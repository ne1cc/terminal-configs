# Architecture

## Design Philosophy

This pipeline follows Dagster's **Software-Defined Asset (SDA)** paradigm. Instead of sequencing opaque tasks (Airflow-style), every table and analytical output is a first-class declarative asset with tracked lineage, freshness policies, and attached metadata.

## System Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Dagster Orchestrator                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌───────────────────────┐    ┌──────────────────────────────────┐  │
│  │   ingestion group     │    │         dbt group                │  │
│  │                       │    │                                  │  │
│  │ raw_experiment_events │───▶│  stg_experiment_users (view)     │  │
│  │ (python, partitioned  │    │         │                        │  │
│  │  by day × 28)         │    │         ▼                        │  │
│  └───────────────────────┘    │  fct_experiment_users (table)    │  │
│                               └──────────────┬───────────────────┘  │
│                                              │                      │
│                    ┌─────────────────────────┼────────────────┐     │
│                    │                         │                │     │
│                    ▼                         ▼                ▼     │
│  ┌─────────────────────────┐  ┌──────────────────┐  ┌───────────┐ │
│  │    analytics group      │  │ analytics group  │  │ sequential│ │
│  │                         │  │                  │  │   group   │ │
│  │ ab_test_summary_metrics │  │ ab_test_revenue  │  │           │ │
│  │ ab_test_segment_metrics │  │ _metrics         │  │ ab_test_  │ │
│  │ (CUPED + Welch + CI)   │  │ (CUPED + Cohen d)│  │ sequential│ │
│  └─────────────────────────┘  └──────────────────┘  │ _metrics  │ │
│                                                     │ (mSPRT)   │ │
│                                                     └───────────┘ │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  daily_schedule (cron 0 6 * * *)  │  new_data_sensor (mtime)│   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│                     DuckDB  (dev.duckdb)                             │
└─────────────────────────────────────────────────────────────────────┘
```

## Asset Graph

| Asset | Group | Compute Kind | Materialization | Partitioned |
|-------|-------|--------------|-----------------|-------------|
| `raw_experiment_events` | ingestion | python | DuckDB table `stg_raw_events` | Daily (28 days) |
| `stg_experiment_users` | dbt | dbt | DuckDB view | No |
| `fct_experiment_users` | dbt | dbt | DuckDB table | No |
| `ab_test_summary_metrics` | analytics | python | Metadata-only (conversion) | No |
| `ab_test_revenue_metrics` | analytics | python | Metadata-only (revenue) | No |
| `ab_test_segment_metrics` | analytics | python | Metadata-only (by quartile) | No |
| `ab_test_sequential_metrics` | sequential | python | Metadata-only (early stopping) | No |

## Scheduling and Automation

| Component | Type | Trigger |
|-----------|------|---------|
| `daily_schedule` | ScheduleDefinition | Cron `0 6 * * *` (06:00 UTC daily) |
| `new_data_sensor` | Sensor | DuckDB file mtime change (polls every 300s) |

Both target `daily_analytics_job` which selects all 4 analytics/sequential assets.

## Data Flow

1. **Ingestion (partitioned)** — Python generates ~1,786 synthetic users per experiment day (28 daily partitions). Each partition uses a deterministic seed (`42 + day_number`) and writes idempotently via DELETE+INSERT.
2. **Staging** — dbt view selects and validates raw columns (including `revenue`, `arrived_at`).
3. **Marts** — dbt table enriches with `is_treatment` flag consumed by all analytics assets.
4. **Analytics (conversion)** — CUPED-adjusted Welch's t-test with CI, Cohen's h, lift %, and power.
5. **Analytics (revenue)** — CUPED-adjusted revenue-per-user with Cohen's d, CI, and power.
6. **Analytics (segments)** — Per-quartile conversion analysis by pre-experiment purchase volume.
7. **Sequential** — Always-valid inference (Gaussian-mixture mSPRT) over daily cumulative looks for early stopping.

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| DuckDB over Postgres | Zero-infrastructure; entire pipeline runs from a laptop clone |
| Daily partitions on ingestion | Enables incremental backfill; each day is independently re-materializable |
| DELETE+INSERT (not CREATE OR REPLACE) | Idempotent per-partition writes without clobbering other days |
| Per-partition RNG seed (`42 + day`) | Deterministic data per day; re-materializing a partition produces identical rows |
| Schedule + sensor (not just schedule) | Schedule handles routine runs; sensor reacts to out-of-band data arrival |
| `SEQ_TAU = 0.01` | Mixing parameter must be ≤ MDE (3.5pp) for confidence sequence to exclude zero |
| CUPED adjustment | Reduces variance ~16% (rho^2 where rho≈0.4), detecting smaller lifts |
| Metadata on asset (not table) | Statistical summaries are ephemeral; Dagster UI is the dashboard |
| Local RNG (`default_rng`) | Avoids mutating global NumPy state; safe for concurrent asset execution |
| Context-managed connections | Guarantees cleanup on failure; prevents file-lock leaks |
| Read-only connection for analytics | Avoids unnecessary write locks; allows concurrent readers |
| Consume `is_treatment` from dbt | Group identity defined once in SQL; Python avoids stringly-typed filtering |
| Named threshold constants | `SRM_ALPHA` and `SIGNIFICANCE_ALPHA` as single source of truth for decision rules |
