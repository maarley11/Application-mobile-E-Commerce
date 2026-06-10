# Data Contract Template

Use this template when a Quality Layer crosses team boundaries (producer → consumer).
A data contract makes quality obligations explicit, versioned, and enforceable.

---

```yaml
# data-contracts/orders/contract_v1.3.0.yaml
# ---------------------------------------------------------
# DATA CONTRACT
# A formal agreement between the producer and consumer of a dataset.
# Changes require sign-off from BOTH parties.
# ---------------------------------------------------------

contract:
  id:          "orders.fct_orders.v1"
  version:     "1.3.0"   # semver: major = breaking, minor = additive, patch = fix
  status:      "ACTIVE"  # ACTIVE | DEPRECATED | DRAFT
  created_at:  "2024-03-01"
  updated_at:  "2024-11-15"
  next_review: "2025-03-01"

# ──────────────────────────────────────────
# PARTIES
# ──────────────────────────────────────────
producer:
  team:        "Payments Data Engineering"
  email:       "payments-data@company.com"
  slack:       "#payments-data-eng"
  on_call:     "PagerDuty service: payments-data"

consumer:
  team:        "Finance Analytics"
  email:       "finance-analytics@company.com"
  slack:       "#finance-analytics"

# ──────────────────────────────────────────
# DATASET
# ──────────────────────────────────────────
dataset:
  logical_name: "Orders Fact Table"
  physical_name: "gold.fct_orders"
  catalog_id:   "asset://data-catalog/gold/fct_orders"
  description:  "One row per completed order. Source of truth for revenue reporting."
  grain:        "order_id (unique per row)"
  update_cadence: "Daily at 06:00 UTC"

# ──────────────────────────────────────────
# SCHEMA CONTRACT
# ──────────────────────────────────────────
schema:
  evolution_policy: "BACKWARD_COMPATIBLE"
  # Options:
  #   BACKWARD_COMPATIBLE: new columns OK, rename/delete requires major version bump
  #   STRICT: no changes without major version bump + consumer sign-off
  #   FLEXIBLE: consumers must handle schema changes gracefully (not recommended for finance)

  columns:
    - name:        order_id
      type:        STRING
      nullable:    false
      description: "Unique order identifier (UUID v4)"
      pii:         false

    - name:        user_id
      type:        STRING
      nullable:    false
      description: "User who placed the order"
      pii:         true
      pii_handling: "direct_identifier — do not join to public-facing datasets"

    - name:        revenue_usd
      type:        DECIMAL(18,4)
      nullable:    false
      description: "Net revenue in USD after discounts and refunds"
      pii:         false
      business_rule: "Must be >= 0. Refunds tracked separately in fct_refunds."

    - name:        created_at
      type:        TIMESTAMP
      nullable:    false
      description: "Order creation time in UTC"
      pii:         false

    - name:        status
      type:        STRING
      nullable:    false
      description: "Order lifecycle status"
      allowed_values: ["PENDING", "CONFIRMED", "SHIPPED", "DELIVERED", "CANCELLED", "REFUNDED"]

# ──────────────────────────────────────────
# QUALITY SLAs (producer's obligations)
# ──────────────────────────────────────────
quality_slas:

  freshness:
    max_lag_hours: 4
    measurement: "MAX(created_at) must be within 4 hours of pipeline trigger time"
    breach_action: "Producer pages on-call and notifies consumer Slack channel"

  completeness:
    min_row_count_daily: 50000
    max_null_pct:
      order_id:    0.0   # zero tolerance
      user_id:     0.0
      revenue_usd: 0.0
      created_at:  0.0
      status:      0.1   # up to 0.1% null tolerated (legacy orders)

  uniqueness:
    primary_key: [order_id]
    duplicate_tolerance: 0   # zero duplicates

  validity:
    revenue_usd_min: 0
    status_in_allowed_values: true

  availability:
    target_uptime_pct: 99.5   # per 30-day rolling window
    planned_downtime_notice_hours: 48

# ──────────────────────────────────────────
# INCIDENT RESPONSE
# ──────────────────────────────────────────
incident_response:
  breach_notification_sla_minutes: 30   # producer notifies consumer within 30 min of breach
  remediation_sla_hours: 4              # breach remediated within 4 hours
  escalation_path:
    - "Producer on-call (PagerDuty)"
    - "Producer data lead"
    - "VP Engineering (if SLA breach > 4h)"
  post_mortem_required: true            # for any BLOCKING breach

# ──────────────────────────────────────────
# CHANGE MANAGEMENT
# ──────────────────────────────────────────
change_management:
  breaking_change_notice_days: 30
  non_breaking_change_notice_days: 7
  change_approval:
    - "Producer team lead"
    - "Consumer team lead"
  change_log:
    - version: "1.3.0"
      date: "2024-11-15"
      type: "NON_BREAKING"
      description: "Added `status` column with allowed_values constraint"
    - version: "1.2.0"
      date: "2024-08-01"
      type: "NON_BREAKING"
      description: "Added freshness SLA (was implicit, now contractual)"
    - version: "1.0.0"
      date: "2024-03-01"
      type: "INITIAL"
      description: "Initial contract between Payments and Finance"

# ──────────────────────────────────────────
# SIGNATURES (required for ACTIVE status)
# ──────────────────────────────────────────
signatures:
  producer:
    name:   "Jane Smith"
    role:   "Staff Data Engineer, Payments"
    date:   "2024-11-15"
  consumer:
    name:   "Carlos Reyes"
    role:   "Analytics Engineering Lead, Finance"
    date:   "2024-11-16"
```

---

## How to Use This Template

1. **Copy** this file to `data-contracts/<domain>/contract_<logical_name>_v<version>.yaml`
2. **Fill in** all fields — do not leave defaults for production contracts
3. **Get signatures** from both producer and consumer leads
4. **Version control** alongside the pipeline (same repo, same PR process)
5. **Register** in your data catalog under the dataset's asset entry
6. **Wire up enforcement** — the Quality Layer should validate against this contract automatically

### Enforcement Integration (dbt example)
```yaml
# Reference the contract version in your dbt schema.yml
models:
  - name: fct_orders
    meta:
      data_contract: "orders.fct_orders.v1"
      data_contract_version: "1.3.0"
```

### Enforcement Integration (Python example)
```python
# Load and validate against the contract
import yaml

with open("data-contracts/orders/contract_v1.3.0.yaml") as f:
    contract = yaml.safe_load(f)

# Extract quality SLAs and generate checks automatically
for col, max_null_pct in contract["quality_slas"]["completeness"]["max_null_pct"].items():
    print(f"Generating null rate check for {col}: max {max_null_pct}%")
```