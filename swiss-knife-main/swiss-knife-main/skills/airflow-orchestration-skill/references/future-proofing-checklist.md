# Future-Proofing Checklist — Airflow Orchestration Layer

Run this before declaring any orchestration layer "production-ready."
A senior engineer should answer YES to every item, or document WHY a NO is acceptable.

---

## Category 1: DAG Design & Structure

- [ ] **DAG naming convention enforced** — `domain__layer__frequency` pattern used consistently
- [ ] **One DAG per logical layer per domain** — no cross-domain monolith DAGs
- [ ] **`catchup=False` explicit on every DAG** — never relying on Airflow default
- [ ] **`max_active_runs=1` on stateful pipelines** — no concurrent runs that could race
- [ ] **`doc_md` populated** — pipeline intent readable without opening the code
- [ ] **Tags complete** — domain, layer, owner, criticality all tagged
- [ ] **No task has > 15 direct dependencies** — complexity is a maintainability risk

## Category 2: Scheduling & Triggers

- [ ] **Cron vs sensor decision is documented** — not defaulting to cron everywhere
- [ ] **All ExternalTaskSensors have `timeout`** — no infinite-wait sensors
- [ ] **All sensors use `mode="reschedule"`** — not blocking worker slots while waiting
- [ ] **Dataset triggers used for layer-to-layer deps** (Airflow 2.4+) where applicable
- [ ] **Condition-based triggers implemented** for ML retraining (not cron-only)
- [ ] **Scheduled fallback exists** for all condition-based triggers — what fires if condition never met?

## Category 3: Failure Handling

- [ ] **Every DAG has `on_failure_callback`** — no failures go unnoticed
- [ ] **Every DAG has `sla_miss_callback`** — SLA misses are treated as incidents
- [ ] **Every critical task has `sla` set** — not just the DAG-level SLA
- [ ] **Retries use exponential backoff** — not uniform `retry_delay`
- [ ] **Dead-letter pattern implemented** for pipelines with no safe retry
- [ ] **`on_failure_callback` routes to right owner** — not a generic "data-eng" group
- [ ] **Failure events written to audit table** — queryable for SLO reporting

## Category 4: Idempotency & Backfill

- [ ] **Every task is idempotent** — re-running on same `logical_date` is safe
- [ ] **`logical_date` used for partition targeting** — not `datetime.now()`
- [ ] **Backfill behavior documented** — what happens if 30 days of runs are triggered?
- [ ] **`max_active_runs` prevents thundering herd** on backfill
- [ ] **MERGE/upsert or partition-replace used** — never append-only to production tables
- [ ] **Incremental loads have partition existence guard** — no re-processing old data unexpectedly

## Category 5: Resource Management

- [ ] **Pools assigned to every resource-bounded task** — Spark jobs, DB queries, API calls
- [ ] **Pool slot limits sized for actual infrastructure** — not just defaults
- [ ] **Priority weights set for business-critical pipelines** — revenue > analytics
- [ ] **Worker queue routing configured** for heavy tasks (KubernetesExecutor pod config or Celery queues)
- [ ] **`execution_timeout` set on long-running tasks** — no zombie tasks

## Category 6: Security & Configuration

- [ ] **No secrets in DAG code** — all via Airflow Connections + Variables
- [ ] **Environment-parameterized** — same DAG code deploys to dev/staging/prod
- [ ] **Connections use encrypted backend** — not plain-text Airflow DB Variables
- [ ] **No hardcoded table names or paths** — all via Variables or Jinja templates
- [ ] **DAG code in version control** — with PR review required for production changes

## Category 7: Observability

- [ ] **SLO dashboard exists** — success rate + P95 duration visible to stakeholders
- [ ] **Structured failure events emitted** — queryable, not just email
- [ ] **Pipeline metrics tracked** — rows processed, duration, quarantine count
- [ ] **SLA breach history queryable** — from `sla_miss` table or external metrics store
- [ ] **Runbook linked in `doc_md`** — on-call engineer knows what to do at 2am

## Category 8: ML Retraining (if applicable)

- [ ] **Retraining is NOT cron-only** — at least one condition-based trigger implemented
- [ ] **Volume threshold sensor implemented** — retrain when N new rows available
- [ ] **Drift detection integrated** — PSI or KS test on feature distributions
- [ ] **Model performance degradation trigger** — retrain when F1 drops X%
- [ ] **Validation gate before promotion** — candidate must beat champion (within tolerance)
- [ ] **Champion/challenger pattern used** — no auto-promote without comparison
- [ ] **`max_active_runs=1` on retraining DAG** — never train two models simultaneously
- [ ] **Retraining run audit trail** — which condition triggered, metrics logged

## Category 9: Evolvability & Governance

- [ ] **Owner declared in `default_args`** — no orphaned DAGs
- [ ] **DAG version tracked** — in metadata or filename convention
- [ ] **Deprecation pattern defined** — how to retire a DAG without losing run history
- [ ] **DAG change requires PR review** — no direct commits to production DAG folder
- [ ] **Staging environment validates DAG changes** before production deploy
- [ ] **Auto-documentation generated** from DAG metadata (data catalog sync)

---

## Scoring

| Score | Interpretation |
|---|---|
| 40/40 | Production-ready. Ship it. |
| 32–39 | Solid foundation. Document gaps as tracked tech debt with owners and dates. |
| 22–31 | Significant gaps. Not safe for business-critical pipelines without remediation. |
| < 22  | Prototype only. Requires a design review before production. |

---

## The "Day 90 Failure Modes" for Orchestration

1. **Sensor timeout not set → zombie sensors accumulate** — Worker pool fills with sensors waiting forever. Fix: Always `timeout` on sensors.

2. **Cron racing upstream → empty partition processing** — Cron fires at 06:00, source data lands at 06:15. Pipeline runs on yesterday's data. Fix: Sensors for cross-team dependencies.

3. **XCom payload grows → metadata DB OOM** — Someone stores a 100MB DataFrame in XCom. Fix: XCom for control signals only; data in S3.

4. **Backfill thundering herd → scheduler crashes** — Team requests 6-month backfill. 180 concurrent runs. Fix: `max_active_runs=1` + phased backfill.

5. **ML retraining never fires → silent model decay** — Condition-based trigger was planned but never implemented. Cron fallback doesn't exist. Fix: Retraining conditions in initial design scope.

6. **Pool starvation → critical pipelines blocked by analytics jobs** — Heavy analytics tasks fill the spark_pool, revenue pipeline queues for 3 hours. Fix: Dedicated pools + priority weights.

7. **Owner field = "airflow" → orphaned DAGs** — Original author left. Nobody responds to alerts. Fix: Mandatory owner validation in CI.

8. **No `execution_timeout` → zombie tasks** — A Spark job hangs but never fails. Worker slot occupied for 12 hours. Fix: Always set `execution_timeout` on long tasks.