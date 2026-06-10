# Stack-Specific Quality Layer Patterns

## Table of Contents
1. [dbt (SQL warehouses)](#dbt)
2. [PySpark / Databricks](#pyspark)
3. [Great Expectations](#great-expectations)
4. [Soda Core](#soda)
5. [Pure SQL (any warehouse)](#pure-sql)
6. [Python / Pandas (small scale)](#pandas)
7. [Kafka / Streaming](#kafka)

---

## 1. dbt {#dbt}

### Check Registry in YAML (declarative, evolvable)
```yaml
# models/marts/orders/_schema.yml
version: 2

models:
  - name: fct_orders
    meta:
      owner: "data-platform@company.com"
      sla_freshness_hours: 4
      data_contract_version: "1.3.0"
    columns:
      - name: order_id
        description: "Unique order identifier"
        tests:
          - unique
          - not_null
      - name: user_id
        tests:
          - not_null
          - relationships:
              to: ref('dim_users')
              field: user_id
              severity: error   # BLOCKING in dbt terms
      - name: revenue_usd
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 1000000  # flag anything > $1M for manual review
              severity: warn     # WARNING — alert, don't halt
      - name: created_at
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: "'2020-01-01'"
              max_value: "current_date"

    tests:
      # Cross-column business rule
      - dbt_utils.expression_is_true:
          expression: "shipped_at >= created_at OR shipped_at IS NULL"
          severity: error
          config:
            error_if: ">0"
```

### Custom Generic Test (modular, reusable)
```sql
-- tests/generic/volume_in_envelope.sql
-- Usage: - volume_in_envelope: {lookback_days: 7, min_pct: 0.5, max_pct: 2.0}
{% test volume_in_envelope(model, column_name, lookback_days=7, min_pct=0.5, max_pct=2.0) %}

with current_count as (
    select count(*) as n from {{ model }}
),
historical_avg as (
    select avg(row_count) as avg_n
    from {{ this.schema }}.dq_volume_history   -- populated by audit macro
    where model_name = '{{ model.name }}'
      and run_date >= current_date - {{ lookback_days }}
)
select 1
from current_count c, historical_avg h
where c.n < h.avg_n * {{ min_pct }}
   or c.n > h.avg_n * {{ max_pct }}

{% endtest %}
```

### Quarantine Macro
```sql
-- macros/quarantine_failures.sql
{% macro quarantine_failures(model, check_id, severity) %}
insert into {{ target.schema }}.dq_quarantine
select
    '{{ model }}'           as asset,
    '{{ check_id }}'        as check_id,
    '{{ severity }}'        as severity,
    '{{ run_started_at }}'  as detected_at,
    '{{ invocation_id }}'   as run_id,
    to_json(*)              as bad_row_json
from {{ model }}
where {{ caller() }}   -- the WHERE clause that identifies bad rows
{% endmacro %}
```

---

## 2. PySpark / Databricks {#pyspark}

### Check Registry (dataclass-driven, version-controlled)
```python
# quality/checks/registry.py
from dataclasses import dataclass, field
from enum import Enum
from typing import Callable
import pyspark.sql.functions as F
from pyspark.sql import DataFrame


class Severity(str, Enum):
    BLOCKING = "BLOCKING"
    WARNING  = "WARNING"
    INFO     = "INFO"


@dataclass
class QualityCheck:
    check_id:    str
    asset:       str
    dimension:   str   # one of the 10 canonical dimensions
    severity:    Severity
    description: str
    owner:       str
    version:     str
    predicate:   Callable[[DataFrame], DataFrame]  # returns DF of failing rows

    def run(self, df: DataFrame) -> dict:
        failing = self.predicate(df)
        n_fail  = failing.count()
        return {
            "check_id":   self.check_id,
            "asset":      self.asset,
            "dimension":  self.dimension,
            "severity":   self.severity.value,
            "owner":      self.owner,
            "version":    self.version,
            "passed":     n_fail == 0,
            "fail_count": n_fail,
            "total_rows": df.count(),
        }
```

### Check Definitions (declarative, separated from logic)
```python
# quality/checks/orders_checks.py
from quality.checks.registry import QualityCheck, Severity
import pyspark.sql.functions as F

ORDERS_CHECKS = [
    QualityCheck(
        check_id    = "orders.pk_unique",
        asset       = "gold.fct_orders",
        dimension   = "UNIQUENESS",
        severity    = Severity.BLOCKING,
        description = "order_id must be globally unique",
        owner       = "data-platform@company.com",
        version     = "1.0.0",
        predicate   = lambda df: (
            df.groupBy("order_id")
              .count()
              .filter(F.col("count") > 1)
        ),
    ),
    QualityCheck(
        check_id    = "orders.revenue_non_negative",
        asset       = "gold.fct_orders",
        dimension   = "BUSINESS_INTEGRITY",
        severity    = Severity.WARNING,
        description = "Revenue must be >= 0; negative values indicate refund processing bug",
        owner       = "payments-data@company.com",
        version     = "1.2.0",
        predicate   = lambda df: df.filter(F.col("revenue_usd") < 0),
    ),
    QualityCheck(
        check_id    = "orders.freshness",
        asset       = "gold.fct_orders",
        dimension   = "FRESHNESS",
        severity    = Severity.BLOCKING,
        description = "Latest order must be within 4 hours; longer gap = upstream failure",
        owner       = "data-platform@company.com",
        version     = "1.0.0",
        predicate   = lambda df: df.filter(
            F.max("created_at").over(F.Window.rowsBetween(
                F.Window.unboundedPreceding, F.Window.unboundedFollowing
            )) < F.current_timestamp() - F.expr("INTERVAL 4 HOURS")
        ),
    ),
]
```

### Quality Runner (with quarantine + structured events)
```python
# quality/runner.py
from pyspark.sql import SparkSession, DataFrame
from quality.checks.registry import QualityCheck, Severity
from datetime import datetime
import json


def run_quality_suite(
    spark:    SparkSession,
    df:       DataFrame,
    checks:   list[QualityCheck],
    run_id:   str,
) -> dict:
    results    = []
    quarantine = []
    blocking_failures = []

    for check in checks:
        result = check.run(df)
        result["run_id"]     = run_id
        result["checked_at"] = datetime.utcnow().isoformat()
        results.append(result)

        if not result["passed"]:
            # Quarantine bad rows
            bad_rows = check.predicate(df).withColumn("_dq_check_id", F.lit(check.check_id)) \
                                          .withColumn("_dq_run_id",   F.lit(run_id)) \
                                          .withColumn("_dq_severity", F.lit(check.severity.value)) \
                                          .withColumn("_dq_detected_at", F.current_timestamp())
            quarantine.append(bad_rows)

            # Emit structured failure event (to Kafka / Delta / monitoring)
            emit_quality_event(result)

            if check.severity == Severity.BLOCKING:
                blocking_failures.append(check.check_id)

    # Write quarantine batch
    if quarantine:
        from functools import reduce
        combined = reduce(DataFrame.unionByName, quarantine, allowMissingColumns=True)
        combined.write.mode("append").saveAsTable("dq.quarantine")

    # Write quality run metadata
    spark.createDataFrame(results).write.mode("append").saveAsTable("dq.quality_runs")

    if blocking_failures:
        raise RuntimeError(
            f"BLOCKING quality checks failed: {blocking_failures}. "
            f"Pipeline halted. Run ID: {run_id}"
        )

    return {"run_id": run_id, "results": results}


def emit_quality_event(result: dict):
    """Emit to your monitoring stack. Replace with DataDog/Prometheus/Kafka as needed."""
    print(json.dumps({"type": "quality_event", **result}))  # structured log → log aggregator
```

---

## 3. Great Expectations {#great-expectations}

### Expectation Suite (code-first, not GUI)
```python
# quality/suites/orders_suite.py
import great_expectations as gx
from great_expectations.core.batch import RuntimeBatchRequest

context = gx.get_context()

suite = context.add_or_update_expectation_suite("orders.gold.v1")

# --- STRUCTURAL ---
suite.add_expectation(gx.core.ExpectationConfiguration(
    expectation_type="expect_column_to_exist",
    kwargs={"column": "order_id"},
    meta={"dimension": "STRUCTURAL", "owner": "data-platform@company.com", "severity": "BLOCKING"}
))

# --- UNIQUENESS ---
suite.add_expectation(gx.core.ExpectationConfiguration(
    expectation_type="expect_column_values_to_be_unique",
    kwargs={"column": "order_id"},
    meta={"dimension": "UNIQUENESS", "severity": "BLOCKING"}
))

# --- STATISTICAL (volume envelope) ---
suite.add_expectation(gx.core.ExpectationConfiguration(
    expectation_type="expect_table_row_count_to_be_between",
    kwargs={"min_value": 10_000, "max_value": 5_000_000},
    meta={
        "dimension": "STATISTICAL",
        "severity": "WARNING",
        "note": "Update bounds monthly via adaptive_threshold_updater.py"
    }
))

# --- BUSINESS INTEGRITY ---
suite.add_expectation(gx.core.ExpectationConfiguration(
    expectation_type="expect_column_values_to_be_between",
    kwargs={"column": "revenue_usd", "min_value": 0, "mostly": 0.999},
    meta={"dimension": "BUSINESS_INTEGRITY", "severity": "WARNING"}
))

context.save_expectation_suite(suite)
```

### Checkpoint with Actions (quarantine + alert wiring)
```python
# quality/checkpoints/orders_checkpoint.py
checkpoint = context.add_or_update_checkpoint(
    name="orders_daily",
    config={
        "class_name": "Checkpoint",
        "action_list": [
            {"name": "store_validation_result",  "action": {"class_name": "StoreValidationResultAction"}},
            {"name": "update_data_docs",          "action": {"class_name": "UpdateDataDocsAction"}},
            {
                "name": "send_slack_on_failure",
                "action": {
                    "class_name": "SlackNotificationAction",
                    "slack_webhook": "${SLACK_DQ_WEBHOOK}",
                    "notify_on": "failure",
                    "notify_with": ["local_site"],
                }
            },
        ]
    }
)
```

---

## 4. Soda Core {#soda}

### Soda Check File (YAML-first, accessible to non-engineers)
```yaml
# quality/soda/orders.yml
checks for fct_orders:

  # STRUCTURAL
  - schema:
      name: "orders_schema_contract_v1"
      fail:
        when required column missing: [order_id, user_id, revenue_usd, created_at]
        when wrong column type:
          revenue_usd: decimal
          created_at: timestamp

  # UNIQUENESS
  - duplicate_count(order_id) = 0:
      name: "order_id must be unique"
      fail: when > 0
      warn: when > 0  # belt-and-suspenders: warn first, fail definitively

  # FRESHNESS
  - freshness(created_at) < 4h:
      name: "orders freshness SLA: 4 hours"

  # STATISTICAL
  - row_count between 10000 and 5000000:
      name: "volume_envelope_orders"
      warn: when not between 50000 and 2000000

  # BUSINESS INTEGRITY
  - invalid_count(revenue_usd) = 0:
      valid min: 0
      name: "revenue_non_negative"
      fail: when > 100  # absolute tolerance
      warn: when > 0

  # NULL RATES
  - missing_percent(user_id) < 0.1%:
      name: "user_id null rate below SLA"
```

---

## 5. Pure SQL (any warehouse) {#pure-sql}

### Quality Metadata Table (infrastructure-first)
```sql
-- Run once to set up quality infrastructure
CREATE TABLE IF NOT EXISTS dq.check_registry (
    check_id     STRING NOT NULL,
    asset        STRING NOT NULL,
    dimension    STRING NOT NULL,
    severity     STRING NOT NULL CHECK (severity IN ('BLOCKING','WARNING','INFO')),
    description  STRING,
    owner        STRING NOT NULL,
    version      STRING NOT NULL,
    enabled      BOOLEAN DEFAULT TRUE,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dq.quality_runs (
    run_id       STRING NOT NULL,
    check_id     STRING NOT NULL,
    asset        STRING NOT NULL,
    dimension    STRING,
    severity     STRING,
    passed       BOOLEAN NOT NULL,
    fail_count   BIGINT,
    total_rows   BIGINT,
    fail_pct     DOUBLE,
    checked_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    run_date     DATE DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS dq.quarantine (
    asset        STRING,
    check_id     STRING,
    severity     STRING,
    run_id       STRING,
    detected_at  TIMESTAMP,
    bad_row_json STRING   -- full row serialized to JSON
);
```

### Reusable SQL Check Template
```sql
-- quality/sql/check_template.sql
-- Replace {{TABLE}}, {{CHECK_ID}}, {{PREDICATE}}, {{SEVERITY}} at runtime via Jinja/dbt

INSERT INTO dq.quality_runs (run_id, check_id, asset, passed, fail_count, total_rows, fail_pct, checked_at)
WITH
  bad_rows AS (
      SELECT * FROM {{TABLE}} WHERE {{PREDICATE}}
  ),
  total AS (
      SELECT COUNT(*) AS n FROM {{TABLE}}
  ),
  bad   AS (
      SELECT COUNT(*) AS n FROM bad_rows
  )
SELECT
    '{{RUN_ID}}'    AS run_id,
    '{{CHECK_ID}}'  AS check_id,
    '{{TABLE}}'     AS asset,
    bad.n = 0       AS passed,
    bad.n           AS fail_count,
    total.n         AS total_rows,
    ROUND(bad.n * 100.0 / NULLIF(total.n, 0), 4) AS fail_pct,
    CURRENT_TIMESTAMP AS checked_at
FROM total, bad;

-- Quarantine bad rows
INSERT INTO dq.quarantine (asset, check_id, severity, run_id, detected_at, bad_row_json)
SELECT
    '{{TABLE}}',
    '{{CHECK_ID}}',
    '{{SEVERITY}}',
    '{{RUN_ID}}',
    CURRENT_TIMESTAMP,
    TO_JSON(b.*)
FROM (SELECT * FROM {{TABLE}} WHERE {{PREDICATE}}) b;
```

---

## 6. Python / Pandas (small scale) {#pandas}

### Lightweight Check Framework
```python
# quality/pandas_quality.py
import pandas as pd
from dataclasses import dataclass
from typing import Callable
from datetime import datetime
import json, uuid


@dataclass
class PandasCheck:
    check_id:  str
    asset:     str
    dimension: str
    severity:  str  # BLOCKING | WARNING | INFO
    owner:     str
    predicate: Callable[[pd.DataFrame], pd.Series]  # returns boolean mask of BAD rows

    def run(self, df: pd.DataFrame) -> dict:
        bad_mask   = self.predicate(df)
        fail_count = bad_mask.sum()
        return {
            "check_id":   self.check_id,
            "asset":      self.asset,
            "dimension":  self.dimension,
            "severity":   self.severity,
            "owner":      self.owner,
            "passed":     fail_count == 0,
            "fail_count": int(fail_count),
            "total_rows": len(df),
            "fail_pct":   round(fail_count / len(df) * 100, 4) if len(df) > 0 else 0,
            "checked_at": datetime.utcnow().isoformat(),
            "bad_rows":   df[bad_mask].to_dict(orient="records"),  # for quarantine
        }


def run_suite(df: pd.DataFrame, checks: list[PandasCheck]) -> pd.DataFrame:
    run_id  = str(uuid.uuid4())[:8]
    results = []
    blocking_failures = []

    for check in checks:
        r = check.run(df)
        r["run_id"] = run_id
        results.append(r)

        if not r["passed"]:
            # Write quarantine (append to CSV or DB in real usage)
            quarantine_df = pd.DataFrame(r["bad_rows"])
            quarantine_df["_dq_check_id"] = check.check_id
            quarantine_df["_dq_run_id"]   = run_id
            quarantine_df["_dq_severity"] = check.severity
            quarantine_df.to_csv("dq_quarantine.csv", mode="a", header=False, index=False)

            # Emit structured event
            print(json.dumps({k: v for k, v in r.items() if k != "bad_rows"}))

            if check.severity == "BLOCKING":
                blocking_failures.append(check.check_id)

    summary = pd.DataFrame([{k: v for k, v in r.items() if k != "bad_rows"} for r in results])

    if blocking_failures:
        raise RuntimeError(f"BLOCKING checks failed: {blocking_failures}. Run ID: {run_id}")

    return summary
```

---

## 7. Kafka / Streaming {#kafka}

### Quality Sidecar Pattern (Faust / Python)
```python
# quality/streaming/orders_quality_sidecar.py
import faust
from datetime import datetime
import json

app = faust.App("orders-quality-sidecar", broker="kafka://localhost:9092")

orders_topic   = app.topic("orders.raw",     value_type=bytes)
quality_topic  = app.topic("quality.events", value_type=bytes)


def check_order_event(event: dict) -> list[dict]:
    """Returns list of quality failures for this event. Empty = passed."""
    failures = []

    if not event.get("order_id"):
        failures.append({
            "check_id":  "stream.order_id.not_null",
            "dimension": "STRUCTURAL",
            "severity":  "BLOCKING",
            "value":     None,
        })

    revenue = event.get("revenue_usd")
    if revenue is not None and revenue < 0:
        failures.append({
            "check_id":  "stream.revenue.non_negative",
            "dimension": "BUSINESS_INTEGRITY",
            "severity":  "WARNING",
            "value":     revenue,
        })

    return failures


@app.agent(orders_topic)
async def quality_sidecar(orders):
    async for raw in orders:
        event    = json.loads(raw)
        failures = check_order_event(event)

        for failure in failures:
            quality_event = {
                **failure,
                "asset":      "kafka.orders.raw",
                "event_key":  event.get("order_id"),
                "detected_at": datetime.utcnow().isoformat(),
            }
            await quality_topic.send(value=json.dumps(quality_event).encode())
```