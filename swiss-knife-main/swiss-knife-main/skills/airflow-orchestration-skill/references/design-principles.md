# Design Principles — Airflow Orchestration Layer

## The Foundational Insight

Most Airflow DAGs fail not because of bad Python code, but because of **wrong mental models**:
- Treating Airflow as a cron replacement (it's an *orchestration platform*)
- Building pipelines that work in development but race in production
- Scheduling on time when the correct trigger is *data state*
- Designing for the happy path instead of the failure path

The best orchestration layers at scale treat pipelines the way SREs treat services: with SLOs, runbooks, graceful degradation, and blameless post-mortems.

---

## DAG Taxonomy — The Layer Model

Big tech data platforms organize DAGs into logical layers, each with a clear contract:

```
┌─────────────────────────────────────────────────────────────────┐
│  LAYER 5: ML / AI                                               │
│  Retraining, evaluation, promotion, serving refresh             │
│  Trigger: condition-based (drift, volume, performance)          │
├─────────────────────────────────────────────────────────────────┤
│  LAYER 4: SERVING                                               │
│  Mart refresh, feature store update, API cache warm             │
│  Trigger: after Layer 3 completes + quality gate passes         │
├─────────────────────────────────────────────────────────────────┤
│  LAYER 3: TRANSFORMATION                                        │
│  dbt runs, Spark transforms, aggregations                       │
│  Trigger: after Layer 2 (quality) passes                        │
├─────────────────────────────────────────────────────────────────┤
│  LAYER 2: QUALITY                                               │
│  DQ checks, schema validation, anomaly detection                │
│  Trigger: after Layer 1 (ingestion) completes                   │
├─────────────────────────────────────────────────────────────────┤
│  LAYER 1: INGESTION                                             │
│  Source extraction, landing zone writes, CDC capture            │
│  Trigger: cron | event | API webhook                            │
└─────────────────────────────────────────────────────────────────┘
```

**Key rules:**
- Each layer is a separate DAG (or set of DAGs)
- No layer skips its upstream dependency — quality always runs before transformation
- Cross-layer wiring uses `ExternalTaskSensor` or `Dataset` triggers (Airflow 2.4+)
- Each DAG owns exactly one layer for exactly one domain (no cross-domain monoliths)

---

## Scheduling Taxonomy

Understanding *when* to use each scheduling mechanism is the senior-engineer differentiator:

| Mechanism | Use When | Airflow Construct |
|---|---|---|
| **Cron** | Upstream is external and always ready on schedule | `schedule="0 6 * * *"` |
| **Dataset Trigger** | Upstream is another Airflow DAG; simple "completed" signal | `schedule=[my_dataset]` |
| **ExternalTaskSensor** | Need to wait for specific task/DAG state, with timeout | `ExternalTaskSensor` |
| **FileSensor / S3KeySensor** | Wait for a file to land in storage | `S3KeySensor`, `FileSensor` |
| **Custom Sensor** | Condition-based: volume, drift, resource, composite | `BaseSensorOperator` subclass |
| **TriggerDagRunOperator** | Parent DAG explicitly spawns child DAG with params | `TriggerDagRunOperator` |
| **REST API trigger** | External system pushes trigger (CI/CD, application event) | Airflow REST API + webhook |

**Never use cron when the real dependency is data state.** Cron creates race conditions when upstream is slow; sensors create safe waits.

---

## The Failure-First Design Contract

Every task in a production DAG must answer these questions before shipping:

1. **What happens if this task fails once?** → Retry with backoff
2. **What happens if it fails N times?** → Alert + halt cleanly
3. **What downstream tasks are blocked?** → SLA impact documented
4. **Who gets paged?** → `on_failure_callback` routes to right owner
5. **What state does it leave behind on failure?** → Partial writes cleaned up or idempotent
6. **Can it be safely retried manually?** → Idempotency guarantee

If any answer is "I don't know," the task is not production-ready.

---

## Idempotency — The Non-Negotiable

Every Airflow task MUST be idempotent: running it twice on the same `logical_date` produces the same result as running it once.

**Why this matters:**
- Airflow retries run the same task again
- Manual reruns are common in production
- Backfills re-execute historical runs
- Catchup re-runs missed intervals

**Patterns for idempotency:**

```python
# BAD: append-only, duplicates on retry
df.to_sql("orders", con=engine, if_exists="append")

# GOOD: partition-replace — always safe to rerun
df.to_sql(f"orders_{logical_date}", con=engine, if_exists="replace")

# GOOD: DELETE + INSERT pattern
cursor.execute("DELETE FROM orders WHERE date = %s", [logical_date])
cursor.executemany("INSERT INTO orders ...", rows)

# GOOD: MERGE / UPSERT pattern
spark.sql(f"""
    MERGE INTO orders USING staging_orders
    ON orders.order_id = staging_orders.order_id
    WHEN MATCHED THEN UPDATE SET *
    WHEN NOT MATCHED THEN INSERT *
""")
```

---

## Airflow 2.x vs 1.x Decision Points

| Feature | Airflow 1.x | Airflow 2.x (use this) |
|---|---|---|
| Task definition | PythonOperator with plain functions | `@task` decorator (TaskFlow API) |
| Data passing | XCom push/pull (verbose) | `@task` return values (automatic XCom) |
| Scheduling | cron strings only | cron + Dataset + Timetable |
| Dependencies | `set_downstream()` / `>>` | `>>` + Dataset `schedule=` |
| Dynamic tasks | `SubDagOperator` (deprecated) | Dynamic Task Mapping (`expand()`) |
| Secrets | Variables (unencrypted option) | Connections + Secret backends |

**Always use Airflow 2.4+ for new projects.** The Dataset scheduling model eliminates entire classes of race conditions.

---

## The "Day 90 Problem" in Orchestration

Things that look fine at launch but fail three months later:

1. **Schedule drift** — upstream partner changes their delivery time; your cron races ahead and processes empty partitions. Fix: sensors, not cron.

2. **Worker starvation** — a single heavy Spark job occupies all workers, queueing 40 other tasks. Fix: Pools with slot limits.

3. **Backfill thundering herd** — team runs a 6-month backfill, spawns 180 DAG runs concurrently, crashes the scheduler. Fix: `max_active_runs=1` + manual date-range backfill.

4. **XCom payload explosion** — someone stores a 50MB DataFrame in XCom, metadata DB hits memory limit. Fix: XCom only for control signals; data via external storage (S3/GCS).

5. **Orphaned sensors** — a sensor waiting for a task that was renamed never times out, accumulates, eats worker slots. Fix: Always set `timeout` + `mode="reschedule"` on sensors.

6. **ML retraining never triggers** — model degrades silently because condition-based trigger logic was never wired; team assumed "we'll add it later." Fix: Retraining conditions are part of the initial design, not an afterthought.