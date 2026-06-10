---
name: ETL & Treasury Data Hub Management
description: Instructions for building, maintaining, and debugging the Treasury Data Hub ETL pipelines (Extraction, Transformation, Loading).
---

# ETL & Treasury Data Hub Skill

This skill defines the standard procedures for managing data flow within the Treasury Management System (SGT). The Treasury Data Hub acts as the **Single Source of Truth**, aggregating data from Accounting (Grand Livre), Payments, Trading, BRVM Apis and Bank Statements.

## 1. Architecture Overview (The "Why")

The Data Hub is a logical layer that:
1.  **Ingests** raw data from multiple sources.
2.  **Cleans & Standardizes** it into a common format.
3.  **Enriches** it with business logic (tagging, classification).
4.  **Stores** it in an optimized Star Schema for analysis and AI modeling.

**Goal**: Ensure perfect consistency between Accounting (GL) and Cash reality (Bank Statements).

## 2. Data Pipeline Stages

When implementing or debugging ETL jobs, follow this strict pipeline:

### Phase 1: Ingestion
- Support both **Batch** (e.g., end-of-day GL exports) and **Real-time** (e.g., API calls for market data) flows.
- **Rule**: Never modify data at the ingestion point. Store raw data if possible for audit trails.
- **Connectors**: Use standardized APIs/Connectors for Accounting, SWIFT/CAMT, and Trading systems.

### Phase 2: Cleaning & Standardization
- **Deduplication**: Check transaction IDs and timestamps to prevent double-counting.
- **Normalization**:
    - **Currency**: Convert all codes to ISO 4217 (e.g., 'CFA' -> 'XOF').
    - **Dates**: Standardize to ISO 8601 (YYYY-MM-DDTHH:mm:ssZ).
    - **Counterparties**: Map various spellings to a unique Legal Entity Identifier (LEI) or internal ID.
- **Validation**:
    - Ensure FX deals have two legs (Buy/Sell).
    - Verify that debits/credits balance where appropriate.

### Phase 3: Business Enrichment
- **Classification**: Tag every transaction with a flow type:
    - `OPERATIONAL`: Supplier payments, salary, collections.
    - `INVESTMENT`: Capex, securities.
    - `FINANCING`: Loans, debt repayment, equity.
- **Linkage**: Attempt to link actual payments to previously generated forecasts/commitments.
- **Metadata**: Add timestamps for "valid_from" and "valid_to" to support time-travel queries.

## 3. Storage Model (Star Schema)

When designing tables, adhere to this schema:

### Fact Tables (Transactions/Events)
- `fact_transactions`: Individual cash flows.
- `fact_balances`: Daily account balances.
- `fact_market_values`: MTM valuations of derivatives.

### Dimension Tables (Context)
- `dim_time`: Dates, fiscal periods, holidays.
- `dim_counterparty`: Client/Supplier details, risk ratings.
- `dim_instrument`: Financial instrument specs (bonds, swaps).
- `dim_currency`: Exchange rates, currency details.
- `dim_legal_entity`: Internal bank entities/subsidiaries.

## 4. Verification & Quality Checks

Before marking an ETL task as complete, run these checks:
1.  **Reconciliation**: Does `Sum(GL Transaction)` +/- `Adjustments` == `Bank Statement Balance`?
2.  **Completeness**: Are there any "Unknown" counterparties or "Unclassified" flow types?
3.  **Freshness**: Is the data up-to-date with the latest batch?

## 5. Common Issues & Debugging
- **Mismatch GL/Bank**: Often caused by timing differences (Float). Check value dates vs booking dates.
- **Duplicate Flows**: Check if a retry mechanism re-sent a valid message.
- **Currency Conversion**: Ensure the FX rate being used matches the transaction date, not the settlement date.
