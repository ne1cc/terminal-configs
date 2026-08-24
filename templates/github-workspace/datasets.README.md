# Local datasets

Drop CSV, Parquet, DuckDB, and other data files here. This directory is **gitignored**.

## Suggested layout

```
datasets/
??? raw/           # downloads (Kaggle, API dumps)
??? processed/     # cleaned intermediates
??? warehouse/     # .duckdb files
??? exports/       # one-off extracts for dashboards
```

## Conventions

- Prefer repo-local `data/` when data belongs to one project
- Use `workspace/datasets/` for shared files across repos
- Never commit licensed data (Kaggle, DHS microdata, etc.)
