# Observability, Alerting & Operational Patterns

## Table of Contents
1. [Structured Alert Callbacks](#callbacks)
2. [SLA Management](#sla)
3. [Retry & Dead-Letter Patterns](#retry)
4. [Metrics & Dashboard Strategy](#metrics)
5. [On-Call Runbook Template](#runbook)

---

## 1. Structured Alert Callbacks {#callbacks}

Never use Airflow's default email alerts in production. They lose context and can't be routed.

```python
# common/callbacks.py
import logging
from datetime import datetime
from airflow.utils.context import Context

log = logging.getLogger(__name__)


def structured_alert(context: Context):
    """
    on_failure_callback for every production DAG and task.
    Emits structured event → routes to Slack + PagerDuty based on severity.
    """
    dag_id   = context["dag"].dag_id
    task_id  = context["task_instance"].task_id
    run_id   = context["run_id"]
    log_url  = context["task_instance"].log_url
    exception = context.get("exception", "Unknown")
    owner    = context["dag"].default_args.get("owner", "unknown")
    severity = _get_severity(dag_id, task_id)

    event = {
        "type":       "airflow_task_failure",
        "dag_id":     dag_id,
        "task_id":    task_id,
        "run_id":     run_id,
        "owner":      owner,
        "severity":   severity,
        "exception":  str(exception)[:500],
        "log_url":    log_url,
        "failed_at":  datetime.utcnow().isoformat(),
        "env":        _get_env(),
    }

    log.error("TASK_FAILURE", extra=event)    # structured log → log aggregator

    # Route based on severity
    if severity == "CRITICAL":
        _page_oncall(event)
        _send_slack(event, channel="#data-incidents")
    elif severity == "HIGH":
        _send_slack(event, channel="#data-alerts")
    else:
        _send_slack(event, channel="#data-warnings")

    # Always write to audit table
    _write_failure_event(event)


def sla_alert(dag, task_list, blocking_task_list, slas, blocking_tis):
    """
    sla_miss_callback — fires when task exceeds its SLA duration.
    Separate from failure: SLA miss ≠ failure.
    """
    for sla in slas:
        event = {
            "type":    "sla_miss",
            "dag_id":  dag.dag_id,
            "task_id": sla.task_id,
            "owner":   dag.default_args.get("owner", "unknown"),
            "missed_at": datetime.utcnow().isoformat(),
        }
        log.warning("SLA_MISS", extra=event)
        _send_slack(event, channel="#data-sla-misses")


def dag_success_callback(context: Context):
    """
    on_success_callback — emit pipeline completion telemetry.
    Use on critical pipelines to track P95 duration trends.
    """
    dag_id   = context["dag"].dag_id
    duration = (datetime.utcnow() - context["dag_run"].start_date).seconds

    _emit_metric("dag.duration.seconds", duration, tags={"dag_id": dag_id})
    _emit_metric("dag.success.count",    1,        tags={"dag_id": dag_id})


def _get_severity(dag_id: str, task_id: str) -> str:
    """Determine severity from DAG/task tags or naming convention."""
    CRITICAL_DAGS = {"payments__ingestion__hourly", "revenue__transformation__daily"}
    if dag_id in CRITICAL_DAGS:
        return "CRITICAL"
    if "ingestion" in dag_id or "revenue" in dag_id:
        return "HIGH"
    return "MEDIUM"


def _send_slack(event: dict, channel: str):
    import requests, os
    webhook = os.environ.get("SLACK_WEBHOOK_URL")
    if not webhook:
        return
    requests.post(webhook, json={
        "channel": channel,
        "text": (
            f":red_circle: *{event['type'].upper()}*\n"
            f"DAG: `{event['dag_id']}` | Task: `{event.get('task_id', 'N/A')}`\n"
            f"Owner: {event['owner']} | Env: {event.get('env', 'unknown')}\n"
            f"<{event.get('log_url', '#')}|View Logs>"
        ),
    })


def _page_oncall(event: dict):
    """Send PagerDuty alert for CRITICAL failures."""
    import requests, os
    requests.post("https://events.pagerduty.com/v2/enqueue", json={
        "routing_key": os.environ["PAGERDUTY_INTEGRATION_KEY"],
        "event_action": "trigger",
        "payload": {
            "summary":  f"Airflow CRITICAL: {event['dag_id']} / {event['task_id']}",
            "severity": "critical",
            "source":   "airflow",
            "custom_details": event,
        },
    })


def _emit_metric(name: str, value: float, tags: dict):
    """Emit to DataDog / Prometheus / StatsD."""
    pass  # implement for your stack


def _write_failure_event(event: dict):
    """Persist failure event to audit table for SLO reporting."""
    pass  # write to dq.airflow_failure_events


def _get_env() -> str:
    from airflow.models import Variable
    return Variable.get("environment", default_var="unknown")
```

---

## 2. SLA Management {#sla}

### SLA Definition Pattern
```python
# Define SLAs based on business impact, not technical convenience
SLA_MAP = {
    # Format: dag_id: (task_id, SLA_timedelta)
    # Ingestion layer — revenue pipeline must land within 30 min
    "payments__ingestion__hourly": {
        "extract_orders_to_s3": timedelta(minutes=20),
        "validate_extract":     timedelta(minutes=30),
    },
    # Transformation — dashboards refresh by 07:00
    "payments__transformation__daily": {
        "run_dbt_models":       timedelta(hours=5),   # starts at 02:00, must finish by 07:00
    },
    # ML Retraining — new model in serving within 6 hours of trigger
    "ml__orders_model__retraining": {
        "promote_to_champion":  timedelta(hours=6),
    },
}

# Apply in task definition
def make_task_with_sla(task_id, dag_id, callable_, sla_map=SLA_MAP):
    sla = sla_map.get(dag_id, {}).get(task_id)
    return PythonOperator(
        task_id         = task_id,
        python_callable = callable_,
        sla             = sla,
    )
```

### SLO Dashboard Queries (SQL)
```sql
-- 7-day DAG success rate by pipeline
SELECT
    dag_id,
    COUNT(*)                                          AS total_runs,
    SUM(CASE WHEN state = 'success' THEN 1 ELSE 0 END) AS successful_runs,
    ROUND(100.0 * SUM(CASE WHEN state = 'success' THEN 1 ELSE 0 END) / COUNT(*), 2) AS success_rate_pct,
    ROUND(AVG(EXTRACT(EPOCH FROM (end_date - start_date)) / 60), 1) AS avg_duration_min,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (end_date - start_date)) / 60), 1) AS p95_duration_min
FROM dag_run
WHERE start_date >= CURRENT_DATE - INTERVAL '7 days'
  AND state IN ('success', 'failed')
GROUP BY dag_id
ORDER BY success_rate_pct ASC;

-- SLA miss frequency by task
SELECT
    dag_id,
    task_id,
    COUNT(*) AS sla_miss_count,
    MAX(timestamp) AS last_miss
FROM sla_miss
WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY dag_id, task_id
ORDER BY sla_miss_count DESC;
```

---

## 3. Retry & Dead-Letter Patterns {#retry}

### Exponential Backoff Configuration
```python
# Never use uniform retry delays in production
RETRY_CONFIG = {
    # Fast-failing transient errors (network, API rate limits)
    "fast_retry": {
        "retries":                   5,
        "retry_delay":               timedelta(seconds=30),
        "retry_exponential_backoff": True,
        "max_retry_delay":           timedelta(minutes=30),
    },
    # Slow-failing infrastructure issues (DB overloaded, Spark unavailable)
    "slow_retry": {
        "retries":                   3,
        "retry_delay":               timedelta(minutes=5),
        "retry_exponential_backoff": True,
        "max_retry_delay":           timedelta(hours=1),
    },
    # Critical pipelines — retry aggressively, alert immediately
    "critical": {
        "retries":                   3,
        "retry_delay":               timedelta(minutes=2),
        "retry_exponential_backoff": True,
        "max_retry_delay":           timedelta(minutes=20),
        "on_retry_callback":         structured_alert,   # alert on EVERY retry
    },
}
```

### Dead-Letter Pattern for Task Failures
```python
# common/dead_letter.py

@task()
def write_to_dead_letter(context_info: dict, ds=None):
    """
    Called when a task exhausts all retries.
    Writes structured failure record for manual remediation.
    """
    import json
    from datetime import datetime

    record = {
        "dag_id":      context_info["dag_id"],
        "task_id":     context_info["task_id"],
        "run_id":      context_info["run_id"],
        "logical_date": ds,
        "failed_at":   datetime.utcnow().isoformat(),
        "exception":   context_info.get("exception"),
        "retry_count": context_info.get("try_number"),
        "status":      "AWAITING_MANUAL_REMEDIATION",
    }

    # Write to dead-letter table
    engine.execute(
        "INSERT INTO orchestration.dead_letter_queue VALUES (:record)",
        record=json.dumps(record),
    )

    # Alert with runbook link
    send_alert(
        title    = f"Dead Letter: {record['dag_id']}/{record['task_id']}",
        details  = record,
        runbook  = f"https://wiki.company.com/runbooks/{record['dag_id']}",
        severity = "HIGH",
    )
```

---

## 4. Metrics & Dashboard Strategy {#metrics}

### Metrics to Track for Every Pipeline
```python
# Emit these metrics from every DAG for the SLO dashboard
PIPELINE_METRICS = [
    # Availability
    "dag.success.count",          # increment on DAG success
    "dag.failure.count",          # increment on DAG failure
    "dag.sla_miss.count",         # increment on SLA miss

    # Performance
    "dag.duration.seconds",       # wall-clock time of full DAG run
    "task.duration.seconds",      # per-task wall-clock time

    # Data quality signal
    "pipeline.rows_processed",    # volume signal
    "pipeline.rows_quarantined",  # quality signal

    # ML-specific
    "model.retrain.trigger_reason",  # which condition fired
    "model.candidate.f1",            # candidate model quality
    "model.champion.f1",             # champion baseline
    "model.promotion.count",         # successful promotions
]
```

---

## 5. On-Call Runbook Template {#runbook}

Every production DAG must have a runbook linked in `doc_md`. Template:

```markdown
# Runbook: {dag_id}

## Purpose
One sentence: what does this DAG do and why does it matter.

## SLA
- Full DAG completion: within X hours of trigger
- Critical path task `{task_id}`: within Y minutes

## Common Failure Modes

### `extract_orders_to_s3` fails
**Likely cause**: Postgres connection timeout or DB overloaded.
**Check**: Run `SELECT count(*) FROM pg_stat_activity WHERE state = 'active'` on source DB.
**Fix**: Wait 10 minutes and clear + rerun the task. If persists, page DB team.

### `wait_for_minimum_volume` times out
**Likely cause**: Upstream source didn't deliver expected data volume.
**Check**: `SELECT count(*) FROM raw.orders WHERE date = '{ds}'`
**Fix**: Check with source team. If intentional (e.g., holiday), mark task success manually.

### `run_dbt_models` fails
**Likely cause**: dbt model compilation error or warehouse timeout.
**Check**: View dbt logs in task log output.
**Fix**: Run `dbt compile` locally against staging. If warehouse timeout, rerun during off-peak.

## Manual Rerun Instructions
1. Clear failed task in Airflow UI (Task Instance > Clear)
2. Confirm upstream is ready (check sensor conditions manually)
3. Trigger rerun from UI or: `airflow tasks run {dag_id} {task_id} {logical_date}`

## Escalation
- Level 1 (task retry): automated
- Level 2 (SLA miss): Slack #data-alerts + on-call Slack DM
- Level 3 (> 2x SLA miss or CRITICAL failure): PagerDuty page
- Level 4 (> 4h unresolved): Escalate to data platform lead

## Related DAGs
- Upstream: {upstream_dag_id}
- Downstream: {downstream_dag_id}
```