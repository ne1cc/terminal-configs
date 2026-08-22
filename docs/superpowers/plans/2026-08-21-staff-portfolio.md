# Staff-Level Portfolio & Executive Deliverables Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the complete Staff-Level Portfolio & Executive Meets/Exceeds Expectations package across ADRs, SQL marts, verification contracts, and a zero-dependency interactive executive dashboard.

**Architecture:** Implement three architectural decision records in `docs/adr/`, create financial reconciliation and data quality SLA dbt models with YAML schema tests in `models/marts/`, and build a standalone dark-mode interactive HTML/CSS/JS dashboard in `docs/dashboard.html`.

**Tech Stack:** dbt-duckdb, DuckDB SQL, HTML5 / CSS3 / Vanilla JS with embedded SVG charting, Markdown ADRs.

**Spec:** `docs/superpowers/specs/2026-08-21-staff-portfolio-design.md`

## Global Constraints

- Zero external JS/CSS runtime CDN dependencies for `docs/dashboard.html` (fully self-contained, offline-capable).
- DuckDB ANSI SQL compatibility with idempotent logic.
- All dbt models must have strict column descriptions and schema assertions in `models/marts/_marts.yml`.

---

### Task 1: Architecture Decision Records (ADRs)

**Files:**
- Create: `docs/adr/0001-why-local-first-duckdb.md`
- Create: `docs/adr/0002-quarantine-firebreak-vs-hard-crash.md`
- Create: `docs/adr/0003-idempotent-merge-lookback-windows.md`

**Interfaces:**
- Consumes: Architectural decisions outlined in the design spec.
- Produces: Version-controlled documentation under `docs/adr/`.

- [ ] **Step 1: Write `docs/adr/0001-why-local-first-duckdb.md`**
- [ ] **Step 2: Write `docs/adr/0002-quarantine-firebreak-vs-hard-crash.md`**
- [ ] **Step 3: Write `docs/adr/0003-idempotent-merge-lookback-windows.md`**
- [ ] **Step 4: Commit ADR files**

---

### Task 2: Financial Reconciliation Mart & Tests

**Files:**
- Create: `models/marts/mart_marketplace_financial_reconciliation.sql`
- Modify: `models/marts/_marts.yml`

**Interfaces:**
- Consumes: Staging/intermediate order, item, and payment models.
- Produces: `mart_marketplace_financial_reconciliation` (grain: `order_id`).

- [ ] **Step 1: Write `mart_marketplace_financial_reconciliation.sql`**
- [ ] **Step 2: Update `models/marts/_marts.yml` with schema contracts and tests**
- [ ] **Step 3: Run `dbt build --select mart_marketplace_financial_reconciliation`**
- [ ] **Step 4: Commit financial reconciliation model and docs**

---

### Task 3: Data Quality SLA Mart & Tests

**Files:**
- Create: `models/marts/mart_data_quality_sla.sql`
- Modify: `models/marts/_marts.yml`

**Interfaces:**
- Consumes: Audit/quarantine logs and staging entities.
- Produces: `mart_data_quality_sla` (grain: `source_name, audit_date`).

- [ ] **Step 1: Write `mart_data_quality_sla.sql`**
- [ ] **Step 2: Update `models/marts/_marts.yml` with SLA column documentation and tests**
- [ ] **Step 3: Run `dbt build --select mart_data_quality_sla`**
- [ ] **Step 4: Commit data quality SLA model and docs**

---

### Task 4: Standalone Interactive Executive Dashboard

**Files:**
- Create: `docs/dashboard.html`

**Interfaces:**
- Consumes: Metrics and aggregates from the marts layer.
- Produces: Standalone, zero-dependency interactive dark-mode dashboard.

- [ ] **Step 1: Write `docs/dashboard.html` with responsive executive styling, SVG visualizations, and tabs (Executive KPIs, Cohort Heatmap, Logistics SLA, Quarantine Observability)**
- [ ] **Step 2: Verify HTML layout, tabs, and SVG charting render without external CDN errors**
- [ ] **Step 3: Commit `docs/dashboard.html`**

---

### Task 5: End-to-End Verification & Artifact Validation

**Files:**
- Test: Full dbt test suite execution and dashboard verification.

- [ ] **Step 1: Run `dbt test` or `dbt build` to ensure 100% test pass rate**
- [ ] **Step 2: Review final artifacts and confirm all deliverables meet Staff-Level criteria**
