# Current Status

## Current State

**Working:**
- Full pipeline: partitioned ingestion (28 days) → dbt staging/marts → 4 analytics assets
- All 4 blocking SRM checks pass
- Sequential testing detects effect at day 3 (mSPRT)
- Daily schedule (06:00 UTC) and file-mtime sensor registered
- 26 tests passing (unit + integration)
- CI workflow defined (GitHub Actions)
- Docker deployment config present

**Partially implemented:**
- Partitions only on ingestion asset (dbt/analytics assets are unpartitioned — they read the full table)

**Not started:**
- Postgres swap (still on DuckDB)
- Video walkthrough
- Blog post / template publication

## Active Objective

Phase 3 is complete. Phase 4 (portfolio polish) is next.

## Latest Verified State

- Last successful test run: `pytest -q` → 26 passed in 4.11s
- Last successful materialization: all 4 analytics assets + dbt build
- Sequential asset: `can_stop_early=True`, day 3, p=7.2e-20, CI=[0.006, 0.058]

## Immediate Next Steps

1. Commit all Phase 3 + Phase 4 changes
2. Push to remote and verify CI passes
3. Tag `v1.0` release
4. (Optional) Postgres swap to demonstrate warehouse portability

## Session Resume Instructions

```bash
# Activate environment
source .venv/bin/activate

# Verify tests pass
pytest -q

# Run full pipeline
dagster dev
# → Materialize All in UI

# Key files
# ab_testing_dagster/assets.py     — ingestion, partitions, schedule, sensor
# ab_testing_dagster/analytics.py  — revenue, segment, sequential assets
# ab_testing_dagster/stats_utils.py — pure stats (mSPRT fixed in this session)
# tests/                           — 26 tests
```
