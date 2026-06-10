# Condition-Based Scheduling & ML Retraining Pipelines

## The Core Insight

Time-based scheduling is a proxy for what you actually care about: **data state**.
Condition-based scheduling eliminates the proxy and triggers on the real signal.

**Examples of real signals:**
- "Run transformation when ≥ 100,000 new rows have landed"
- "Retrain model when feature distribution drift exceeds threshold"
- "Trigger serving refresh only if Spark cluster utilization < 60%"
- "Run heavy batch job only between 02:00–05:00 AND when queue depth < 10"

---

## Table of Contents
1. [Custom Sensor Foundations](#sensors)
2. [Data-Volume Triggered Pipelines](#volume)
3. [Resource-Aware Scheduling](#resource)
4. [ML Retraining — Full Architecture](#ml-retraining)
5. [Composite Condition Triggers](#composite)
6. [Drift Detection Integration](#drift)

---

## 1. Custom Sensor Foundations {#sensors}

Always use `mode="reschedule"` for sensors that wait > 2 minutes. This releases the worker slot during the wait, preventing worker starvation.

```python
# common/sensors/base_condition_sensor.py
from airflow.sensors.base import BaseSensorOperator
from airflow.utils.context import Context
from typing import Any
import logging

log = logging.getLogger(__name__)

class BaseConditionSensor(BaseSensorOperator):
    """
    Base class for all condition-based sensors.
    Subclass this and implement `check_condition()`.
    """
    ui_color = "#f0e68c"  # visual distinction in Airflow UI

    def __init__(
        self,
        poke_interval:  int   = 300,     # check every 5 minutes
        timeout:        int   = 7200,    # 2-hour max wait — never infinite
        mode:           str   = "reschedule",  # release worker while waiting
        soft_fail:      bool  = False,   # True = skip instead of fail on timeout
        **kwargs,
    ):
        super().__init__(
            poke_interval=poke_interval,
            timeout=timeout,
            mode=mode,
            soft_fail=soft_fail,
            **kwargs,
        )

    def check_condition(self, context: Context) -> tuple[bool, Any]:
        """
        Override this. Return (condition_met: bool, metadata: Any).
        metadata is pushed to XCom for downstream tasks.
        """
        raise NotImplementedError

    def poke(self, context: Context) -> bool:
        met, metadata = self.check_condition(context)
        if met:
            context["task_instance"].xcom_push(key="condition_metadata", value=metadata)
            log.info(f"Condition met: {metadata}")
        else:
            log.info(f"Condition not yet met. Metadata: {metadata}")
        return met
```

---

## 2. Data-Volume Triggered Pipelines {#volume}

### Row-Count Sensor
```python
# common/sensors/row_count_sensor.py
from common.sensors.base_condition_sensor import BaseConditionSensor
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
import pyarrow.parquet as pq

class S3RowCountSensor(BaseConditionSensor):
    """
    Waits until total rows in an S3 prefix partition exceeds threshold.
    Use this instead of cron when downstream processing has a minimum viable batch size.
    """
    template_fields = ("s3_prefix", "min_row_count")

    def __init__(
        self,
        s3_bucket:     str,
        s3_prefix:     str,       # supports Jinja: "raw/orders/{{ ds }}/"
        min_row_count: int,
        aws_conn_id:   str = "aws_default",
        **kwargs,
    ):
        super().__init__(**kwargs)
        self.s3_bucket     = s3_bucket
        self.s3_prefix     = s3_prefix
        self.min_row_count = min_row_count
        self.aws_conn_id   = aws_conn_id

    def check_condition(self, context):
        hook   = S3Hook(aws_conn_id=self.aws_conn_id)
        keys   = hook.list_keys(bucket_name=self.s3_bucket, prefix=self.s3_prefix)
        if not keys:
            return False, {"row_count": 0, "threshold": self.min_row_count}

        total_rows = 0
        for key in keys:
            if key.endswith(".parquet"):
                obj         = hook.get_key(key, self.s3_bucket)
                pf          = pq.read_metadata(obj.get()["Body"])
                total_rows += pf.num_rows

        met = total_rows >= self.min_row_count
        return met, {"row_count": total_rows, "threshold": self.min_row_count, "files": len(keys)}
```

### Usage in DAG
```python
wait_for_minimum_volume = S3RowCountSensor(
    task_id       = "wait_for_minimum_order_volume",
    s3_bucket     = "data-lake",
    s3_prefix     = "raw/payments/orders/{{ ds }}/",
    min_row_count = 50_000,          # don't process unless meaningful batch
    poke_interval = 300,             # check every 5 min
    timeout       = 60 * 60 * 6,    # wait up to 6 hours
    mode          = "reschedule",
    soft_fail     = True,            # skip (not fail) if threshold never reached
)

@task()
def transform_orders(ti=None, ds=None):
    meta = ti.xcom_pull(task_ids="wait_for_minimum_order_volume", key="condition_metadata")
    log.info(f"Processing {meta['row_count']} rows from {meta['files']} files")
    # ... proceed with transformation

wait_for_minimum_volume >> transform_orders()
```

---

## 3. Resource-Aware Scheduling {#resource}

### Spark Cluster Utilization Sensor
```python
# common/sensors/resource_sensor.py
import requests
from common.sensors.base_condition_sensor import BaseConditionSensor

class SparkClusterCapacitySensor(BaseConditionSensor):
    """
    Waits until Spark cluster has sufficient free capacity.
    Prevents submitting heavy jobs when cluster is already saturated.
    """
    def __init__(
        self,
        spark_history_url:     str,
        min_free_executor_pct: float = 0.3,   # need 30% free before submitting
        **kwargs,
    ):
        super().__init__(**kwargs)
        self.spark_history_url     = spark_history_url
        self.min_free_executor_pct = min_free_executor_pct

    def check_condition(self, context):
        resp    = requests.get(f"{self.spark_history_url}/api/v1/applications?status=running")
        apps    = resp.json()
        # Calculate utilization from running apps' executor counts
        # ... (implementation depends on your cluster manager)
        free_pct = self._calculate_free_pct(apps)
        met      = free_pct >= self.min_free_executor_pct
        return met, {"free_executor_pct": free_pct, "running_apps": len(apps)}
```

### Time-Window + Resource Composite
```python
from airflow.sensors.time_delta import TimeDeltaSensorAsync
from airflow.utils.trigger_rule import TriggerRule

# Run heavy job only in maintenance window AND when cluster is free
wait_for_window = TimeDeltaSensorAsync(
    task_id  = "wait_for_maintenance_window",
    delta    = timedelta(hours=2),   # 2 hours after DAG trigger (lands in low-traffic window)
)

check_cluster = SparkClusterCapacitySensor(
    task_id                = "check_cluster_capacity",
    spark_history_url      = "http://spark-master:18080",
    min_free_executor_pct  = 0.4,
    poke_interval          = 120,
    timeout                = 3600,
    mode                   = "reschedule",
    trigger_rule           = TriggerRule.ALL_SUCCESS,  # only check after window opens
)

run_heavy_job = SparkSubmitOperator(
    task_id     = "run_heavy_etl",
    pool        = "spark_pool",
    # ...
)

wait_for_window >> check_cluster >> run_heavy_job
```

---

## 4. ML Retraining — Full Architecture {#ml-retraining}

### The Retraining Pipeline DAG
```python
# dags/ml__orders_model__retraining.py
"""
Orders Propensity Model — Retraining Pipeline
Triggered by: data volume threshold OR drift detection OR weekly fallback.
NOT triggered by cron alone.

Retraining conditions (ANY of these triggers):
  1. New labeled data volume ≥ 10,000 rows since last train
  2. Feature distribution drift score > 0.15 (PSI)
  3. Model F1 on held-out set drops > 5% vs champion
  4. Fallback: weekly scheduled retrain regardless of conditions

Owner: ml-platform@company.com
SLA: 6 hours from trigger to new model available in serving
"""
from __future__ import annotations
from airflow.decorators import task, dag
from airflow.operators.python import BranchPythonOperator
from datetime import datetime, timedelta
from callbacks import structured_alert, sla_alert

@dag(
    dag_id          = "ml__orders_model__retraining",
    schedule        = "0 2 * * 1",     # weekly fallback at Mon 02:00; also triggered externally
    start_date      = datetime(2024, 1, 1),
    catchup         = False,
    max_active_runs = 1,               # never run two retraining jobs simultaneously
    default_args    = {
        "owner":             "ml-platform",
        "retries":           1,
        "retry_delay":       timedelta(minutes=10),
        "on_failure_callback": structured_alert,
        "sla":               timedelta(hours=6),
    },
    sla_miss_callback = sla_alert,
    tags = ["ml", "retraining", "orders-model", "layer-5"],
    doc_md = __doc__,
)
def orders_model_retraining():

    @task()
    def check_retraining_conditions(**context) -> dict:
        """
        Evaluate all retraining conditions.
        Returns a summary dict — used by gate to decide proceed/skip.
        """
        from ml.conditions import (
            check_new_data_volume,
            check_feature_drift,
            check_model_performance,
        )
        volume_met,     volume_meta     = check_new_data_volume(min_rows=10_000)
        drift_detected, drift_meta      = check_feature_drift(psi_threshold=0.15)
        perf_degraded,  perf_meta       = check_model_performance(f1_drop_threshold=0.05)
        triggered_by_schedule           = context["dag_run"].run_type == "scheduled"

        should_retrain = any([volume_met, drift_detected, perf_degraded, triggered_by_schedule])

        return {
            "should_retrain":     should_retrain,
            "reasons":            {
                "new_data_volume": volume_meta,
                "feature_drift":   drift_meta,
                "perf_degraded":   perf_meta,
                "scheduled":       triggered_by_schedule,
            }
        }

    @task.branch()
    def retraining_gate(conditions: dict) -> str:
        """Route to train or skip based on conditions evaluation."""
        if conditions["should_retrain"]:
            return "prepare_training_dataset"
        return "skip_retraining"

    @task()
    def skip_retraining(**context):
        """Log the skip decision — important for audit trail."""
        import logging
        logging.info("Retraining skipped: conditions not met.")

    @task(pool="ml_training_pool")
    def prepare_training_dataset(conditions: dict, ds=None) -> dict:
        """Build train/val/test splits. Returns dataset metadata."""
        # ... feature engineering, split logic
        return {
            "train_path": f"s3://ml-data/orders-model/train/{ds}/",
            "val_path":   f"s3://ml-data/orders-model/val/{ds}/",
            "test_path":  f"s3://ml-data/orders-model/test/{ds}/",
            "n_train":    80_000,
        }

    @task(pool="ml_training_pool", execution_timeout=timedelta(hours=4))
    def train_model(dataset: dict, ds=None) -> dict:
        """Train the model. Returns artifact paths and metrics."""
        # ... training logic (Spark MLlib / sklearn / XGBoost / etc.)
        return {
            "model_path":  f"s3://ml-models/orders-model/candidate/{ds}/",
            "metrics":     {"f1": 0.87, "precision": 0.85, "recall": 0.89},
            "training_rows": dataset["n_train"],
        }

    @task()
    def validate_candidate_model(trained: dict) -> dict:
        """
        Validate candidate vs champion model.
        NEVER promote without this gate passing.
        """
        champion_metrics = load_champion_metrics()  # from model registry
        candidate_f1     = trained["metrics"]["f1"]
        champion_f1      = champion_metrics["f1"]

        improvement = (candidate_f1 - champion_f1) / champion_f1

        return {
            **trained,
            "champion_f1":  champion_f1,
            "improvement":  improvement,
            "gate_passed":  improvement >= -0.01,  # allow up to 1% regression (noise tolerance)
        }

    @task.branch()
    def promotion_gate(validated: dict) -> str:
        """Only promote if validation passed."""
        if validated["gate_passed"]:
            return "promote_to_champion"
        return "flag_training_failure"

    @task()
    def promote_to_champion(validated: dict, ds=None):
        """Register new champion in model registry, update serving pointer."""
        register_model(
            path    = validated["model_path"],
            version = ds,
            metrics = validated["metrics"],
            status  = "champion",
        )
        # Atomic swap: serving layer picks up new champion on next request

    @task()
    def flag_training_failure(validated: dict):
        """Alert team that candidate didn't pass validation. Do NOT promote."""
        send_alert(
            title   = "ML Retraining: Candidate did not beat champion",
            details = validated,
            severity = "WARNING",
        )

    @task()
    def trigger_serving_refresh():
        """Warm the serving cache / feature store after new champion promoted."""
        pass

    # Wire the pipeline
    conditions = check_retraining_conditions()
    gate       = retraining_gate(conditions)
    dataset    = prepare_training_dataset(conditions)
    trained    = train_model(dataset)
    validated  = validate_candidate_model(trained)
    promo_gate = promotion_gate(validated)

    gate >> [dataset, skip_retraining()]
    promo_gate >> [promote_to_champion(validated) >> trigger_serving_refresh(), flag_training_failure(validated)]

orders_model_retraining()
```

### External Trigger for Condition-Based Retraining
```python
# ml/triggers/retrain_trigger.py
# Called by your data pipeline (not by Airflow itself) when conditions are met
import requests

def trigger_retraining_if_conditions_met(new_row_count: int, drift_score: float):
    """
    Push-based trigger: data pipeline calls this after quality checks.
    More responsive than sensor polling for high-frequency pipelines.
    """
    should_trigger = new_row_count >= 10_000 or drift_score > 0.15

    if should_trigger:
        resp = requests.post(
            "http://airflow-webserver:8080/api/v1/dags/ml__orders_model__retraining/dagRuns",
            json = {
                "conf": {
                    "trigger_reason":  "external_condition",
                    "new_row_count":   new_row_count,
                    "drift_score":     drift_score,
                }
            },
            headers = {"Authorization": f"Bearer {get_airflow_token()}"},
        )
        resp.raise_for_status()
```

---

## 5. Composite Condition Triggers {#composite}

```python
# common/sensors/composite_condition_sensor.py
from common.sensors.base_condition_sensor import BaseConditionSensor
from typing import Callable, Literal

class CompositeConditionSensor(BaseConditionSensor):
    """
    Combine multiple condition checks with AND or OR logic.
    Each condition_fn returns (bool, dict).
    """
    def __init__(
        self,
        conditions: list[Callable],
        operator:   Literal["AND", "OR"] = "AND",
        **kwargs,
    ):
        super().__init__(**kwargs)
        self.conditions = conditions
        self.operator   = operator

    def check_condition(self, context):
        results = [fn(context) for fn in self.conditions]
        bools   = [r[0] for r in results]
        metas   = [r[1] for r in results]

        if self.operator == "AND":
            met = all(bools)
        else:
            met = any(bools)

        return met, {"operator": self.operator, "results": list(zip(bools, metas))}


# Usage
from ml.conditions import check_new_data_volume, check_feature_drift

wait_for_retrain_conditions = CompositeConditionSensor(
    task_id    = "wait_for_retrain_conditions",
    conditions = [
        lambda ctx: check_new_data_volume(min_rows=10_000),
        lambda ctx: check_feature_drift(psi_threshold=0.15),
    ],
    operator      = "OR",      # retrain if EITHER condition met
    poke_interval = 600,       # check every 10 min
    timeout       = 86400,     # wait up to 24 hours
    mode          = "reschedule",
)
```

---

## 6. Drift Detection Integration {#drift}

```python
# ml/conditions/feature_drift.py
import numpy as np
from scipy.stats import ks_2samp

def compute_psi(expected: np.ndarray, actual: np.ndarray, buckets: int = 10) -> float:
    """
    Population Stability Index — standard drift metric.
    PSI < 0.1: no change. 0.1–0.2: moderate. > 0.2: significant drift.
    """
    breakpoints = np.percentile(expected, np.linspace(0, 100, buckets + 1))
    expected_pct = np.histogram(expected, bins=breakpoints)[0] / len(expected)
    actual_pct   = np.histogram(actual,   bins=breakpoints)[0] / len(actual)

    # Avoid log(0)
    expected_pct = np.clip(expected_pct, 1e-6, None)
    actual_pct   = np.clip(actual_pct,   1e-6, None)

    psi = np.sum((actual_pct - expected_pct) * np.log(actual_pct / expected_pct))
    return float(psi)


def check_feature_drift(psi_threshold: float = 0.15) -> tuple[bool, dict]:
    """
    Compare current feature distributions vs training baseline.
    Returns (drift_detected, metadata).
    """
    # Load baseline from model registry / feature store
    baseline_features = load_baseline_features()
    current_features  = load_current_features(lookback_days=7)

    psi_scores = {}
    for feature in baseline_features.columns:
        psi_scores[feature] = compute_psi(
            baseline_features[feature].dropna().values,
            current_features[feature].dropna().values,
        )

    max_psi          = max(psi_scores.values())
    drifted_features = {k: v for k, v in psi_scores.items() if v > psi_threshold}
    drift_detected   = max_psi > psi_threshold

    return drift_detected, {
        "max_psi":          max_psi,
        "threshold":        psi_threshold,
        "drifted_features": drifted_features,
        "all_psi_scores":   psi_scores,
    }
```