# Domain Principles — Data Quality Layer

## The Foundational Insight

A Quality Layer fails not because engineers don't care, but because it's treated as a **feature** instead of an **architectural contract**. The best data teams at scale treat data quality like production software engineers treat uptime: with SLOs, on-call rotations, incident response, and blameless post-mortems.

---

## Design Philosophy

### 1. Shift Left, Then Shift Right
- **Shift Left**: Validate at the earliest possible point (schema at ingest, not 3 hops downstream)
- **Shift Right**: Monitor production outputs continuously — checks in CI are necessary but not sufficient
- Real pipelines need both: proactive (pre-merge) + reactive (post-deploy monitoring)

### 2. Pyramid of Quality Checks

```
           ┌─────────────────────┐
           │  Business Logic     │  ← Fewest, most complex, owned by domain team
           ├─────────────────────┤
           │  Cross-Table Rules  │  ← Referential, temporal, consistency
           ├─────────────────────┤
           │  Statistical Rules  │  ← Volume, distribution, anomaly
           ├─────────────────────┤
           │  Structural Rules   │  ← Schema, types, nullability
           └─────────────────────┘
                  ← Many, cheap, automated
```

Run bottom-up on every pipeline trigger. Never run business logic checks if structural checks fail — it's expensive and the failures will be misleading.

### 3. Severity Is a First-Class Citizen

Every check must declare its blast radius:

| Severity   | Definition                                  | Pipeline Action     | Alert Destination         |
|------------|---------------------------------------------|---------------------|---------------------------|
| BLOCKING   | Downstream breakage is guaranteed           | HALT pipeline       | PagerDuty / on-call       |
| WARNING    | Quality degraded, may affect consumers      | Continue + alert    | Slack data-quality channel|
| INFO       | Informational drift, no immediate risk      | Continue + log      | Dashboard only            |

**Never default to BLOCKING.** Over-blocking trains teams to ignore alerts.

### 4. Checks Are Code, Not Config Comments

Every check must be:
- Version-controlled alongside the pipeline it protects
- Peer-reviewed before reaching production (data PR review)
- Tested with fixture data before merge
- Auto-documented from its metadata

### 5. The "Day 2 Problem"

Most quality layers look great on Day 1. They fail on Day 2 because:
- Business logic changes but checks don't
- Data volume grows and hard-coded thresholds become irrelevant
- New columns arrive unannounced and break downstream consumers
- Team members leave and no one knows who owns a check

**Mitigations:**
- Adaptive thresholds (% deviation from rolling baseline, not fixed numbers)
- Schema contracts with explicit backward-compatibility policy
- `owner` field mandatory on every check
- Automated check coverage reports in data catalog

---

## Architectural Patterns

### Pattern A: Inline Quality Gate
```
Source → [Quality Gate] → Transform → Serve
```
Simplest. Quality runs as a stage in the pipeline DAG. Good for batch pipelines.
Weakness: If the gate is slow, it blocks the entire pipeline.

### Pattern B: Parallel Quality Observer
```
Source → Transform → Serve
           ↓
        [Quality Observer]
           ↓
        [Alert / Quarantine]
```
Quality is decoupled from the critical path. Good for streaming or latency-sensitive pipelines.
Weakness: Consumers may see bad data before the observer catches it.

### Pattern C: Data Contract Enforcement
```
Producer → [Contract Validator] → Event Bus → [Consumer]
                  ↓
            [Schema Registry]
```
The contract (schema + rules) is owned and versioned by the producer, enforced at publish time.
Best for multi-team, service-oriented data meshes.
Weakness: Requires organizational adoption, not just tooling.

### Pattern D: Quality-as-a-Sidecar (streaming)
```
Raw Stream → Processor → Output Stream
                ↓
         [Quality Sidecar]   (same consumer group, separate topic)
                ↓
         [quality-events topic]
```
For Kafka/Flink pipelines. Quality checks run on the same data in parallel, emit to a separate quality topic. Dashboards and alerts subscribe to quality-events.

---

## The 10 Dimensions — Deep Dive

### Dimension 1: Schema & Structural Integrity
**What breaks without it**: Silent column rename → downstream joins return nulls → revenue reports wrong.
**Key insight**: Schema checks must cover *structural* AND *semantic* schema (a column named `revenue` that contains `user_id` values passes structural checks but is semantically broken — add value range checks).

### Dimension 2: Statistical / Distribution
**What breaks without it**: A bug zeroes out 5% of revenue rows. Row count is fine. Sum is off by 5%. No one notices for 3 weeks.
**Key insight**: Absolute thresholds fail seasonally. Always use rolling baselines (7-day, 28-day) with % deviation bounds. Use IQR for skewed distributions, not z-score.

### Dimension 3: Referential & Business Integrity
**What breaks without it**: Orders reference deleted users → BI tool crashes on join → dashboard goes dark.
**Key insight**: Cross-table checks are the hardest to maintain because they require awareness of two datasets' update schedules. Always timestamp cross-table checks and document the assumed partition alignment.

### Dimension 4: Freshness & Timeliness
**What breaks without it**: ETL fails silently, downstream dashboard shows yesterday's data with today's date label.
**Key insight**: Freshness SLA must be agreed upon by both producer and consumer. A `_dq_metadata` table with `last_updated`, `expected_partition`, and `rows_loaded` columns is the cheapest observability investment a team can make.

### Dimension 5: Uniqueness & Deduplication
**What breaks without it**: Double-counting revenue. One of the most common and embarrassing data bugs in production.
**Key insight**: Idempotency and deduplication are different problems. Idempotency = re-running the pipeline doesn't add duplicates. Deduplication = the source itself sends duplicates. Both need to be addressed separately.

### Dimension 6: Data Lineage & Impact
**What breaks without it**: A schema change in one table breaks 12 downstream dashboards — nobody knew.
**Key insight**: Lineage is not optional at scale. Every check should reference the asset catalog ID of the table it covers. This enables blast-radius analysis and automated impact notifications.

### Dimension 7: Observability & Alerting
**What breaks without it**: The check fails. Nothing routes. Nobody knows. Consumers file a ticket 3 days later.
**Key insight**: Emit structured failure events, not just log lines. A quality event should carry enough context that an on-call engineer can triage without opening a notebook.

### Dimension 8: Quarantine & Remediation
**What breaks without it**: Bad rows silently dropped → data loss → compliance risk.
**Key insight**: Never delete bad data. Write it to a quarantine table with the reason for rejection. This creates an audit trail and enables retroactive remediation.

### Dimension 9: Testability & CI/CD
**What breaks without it**: A check change ships that always passes (due to a bug). The check was "green" in CI but useless.
**Key insight**: Quality checks must be tested with adversarial fixtures: a dataset specifically designed to fail the check. If you can't write a fixture that makes your check fail, your check is probably not working.

### Dimension 10: Evolvability & Governance
**What breaks without it**: The team that wrote the checks leaves. Six months later, thresholds are stale, owners are wrong, nobody changes anything out of fear.
**Key insight**: Every check needs a mandatory `owner`, `review_date`, and `version`. Automate a monthly report of "checks not reviewed in 90 days" and send it to data leads. Treat stale checks like stale documentation: a liability.