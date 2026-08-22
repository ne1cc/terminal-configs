# Design Spec: Staff-Level Portfolio & Executive Meets/Exceeds Expectations Package

**Date:** 2026-08-21  
**Status:** Approved for Implementation Planning  
**Scope:** Architectural (Analytics Engineering, Observability, Executive UX, Engineering Leadership)

---

## 1. Overview & Objectives

Deliver a comprehensive, production-grade Staff Analytics Engineer portfolio package demonstrating both technical rigor (idempotent modeling, data quality SLAs, financial reconciliation) and strategic leadership (ADRs, executive dashboards, zero-dependency artifacts).

### Key Deliverables:
1. **Interactive Executive & Operations Dashboard (`docs/dashboard.html`)**
2. **Architecture Decision Records (`docs/adr/0001..0003`)**
3. **Financial Reconciliation Mart (`models/marts/mart_marketplace_financial_reconciliation.sql`)**
4. **Data Quality SLA Mart (`models/marts/mart_data_quality_sla.sql`)**
5. **Schema Contracts & Verification Suite (`models/marts/_marts.yml`)**

---

## 2. Architecture & Data Flow

```
[Raw Ingestion / Bronze Parquet]
       │
       ▼
[Staging / Silver Layer] ──► Quarantine / Dead-Letter (Corrupt Records)
       │
       ▼
[Gold Marts Layer]
  ├─ mart_marketplace_financial_reconciliation (Grain: order_id)
  └─ mart_data_quality_sla (Grain: source_name, audit_date)
       │
       ▼
[Verification Suite (dbt tests & schema contracts)]
       │
       ▼
[Executive & Ops Dashboard (docs/dashboard.html)]
```

---

## 3. Detailed Component Specifications

### 3.1 Executive & Operations Dashboard (`docs/dashboard.html`)
- **Format:** Standalone, zero-external-dependency HTML/CSS/JS file.
- **Visuals:** Dark-mode executive styling, responsive layout, embedded interactive SVG/Canvas charts.
- **Views/Tabs:**
  1. **Executive KPI Overview:** GMV, order volume, repeat buyer rate, average order value (AOV), freight margin.
  2. **Customer Cohort Retention Matrix:** $M_0 \to M_{12}$ heatmap with retention drop-off insights.
  3. **Logistics SLA & Corridor Matrix:** On-time delivery % vs. delay % by Brazilian state corridor; review score correlation.
  4. **Data Observability & Quarantine Audit:** Pipeline test pass rate (162/162), schema drift count, dead-letter quarantine reasons.

### 3.2 Architecture Decision Records (`docs/adr/`)
- **`0001-why-local-first-duckdb.md`**:
  - Context & Problem Statement: CI compute cost and latency for analytical verification.
  - Decision: DuckDB + Parquet local-first storage with ANSI SQL portability.
  - Consequences & Trade-offs: Zero-cost CI, instant local developer feedback loop, scaling boundaries.
- **`0002-quarantine-firebreak-vs-hard-crash.md`**:
  - Context & Problem Statement: Handling schema drift and malformed raw data at scale.
  - Decision: Dead-letter isolation with execution metadata rather than pipeline crashes or silent coercion.
  - Consequences & Trade-offs: Continuous pipeline throughput, transparent quarantine audits, isolation maintenance.
- **`0003-idempotent-merge-lookback-windows.md`**:
  - Context & Problem Statement: Late-arriving events in batch processing.
  - Decision: 2-day late-arrival event-time lookback window with idempotent merge/upsert keys.
  - Consequences & Trade-offs: Predictable runtimes, duplicate protection, backfill determinism.

### 3.3 Marts & Data Models

#### `mart_marketplace_financial_reconciliation.sql`
- **Grain:** One row per `order_id`.
- **Logic:** Reconciles order payment total against item price sum, freight value, voucher subsidies, and installment fees.
- **Output Columns:**
  - `order_id` (PK)
  - `total_payment_value`
  - `merchandise_item_value`
  - `freight_value`
  - `voucher_discount_value`
  - `net_reconciled_variance`
  - `is_balanced` (boolean)

#### `mart_data_quality_sla.sql`
- **Grain:** One row per `(source_name, audit_date)`.
- **Logic:** Tracks ingested record volume, quarantine count, schema anomalies, and computes data quality SLA percentage.
- **Output Columns:**
  - `source_name`
  - `audit_date`
  - `total_records_processed`
  - `valid_records_loaded`
  - `quarantine_records_count`
  - `data_quality_pass_rate_pct`
  - `schema_drift_warning_count`

### 3.4 Verification & Schema Contracts (`models/marts/_marts.yml`)
- Strict column types, descriptions, tests (`not_null`, `unique`, `accepted_values`, expressions verifying `is_balanced` consistency).

---

## 4. Implementation Steps
1. Create ADR documents in `docs/adr/`.
2. Implement dbt SQL models for financial reconciliation and data quality SLA.
3. Update YAML contract files with full column documentation and tests.
4. Build `docs/dashboard.html` with mock/compiled analytical datasets.
5. Verify dbt models compile and execute cleanly.
