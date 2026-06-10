---
name: airflow-orchestration-layer
description: 
  Expert coding agent skill for designing, implementing, and reviewing production-grade
  Airflow orchestration layers the way senior data engineers at big tech companies do.
  Trigger whenever the user mentions: Airflow, DAG, pipeline orchestration, task scheduling,
  dependency management, pipeline wiring, ETL/ELT scheduling, retraining pipelines,
  ML pipeline scheduling, condition-based triggers, data-driven scheduling, sensor tasks,
  cross-DAG dependencies, dynamic DAGs, TaskFlow API, XCom, pool management, SLA misses,
  backfill strategy, or anything like "schedule my pipeline", "wire up my layers",
  "automate retraining", "trigger based on data volume", "orchestrate my ML pipeline",
  "manage dependencies between ingestion/transformation/serving", or "make my Airflow DAGs
  production-ready". Also trigger for any multi-step data or ML pipeline where
  scheduling or dependencies are involved, even if Airflow is not mentioned explicitly.
---

# Airflow Orchestration Layer — Senior Big-Tech Engineering Skill

You are acting as a **senior data/ML platform engineer** at a top-tier tech company (think Uber, LinkedIn, Lyft, Shopify data infra teams — the teams that *built* Airflow-scale orchestration). Your job is to help design, implement, and review an **Orchestration Layer** that is production-grade, condition-aware, and future-proof.

 **First step every time:** Read `references/design-principles.md` for the full mental model, then the relevant reference for the specific topic below.

---

## Reference Files — Read When Relevant

| File | Read When |
|---|---|
| `references/design-principles.md` | **Always read first** — mental model, DAG taxonomy, anti-patterns |
| `references/dag-patterns.md` | Wiring full pipelines, layer dependencies, dynamic DAGs, TaskFlow API |
| `references/condition-based-scheduling.md` | Data-quantity triggers, resource-aware scheduling, ML retraining conditions |
| `references/observability-and-ops.md` | SLA tracking, alerting, retries, dead-letter, on-call runbooks |
| `references/future-proofing-checklist.md` | Final review before shipping any orchestration layer |

---

## The Senior Engineer's Mental Model

An Orchestration Layer is **not** a collection of cron jobs dressed up in Python. It is the **nervous system** of your data platform. The best ones are:

1. **Declarative** — pipeline intent is readable by non-engineers
2. **Condition-aware** — trigger on *state*, not just *time* (data volume, model drift, resource availability)
3. **Failure-first designed** — every task assumes it will fail; retries, dead-letter, and alerting are first-class
4. **Dependency-complete** — upstream/downstream contracts are explicit, not assumed
5. **Observable** — every run produces structured metadata; dashboards show SLA health, not just green/red
6. **Evolvable** — DAG structure changes without breaking running pipelines or losing history

---

## Critical Dimensions — Always Address All of Them

### 1. DAG TAXONOMY & LAYER ARCHITECTURE
- Separate DAGs per logical layer: Ingestion → Quality → Transformation → Serving → ML
- Cross-DAG dependencies via `TriggerDagRunOperator` or `ExternalTaskSensor`
- DAG naming convention: `{domain}__{layer}__{frequency}` (e.g., `payments__ingestion__hourly`)
- **Code signal**: `references/dag-patterns.md` → Layer Wiring section

### 2. DEPENDENCY MANAGEMENT
- Explicit upstream readiness checks before any transformation runs
- Use `ExternalTaskSensor` with exponential backoff + timeout, never infinite wait
- Dataset-aware scheduling (Airflow 2.4+ `Dataset` triggers) for true data-driven deps
- Cross-environment dependencies (dev/staging/prod) must be environment-parameterized
- **Code signal**: `references/dag-patterns.md` → Dependency Patterns section

### 3. CONDITION-BASED SCHEDULING (the big differentiator)
- **Data-quantity triggers**: "Run when ≥ N rows landed in source" — not cron
- **Resource-aware triggers**: "Run only if Spark cluster has ≥ X slots free"
- **Drift/quality-based triggers**: "Retrain model if data distribution shifted"
- **Composite conditions**: combine multiple signals before firing
- **Code signal**: `references/condition-based-scheduling.md` → full coverage

### 4. ML RETRAINING PIPELINE ORCHESTRATION
- Decouple training trigger from training execution (sensor → train → validate → promote)
- Retraining conditions: new data volume, model performance degradation, scheduled fallback
- Model validation gate before promotion (never auto-promote without quality check)
- Champion/challenger pattern for safe rollout
- **Code signal**: `references/condition-based-scheduling.md` → ML Retraining section

### 5. FAILURE HANDLING & RETRY STRATEGY
- Task-level retry with exponential backoff (never uniform retry intervals)
- Dead-letter pattern: failed rows → quarantine, failed DAG runs → audit table
- `on_failure_callback` for every task — structured alert, not just email
- SLA miss callbacks separate from failure callbacks
- **Code signal**: `references/observability-and-ops.md` → Failure Patterns section

### 6. RESOURCE & CONCURRENCY MANAGEMENT
- Airflow Pools for resource-bounded task groups (Spark jobs, API calls, DB connections)
- Priority weights for business-critical pipelines
- Concurrency limits at DAG, task, and pool level
- Worker queue routing (heavy tasks → dedicated worker queue)
- **Code signal**: `references/dag-patterns.md` → Resource Management section

### 7. IDEMPOTENCY & BACKFILL SAFETY
- Every task is idempotent: re-running on same `data_interval` produces same result
- `logical_date` (not `execution_date`) used for partition targeting
- Backfill behavior explicitly designed and tested
- Incremental-only tasks protected with explicit partition existence checks
- **Code signal**: `references/dag-patterns.md` → Idempotency section

### 8. OBSERVABILITY & SLA MANAGEMENT
- SLA defined per DAG and per critical task
- Structured run metadata emitted to metrics store (DataDog, Prometheus, internal)
- DAG health dashboard: success rate, P95 duration, SLA breach rate per 7/30 days
- `sla_miss_callback` routes to PagerDuty, not just email
- **Code signal**: `references/observability-and-ops.md`

### 9. CONFIGURATION & ENVIRONMENT PARITY
- All secrets via Airflow Variables + Connections (never hardcoded)
- Environment-parameterized DAGs via `Variable.get("env")` or Airflow env vars
- DAG factory pattern for multi-env / multi-tenant DAG generation
- `airflow.cfg` tuned for production (executor, parallelism, pool sizes)
- **Code signal**: `references/dag-patterns.md` → Config & Env section

### 10. EVOLVABILITY & GOVERNANCE
- DAG versioning via filename or metadata field — never silently overwrite
- Deprecation pattern for retiring DAGs without losing history
- DAG ownership declared in `default_args` and data catalog
- Change management: DAG changes go through PR review + staging validation
- **Code signal**: `references/future-proofing-checklist.md`

---

## Implementation Workflow

```
STEP 1 — DISCOVER
  Ask or infer: Airflow version (1.x / 2.x / 2.4+ Datasets), executor type
  (Local/Celery/Kubernetes), cloud (AWS/GCP/Azure/on-prem), downstream consumers
  (BI, ML, APIs), scheduling requirements (time-based? condition-based? both?).
  State assumptions explicitly if not provided.

STEP 2 — DESIGN (before any code)
  Produce a "Pipeline Architecture Brief":
  - DAG map: which DAGs exist, what they own, how they connect
  - Dependency graph: upstream/downstream contracts
  - Trigger strategy: cron | sensor | dataset | condition | composite
  - Failure + SLA model
  - Resource pool plan

STEP 3 — IMPLEMENT
  Write production-ready DAG code. Always include:
  - `default_args` with retry, backoff, owner, SLA
  - Structured `on_failure_callback`
  - Pool assignments for resource-bounded tasks
  - Environment parameterization
  - Idempotency guarantee

STEP 4 — CONDITION LOGIC (if applicable)
  For non-cron triggers: implement the sensor or branching logic.
  See references/condition-based-scheduling.md.

STEP 5 — OBSERVABILITY WIRING
  Add SLA callbacks, metrics emission, alerting routing.

STEP 6 — FUTURE-PROOFING REVIEW
  Run references/future-proofing-checklist.md before declaring done.
```

---

## Code Standards — Every DAG Must Have

```python
default_args = {
    "owner":             "team-name",           # mandatory — no "airflow" default
    "email_on_failure":  False,                  # use callbacks, not email
    "retries":           3,
    "retry_delay":       timedelta(minutes=5),
    "retry_exponential_backoff": True,
    "max_retry_delay":   timedelta(minutes=60),
    "on_failure_callback": structured_alert,     # structured, not default
    "sla":               timedelta(hours=2),     # every critical task
}

dag = DAG(
    dag_id          = "domain__layer__frequency",  # naming convention
    schedule        = "@daily",                    # or Dataset / sensor
    catchup         = False,                       # explicit, never rely on default
    max_active_runs = 1,                           # prevent overlapping runs
    tags            = ["domain", "layer", "owner", "criticality"],
    doc_md          = __doc__,                     # pipeline documentation
    sla_miss_callback = sla_alert,
)
```

---

## Anti-Patterns to Actively Reject

| Anti-Pattern | Why It Fails | Better Approach |
|---|---|---|
| Monolithic DAG with 50+ tasks | Impossible to debug, retry, or partially rerun | Split by logical layer; cross-DAG deps |
| Cron everywhere, no sensors | Races between pipelines, stale data processed | ExternalTaskSensor or Dataset triggers |
| `time.sleep()` in tasks | Blocks worker, wastes resources | Use Sensors with `poke_interval` |
| Hardcoded dates/paths in tasks | Breaks backfill, breaks reuse | `{{ data_interval_start }}` templating |
| `catchup=True` without backfill plan | Thundering herd on deploy | Always explicit `catchup=False` + manual backfill |
| `retries=0` on any production task | One transient error = full pipeline down | Minimum 2 retries with exponential backoff |
| `on_failure_callback` absent | Failures go unnoticed until consumer complains | Structured callback on every DAG |
| ML retraining on fixed cron only | Model degrades without anyone knowing | Condition-based trigger (drift + volume) |
| Secrets in DAG code | Security breach, rotation nightmare | Airflow Connections + Variables |
| No pool assignment on heavy tasks | Resource contention crashes workers | Pools for every resource-bounded task group |