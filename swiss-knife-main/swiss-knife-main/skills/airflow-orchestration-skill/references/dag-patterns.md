# DAG Patterns — Pipeline Wiring, Dependencies, Dynamic DAGs

## Table of Contents
1. [Full Pipeline Wiring (Layer DAGs)](#layer-wiring)
2. [Cross-DAG Dependency Patterns](#cross-dag)
3. [Dataset-Driven Scheduling (Airflow 2.4+)](#datasets)
4. [Dynamic Task Mapping](#dynamic-tasks)
5. [TaskFlow API Best Practices](#taskflow)
6. [Resource & Pool Management](#pools)
7. [Configuration & Environment Parity](#config)
8. [Idempotency Patterns](#idempotency)

---

## 1. Full Pipeline Wiring — Layer DAGs {#layer-wiring}

### Ingestion DAG (Layer 1)
```python
# dags/payments__ingestion__hourly.py
"""
Payments Ingestion Pipeline — Layer 1
Extracts orders from Postgres source, lands to S3 raw zone.
Triggers: every hour at :05 to allow source DB to settle.
Owner: data-platform@company.com
SLA: 30 minutes from trigger
"""
from __future__ import annotations
from datetime import datetime, timedelta
from airflow import DAG, Dataset
from airflow.decorators import task
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.transfers.sql_to_s3 import SqlToS3Operator
from callbacks import structured_alert, sla_alert   # see observability reference

# Dataset outlet — downstream DAGs subscribe to this
ORDERS_RAW_DATASET = Dataset("s3://data-lake/raw/payments/orders/")

default_args = {
    "owner":                     "data-platform",
    "email_on_failure":          False,
    "email_on_retry":            False,
    "retries":                   3,
    "retry_delay":               timedelta(minutes=2),
    "retry_exponential_backoff": True,
    "max_retry_delay":           timedelta(minutes=30),
    "on_failure_callback":       structured_alert,
    "sla":                       timedelta(minutes=30),
}

with DAG(
    dag_id          = "payments__ingestion__hourly",
    schedule        = "5 * * * *",
    start_date      = datetime(2024, 1, 1),
    catchup         = False,
    max_active_runs = 1,
    default_args    = default_args,
    tags            = ["payments", "ingestion", "hourly", "layer-1"],
    doc_md          = __doc__,
    sla_miss_callback = sla_alert,
) as dag:

    extract_orders = SqlToS3Operator(
        task_id        = "extract_orders_to_s3",
        sql            = "SELECT * FROM orders WHERE updated_at >= '{{ data_interval_start }}' AND updated_at < '{{ data_interval_end }}'",
        s3_bucket      = "data-lake",
        s3_key         = "raw/payments/orders/{{ ds }}/{{ ts_nodash }}.parquet",
        sql_conn_id    = "postgres_payments_prod",
        aws_conn_id    = "aws_default",
        file_format    = "parquet",
        pool           = "postgres_extract_pool",   # limit concurrent DB connections
        outlets        = [ORDERS_RAW_DATASET],       # signal to downstream Dataset DAGs
    )

    @task(outlets=[ORDERS_RAW_DATASET])
    def validate_extract(ds=None, **context):
        """Verify extracted file exists and has rows."""
        # ... S3 key existence + row count check
        pass

    @task()
    def emit_ingestion_metrics(ds=None, **context):
        """Emit structured telemetry for observability dashboard."""
        # ... push to DataDog / Prometheus
        pass

    extract_orders >> validate_extract() >> emit_ingestion_metrics()
```

### Quality DAG (Layer 2) — Dataset-triggered
```python
# dags/payments__quality__triggered.py
"""
Payments Quality Pipeline — Layer 2
Runs DQ checks on raw orders. Triggered by ingestion dataset completion.
Owner: data-platform@company.com
SLA: 45 minutes from ingestion complete
"""
from airflow import DAG, Dataset
from airflow.decorators import task
from datetime import timedelta
from callbacks import structured_alert, sla_alert

ORDERS_RAW_DATASET   = Dataset("s3://data-lake/raw/payments/orders/")
ORDERS_CLEAN_DATASET = Dataset("s3://data-lake/clean/payments/orders/")

with DAG(
    dag_id          = "payments__quality__triggered",
    schedule        = [ORDERS_RAW_DATASET],   # triggered by ingestion, not cron
    catchup         = False,
    max_active_runs = 2,
    default_args    = {
        "owner": "data-platform",
        "retries": 2,
        "retry_delay": timedelta(minutes=5),
        "on_failure_callback": structured_alert,
        "sla": timedelta(minutes=45),
    },
    sla_miss_callback = sla_alert,
    tags = ["payments", "quality", "layer-2"],
) as dag:

    @task()
    def run_schema_checks(**context): pass

    @task()
    def run_statistical_checks(**context): pass

    @task()
    def run_business_rule_checks(**context): pass

    @task(outlets=[ORDERS_CLEAN_DATASET])
    def promote_to_clean_zone(**context):
        """Move validated data to clean zone, signal downstream."""
        pass

    @task.branch()
    def quality_gate(**context) -> str:
        """Route to success or quarantine based on check results."""
        # Read check results from XCom
        # Return task_id of next task
        pass

    @task()
    def quarantine_bad_data(**context): pass

    [run_schema_checks(), run_statistical_checks(), run_business_rule_checks()] >> quality_gate() >> [promote_to_clean_zone(), quarantine_bad_data()]
```

---

## 2. Cross-DAG Dependency Patterns {#cross-dag}

### ExternalTaskSensor (for non-Dataset cross-DAG deps)
```python
from airflow.sensors.external_task import ExternalTaskSensor

# Wait for upstream DAG's specific task to succeed
wait_for_ingestion = ExternalTaskSensor(
    task_id              = "wait_for_payments_ingestion",
    external_dag_id      = "payments__ingestion__hourly",
    external_task_id     = "validate_extract",     # wait for specific task, not whole DAG
    allowed_states       = ["success"],
    failed_states        = ["failed", "skipped"],  # fail fast if upstream failed
    execution_delta      = timedelta(hours=0),     # same logical date
    timeout              = 60 * 60 * 2,            # 2 hour timeout — never infinite
    poke_interval        = 60,                     # check every 60s
    mode                 = "reschedule",           # release worker slot while waiting
    on_failure_callback  = structured_alert,
)
```

### TriggerDagRunOperator (parent spawns child with params)
```python
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

trigger_transform = TriggerDagRunOperator(
    task_id        = "trigger_transformation_layer",
    trigger_dag_id = "payments__transformation__triggered",
    conf           = {
        "source_partition": "{{ ds }}",
        "triggered_by":     "{{ dag.dag_id }}",
        "run_id":           "{{ run_id }}",
    },
    wait_for_completion = True,    # block until child completes
    poke_interval       = 30,
    failed_states       = ["failed"],
)
```

---

## 3. Dataset-Driven Scheduling (Airflow 2.4+) {#datasets}

The cleanest pattern for layer-to-layer wiring. No sensors needed.

```python
# Producer DAG marks dataset as updated
from airflow import Dataset

MY_DATASET = Dataset("s3://bucket/path/to/data/")

with DAG(...) as producer_dag:
    @task(outlets=[MY_DATASET])   # marks dataset updated on task success
    def write_data():
        pass

# Consumer DAG triggers automatically when dataset is updated
with DAG(
    dag_id   = "consumer_dag",
    schedule = [MY_DATASET],      # triggered by dataset, not cron
    ...
) as consumer_dag:
    @task()
    def process_data():
        pass
```

**Multi-dataset trigger** (wait for multiple upstream datasets):
```python
from airflow import Dataset

ORDERS_DATASET  = Dataset("s3://bucket/orders/")
USERS_DATASET   = Dataset("s3://bucket/users/")

# This DAG runs only when BOTH datasets have been updated
with DAG(
    dag_id   = "orders_user_join__transformation",
    schedule = [ORDERS_DATASET, USERS_DATASET],  # AND condition
    ...
) as dag:
    pass
```

---

## 4. Dynamic Task Mapping {#dynamic-tasks}

For fan-out patterns: one task per partition, per table, per model.

```python
from airflow.decorators import task

@task()
def get_tables_to_process(**context) -> list[str]:
    """Return list of tables needing refresh today."""
    return ["orders", "users", "products", "events"]

@task(
    pool          = "spark_pool",
    retries       = 2,
    retry_delay   = timedelta(minutes=10),
)
def transform_table(table_name: str, ds=None) -> str:
    """Transform one table. Mapped dynamically."""
    # ... run Spark job for this table
    return f"s3://bucket/clean/{table_name}/{ds}/"

# Dynamic mapping — creates one task instance per table
tables      = get_tables_to_process()
transformed = transform_table.expand(table_name=tables)
```

**Partial expansion** (fix some args, expand others):
```python
transform_table.partial(
    pool="spark_pool",
    retries=3,
).expand(table_name=tables)
```

---

## 5. TaskFlow API Best Practices {#taskflow}

```python
from airflow.decorators import task, dag
from datetime import datetime, timedelta

@dag(
    schedule     = "@daily",
    start_date   = datetime(2024, 1, 1),
    catchup      = False,
    default_args = {"owner": "data-team", "retries": 2},
)
def payments_pipeline():
    """Full payments pipeline using TaskFlow API."""

    @task()
    def extract(ds=None) -> dict:
        """Returns metadata dict, NOT raw data (never pass large data via XCom)."""
        row_count = 10_000  # actual extraction stores to S3
        return {"s3_path": f"s3://bucket/raw/{ds}/", "row_count": row_count}

    @task()
    def validate(extract_result: dict) -> dict:
        """Receives extract metadata, runs quality checks."""
        assert extract_result["row_count"] > 0, "Empty extract"
        return {**extract_result, "quality_passed": True}

    @task(pool="spark_pool")
    def transform(validated: dict) -> dict:
        """Heavy Spark job — pool-bounded."""
        return {**validated, "clean_path": validated["s3_path"].replace("raw", "clean")}

    @task()
    def serve(transformed: dict):
        """Refresh serving layer."""
        pass

    # Wire the pipeline
    extracted  = extract()
    validated  = validate(extracted)
    transformed = transform(validated)
    serve(transformed)

# Instantiate the DAG
payments_pipeline()
```

**XCom rules:**
- ✅ Pass control signals: file paths, row counts, status flags, partition identifiers
- ❌ Never pass raw data (DataFrames, large lists) — use S3/GCS paths instead
- ❌ Never pass secrets through XCom

---

## 6. Resource & Pool Management {#pools}

### Pool Configuration (set in Airflow UI or CLI)
```bash
# Create pools — do this in your infrastructure-as-code, not manually
airflow pools set spark_pool          8  "Spark job concurrency limit"
airflow pools set postgres_extract_pool 4  "Postgres connection limit"
airflow pools set api_call_pool       10 "External API rate limit"
airflow pools set ml_training_pool    2  "GPU/large-instance training jobs"
```

### Priority Weights for Business-Critical Pipelines
```python
# High-priority revenue pipeline preempts analytics jobs
extract_revenue = PythonOperator(
    task_id        = "extract_revenue",
    python_callable = _extract_revenue,
    pool           = "postgres_extract_pool",
    priority_weight = 100,   # higher = runs first when pool is contested
    weight_rule    = "upstream",  # propagate priority to all downstream tasks
)

# Lower-priority analytics pipeline
extract_events = PythonOperator(
    task_id        = "extract_events",
    python_callable = _extract_events,
    pool           = "postgres_extract_pool",
    priority_weight = 10,
)
```

### Queue Routing (CeleryExecutor)
```python
# Route heavy jobs to dedicated high-memory workers
spark_task = SparkSubmitOperator(
    task_id     = "run_spark_job",
    queue       = "spark_workers",   # only runs on workers in this queue
    pool        = "spark_pool",
    application = "...",
)
```

---

## 7. Configuration & Environment Parity {#config}

### Environment-Parameterized DAG Factory
```python
# dags/factory/pipeline_factory.py
import os
from airflow import DAG
from airflow.models import Variable

ENV = Variable.get("environment", default_var="dev")   # dev | staging | prod

CONFIGS = {
    "dev":     {"s3_bucket": "dev-data-lake",  "spark_pool_slots": 2, "max_active_runs": 3},
    "staging": {"s3_bucket": "stg-data-lake",  "spark_pool_slots": 4, "max_active_runs": 2},
    "prod":    {"s3_bucket": "prod-data-lake",  "spark_pool_slots": 8, "max_active_runs": 1},
}

cfg = CONFIGS[ENV]
```

### Secrets — Never Hardcode
```python
# Connections: stored in Airflow Connections (encrypted)
# Access via conn_id, never by reading secrets directly in task code
from airflow.hooks.base import BaseHook

conn = BaseHook.get_connection("postgres_payments_prod")
# conn.host, conn.login, conn.password — all from encrypted store

# Variables: for non-secret config
from airflow.models import Variable
s3_prefix = Variable.get("payments_s3_prefix")   # set per environment
```

---

## 8. Idempotency Patterns {#idempotency}

```python
@task()
def write_partition(ds=None, **context):
    """
    Idempotent write: always safe to rerun for same ds.
    Uses partition-replace strategy.
    """
    partition_path = f"s3://bucket/clean/orders/date={ds}/"

    # Step 1: Write to temp location
    temp_path = f"s3://bucket/tmp/orders/{context['run_id']}/"
    write_data_to_s3(data, temp_path)

    # Step 2: Atomically replace the partition (delete old + rename new)
    delete_s3_prefix(partition_path)
    rename_s3_prefix(temp_path, partition_path)
    # Now: rerunning this task always produces the same result


@task()
def upsert_to_warehouse(ds=None, **context):
    """
    Idempotent DB write using MERGE pattern.
    """
    sql = f"""
        MERGE INTO orders_clean AS target
        USING (SELECT * FROM orders_staging WHERE date = '{ds}') AS source
        ON target.order_id = source.order_id
        WHEN MATCHED THEN UPDATE SET *
        WHEN NOT MATCHED THEN INSERT *
    """
    run_sql(sql)
```