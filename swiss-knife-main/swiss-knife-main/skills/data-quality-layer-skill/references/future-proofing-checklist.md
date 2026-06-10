# Future-Proofing Checklist

Run this checklist before declaring any Quality Layer implementation "done."
A senior engineer should be able to answer YES to every item, or explicitly document WHY a NO is acceptable.

---

## Category 1: Evolvability

- [ ] **Adaptive thresholds** — No hard-coded absolute numbers without a documented review cadence. Statistical checks use rolling baselines or % deviation, not fixed bounds.
- [ ] **Config over code** — Check definitions live in YAML/config files, not scattered across SQL strings or notebook cells.
- [ ] **Versioned checks** — Every check has a `version` field. Breaking changes bump the major version.
- [ ] **Owner assigned** — Every check has a `owner` (team or email). No orphaned checks.
- [ ] **Review cadence** — Each check has a `next_review_date` or is linked to a quarterly review process.
- [ ] **Schema evolution policy** — Explicitly documented: backward compatible? forward compatible? breaking changes require what?

## Category 2: Observability

- [ ] **Structured failure events** — Failures emit JSON with `check_id`, `asset`, `severity`, `fail_count`, `total_rows`, `run_id`, `detected_at`. Not just a log line.
- [ ] **Severity is declared and correct** — Every check has BLOCKING / WARNING / INFO. BLOCKING is used sparingly (< 20% of checks).
- [ ] **Alert routing is configured** — BLOCKING → PagerDuty or equivalent. WARNING → Slack channel. Tested with a synthetic failure.
- [ ] **Quality SLO dashboard exists** — % checks passing over 7/30/90 days is visible to stakeholders.
- [ ] **Run history is persisted** — `dq.quality_runs` or equivalent table exists and is queryable.

## Category 3: Quarantine & Remediation

- [ ] **No silent data loss** — Every bad row goes to a quarantine table, never silently dropped.
- [ ] **Quarantine schema is documented** — Downstream teams know it exists and can query it.
- [ ] **Remediation SOP exists** — Written procedure for "what to do when check X fails." Not just "notify owner."
- [ ] **Quarantine retention policy** — How long are quarantine records kept? Is there a cleanup job?

## Category 4: Testability

- [ ] **Adversarial fixtures exist** — At least one test dataset designed to FAIL each check. If you can't make a check fail, it's probably broken.
- [ ] **Checks run in CI** — Quality checks are part of the PR/merge pipeline, not just production.
- [ ] **Idempotency tested** — Running the pipeline twice on the same data produces the same quarantine output (no duplicates).
- [ ] **Empty dataset handled** — What happens when the source table is empty? BLOCKING or graceful skip?

## Category 5: Coverage

- [ ] **All 10 dimensions covered or explicitly waived** — For each dimension, either there is a check or there is a documented decision not to cover it.
- [ ] **Checks at every pipeline layer** — Ingestion → Staging → Mart → Serving. Not just at the source.
- [ ] **Cross-table checks included** — Referential integrity between related datasets is validated.
- [ ] **Freshness SLA defined and enforced** — Every table has an agreed maximum staleness. The check enforces it.

## Category 6: Governance & Lineage

- [ ] **Lineage is tagged** — Every check references the asset catalog ID or logical name of the table it covers.
- [ ] **Blast-radius is knowable** — Given a failing check, you can determine which downstream assets are affected within 5 minutes.
- [ ] **Data contract exists (for cross-team assets)** — Producer and consumer have a signed contract. See `data-contract-template.md`.
- [ ] **Checks are in version control** — Alongside the pipeline they protect, in the same repo.
- [ ] **Changes require review** — Check changes go through a PR process with data owner approval.

## Category 7: Operational Readiness

- [ ] **On-call runbook exists** — What does the on-call engineer do at 2am when a BLOCKING check fires?
- [ ] **False positive rate is acceptable** — Checks have been live for at least one business cycle without noisy false positives.
- [ ] **Performance impact measured** — Quality checks don't add > 20% to pipeline runtime without justification.
- [ ] **Backfill / historical reprocessing handled** — Does the quality layer behave correctly during historical backfills? (Don't fire stale freshness alerts on 2-year-old data being reprocessed.)

---

## Scoring

| Score | Interpretation |
|---|---|
| 28/28 | Production-ready. Ship it. |
| 22–27 | Solid. Document the gaps as known tech debt with owners. |
| 15–21 | Significant gaps. Don't call this production-grade yet. |
| < 15  | Prototype only. Not safe for business-critical pipelines. |

---

## Common "Day 90" Failure Modes

These are the things that look fine at launch but fail 3 months later:

1. **Seasonal volume spikes break fixed-range checks** — e.g., Black Friday doubles order volume → BLOCKING volume check fires unnecessarily → on-call pages → trust erodes → team disables checks.
   *Fix*: Use rolling baseline + % deviation, not absolute bounds.

2. **Owner left the company, check orphaned** — check fires, no one knows who to page, no one fixes it, it gets silently disabled.
   *Fix*: Mandatory owner field + quarterly ownership review process.

3. **Schema added upstream, not in contract** — new column arrives, downstream transformer breaks, no one was notified.
   *Fix*: Schema registry with change notification + backward-compatibility enforcement.

4. **Check covers dev environment only** — tests pass in dev, prod silently uses different logic.
   *Fix*: CI runs against production-mirrored sample data, not dev fixtures.

5. **Quarantine table never read** — bad data accumulates, compliance risk grows, nobody built a dashboard for it.
   *Fix*: Quarantine table linked in data catalog, weekly summary email to data leads.

6. **"Warning" fatigue** — too many WARNING checks fire too often → team stops looking → a real problem gets missed.
   *Fix*: Keep WARNING count low and actionable. Regularly prune low-signal warnings.