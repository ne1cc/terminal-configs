# Architecture

## Design Philosophy

This pipeline follows Dagster's **Software-Defined Asset (SDA)** paradigm. Instead of sequencing opaque tasks (Airflow-style), every table and analytical output is a first-class declarative asset with tracked lineage, freshness policies, and attached metadata.

## System Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        Dagster Orchestrator                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐    ┌──────────────────────────────────┐   │
│  │  ingestion group │    │         dbt group                │   │
│  │                  │    │                                  │   │
│  │ raw_experiment_  │───▶│  stg_experiment_users (view)     │   │
│  │ events           │    │         │                        │   │
│  │ (python)         │    │         ▼                        │   │
│  └──────────────────┘    │  fct_experiment_users (table)    │   │
│                          └──────────────┬───────────────────┘   │
│                                         │                       │
│                          ┌──────────────▼───────────────────┐   │
│                          │       analytics group            │   │
│                          │                                  │   │
│                          │  ab_test_summary_metrics         │   │
│                          │  (python — CUPED + SRM)          │   │
│                          └──────────────────────────────────┘   │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                     DuckDB  (dev.duckdb)                         │
└─────────────────────────────────────────────────────────────────┘
```

## Asset Graph

| Asset | Group | Compute Kind | Materialization |
|-------|-------|--------------|-----------------|
| `raw_experiment_events` | ingestion | python | DuckDB table `stg_raw_events` |
| `stg_experiment_users` | dbt | dbt | DuckDB view |
| `fct_experiment_users` | dbt | dbt | DuckDB table |
| `ab_test_summary_metrics` | analytics | python | Metadata-only (no table) |

## Data Flow

1. **Ingestion** — Python generates 50k synthetic users with variant assignment and pre-experiment covariates, writes to `stg_raw_events`.
2. **Staging** — dbt view selects and validates raw columns.
3. **Marts** — dbt table enriches with `is_treatment` flag for downstream consumers.
4. **Analytics** — Python reads the mart, performs SRM chi-square check, applies CUPED variance reduction, runs Welch's t-test, and logs all statistics as Dagster output metadata.

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| DuckDB over Postgres | Zero-infrastructure; entire pipeline runs from a laptop clone |
| `CREATE OR REPLACE TABLE` | Idempotent re-materialization without manual cleanup |
| CUPED adjustment | Reduces variance ~40% vs. naive t-test, detecting smaller lifts |
| Metadata on asset (not table) | Statistical summaries are ephemeral; Dagster UI is the dashboard |
