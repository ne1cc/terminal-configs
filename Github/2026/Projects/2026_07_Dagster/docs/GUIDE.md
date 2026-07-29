# The Complete Guide to This Project

## What This Project Is

This is an **A/B testing pipeline** — an automated system that simulates a product experiment (like testing a new checkout button), transforms the raw data into a clean analytical table, and then runs rigorous statistical tests to determine whether the experiment produced a real, meaningful result.

The entire pipeline is orchestrated by **Dagster**, which treats every intermediate table and analytical output as a *data asset* with tracked dependencies, so you can see exactly how data flows from raw generation to final statistical conclusion.

---

## The Problem It Solves

When a product team runs an A/B test, they need to answer:

> "Did the treatment (new feature) actually cause more conversions, or is the difference just random noise?"

Naively comparing two averages is not enough. Real experimentation platforms must:

1. **Detect broken randomization** — if more users ended up in one group by accident, all conclusions are invalid (Sample Ratio Mismatch).
2. **Reduce noise** — pre-existing differences between users (e.g., some users already buy more) inflate variance and hide real effects (solved by CUPED).
3. **Produce trustworthy p-values** — using the correct statistical test with proper assumptions.
4. **Be reproducible and auditable** — anyone should be able to re-run the pipeline and get the same answer.

This project demonstrates all four concerns in a self-contained, zero-infrastructure pipeline.

---

## The Tech Stack (and Why Each Piece)

| Tool | Role | Why This Tool |
|------|------|---------------|
| **Dagster** | Orchestration | Asset-based (not task-based); tracks data lineage; logs metadata into a UI; supports blocking checks |
| **dbt** | SQL transformations | Declarative models with built-in testing; manifest-driven lineage; industry standard |
| **DuckDB** | Database | Embedded (no server); zero config; fast analytical queries; single file |
| **NumPy** | Data generation | Vectorized random variate generation; reproducible via seeded generators |
| **Pandas** | Data manipulation | DataFrame interface between Python and DuckDB |
| **SciPy** | Statistics | Chi-square test, Welch's t-test — battle-tested implementations |

---

## How the Pipeline Works (End to End)

```
Step 1: INGESTION
  Python generates 50,000 fake users with:
    - a random group assignment (control or treatment)
    - a pre-experiment covariate (how much they bought before)
    - a conversion outcome (did they buy during the experiment?)
  Writes to DuckDB table: stg_raw_events

Step 2: STAGING (dbt)
  A dbt view selects and validates the raw columns.
  dbt tests run: not_null, unique, accepted_values.
  Output: stg_experiment_users (view)

Step 3: MART (dbt)
  A dbt table enriches the data with an is_treatment flag.
  dbt tests run again on the enriched table.
  Output: fct_experiment_users (table)

Step 4: ANALYSIS (Python)
  Reads the mart, then:
    a) SRM check — is the 50/50 split intact?
    b) CUPED adjustment — remove noise from pre-existing differences
    c) Welch's t-test — is the treatment effect statistically significant?
  Logs all results as metadata in the Dagster UI.
  A blocking asset check independently verifies SRM passes.
```

---

## Deep Dive: Each File Explained

### `ab_testing_dagster/assets.py` — The Core Pipeline

This file defines all four assets and one asset check.

#### Module-Level Constants

```python
DBT_PROJECT_DIR = Path(__file__).joinpath("..", "..", "dbt_project").resolve()
DB_PATH = DBT_PROJECT_DIR / "dev.duckdb"
SRM_ALPHA = 0.01
SIGNIFICANCE_ALPHA = 0.05
```

- `DBT_PROJECT_DIR` — locates the dbt project relative to this file, so the pipeline works regardless of where you clone the repo.
- `DB_PATH` — the single DuckDB file shared by all assets. One file = one database.
- `SRM_ALPHA` / `SIGNIFICANCE_ALPHA` — the decision thresholds. Named constants so the rules live in one place.

#### Asset 1: `raw_experiment_events`

```python
@asset(group_name="ingestion", compute_kind="python")
def raw_experiment_events():
```

**What it does:** Creates 50,000 synthetic users and writes them to DuckDB.

**How it works, line by line:**

```python
rng = np.random.default_rng(42)
```
Creates a *local* random number generator seeded with 42. This means:
- The same data is generated every time (reproducible).
- It does NOT mutate global NumPy state (safe if other code runs concurrently).

```python
users = pd.DataFrame({
    "user_id": np.arange(1, n_users + 1),
    "variant": rng.choice(["control", "treatment"], size=n_users, p=[0.5, 0.5]),
    "pre_exp_purchases": rng.poisson(lam=1.2, size=n_users),
})
```
Builds a DataFrame with:
- `user_id` — unique identifier (1 to 50,000)
- `variant` — randomly assigned group, 50/50 split
- `pre_exp_purchases` — how many times the user bought *before* the experiment (Poisson distributed, average 1.2 purchases). This is the **covariate** used later for CUPED.

```python
probs = np.where(users["variant"] == "treatment", 0.12 + 0.035, 0.12)
users["converted"] = rng.binomial(1, probs)
```
Assigns conversion probability per user:
- Control users: 12% chance of converting
- Treatment users: 15.5% chance (a +3.5 percentage point lift)

Then draws a single Bernoulli outcome per user. The `np.where` builds a probability *vector* so we only call `binomial` once (efficient — no redundant RNG draws).

```python
with duckdb.connect(str(DB_PATH)) as con:
    con.register("users_df", users)
    con.execute("CREATE OR REPLACE TABLE stg_raw_events AS SELECT * FROM users_df")
```
- `with` — context manager guarantees the connection closes even if an error occurs.
- `con.register("users_df", users)` — explicitly makes the DataFrame available to SQL by name. This is safer than relying on DuckDB's implicit variable scanning.
- `CREATE OR REPLACE TABLE` — idempotent: re-running the asset always produces a clean table.

#### Asset 2: `my_dbt_assets`

```python
@dbt_assets(manifest=dbt_project.manifest_path)
def my_dbt_assets(context: AssetExecutionContext, dbt: DbtCliResource):
    yield from dbt.cli(["build"], context=context).stream()
```

**What it does:** Runs `dbt build`, which executes all SQL models AND their tests in dependency order.

**How it works:**
- `@dbt_assets` reads dbt's `manifest.json` (generated by `dbt parse`) and creates one Dagster asset node per dbt model.
- `dbt.cli(["build"])` runs the models. `build` = `run` + `test` (so schema tests execute automatically).
- `.stream()` yields events back to Dagster so the UI shows real-time progress per model.

The dbt models themselves:

**`stg_experiment_users.sql`** (staging view):
```sql
select user_id, variant, pre_exp_purchases, converted
from {{ source('main', 'stg_raw_events') }}
```
A thin pass-through that establishes a stable column contract. The `{{ source(...) }}` macro tells dbt this reads from the raw table, creating a lineage edge.

**`fct_experiment_users.sql`** (mart table):
```sql
select *, case when variant = 'treatment' then 1 else 0 end as is_treatment
from {{ ref('stg_experiment_users') }}
```
Adds a binary flag so downstream consumers don't need to pattern-match on strings. The `{{ ref(...) }}` macro creates the dependency on the staging model.

#### Asset 3: `ab_test_summary_metrics`

```python
@asset(deps=["fct_experiment_users"], group_name="analytics", compute_kind="python")
def ab_test_summary_metrics(context: AssetExecutionContext):
```

**What it does:** Reads the clean mart, runs three statistical procedures, and logs results.

**Step-by-step:**

```python
with duckdb.connect(str(DB_PATH), read_only=True) as con:
    df = con.execute(
        "SELECT variant, converted, pre_exp_purchases, is_treatment"
        " FROM fct_experiment_users"
    ).df()
```
- `read_only=True` — this asset only reads, so it opens a read-only connection (no write lock, allows concurrent readers).
- Selects only the 4 needed columns (not `SELECT *`).
- `.df()` converts the result directly to a Pandas DataFrame.

**SRM Check:**
```python
observed = df["variant"].value_counts()
_, srm_p_value = stats.chisquare(observed)
```
Counts how many users are in each group and runs a chi-square goodness-of-fit test against the expected 50/50 split. If p <= 0.01, randomization is broken and all results are suspect.

**CUPED Adjustment:**
```python
theta = df["converted"].cov(df["pre_exp_purchases"]) / df["pre_exp_purchases"].var()
df["converted_cuped"] = df["converted"] - theta * (
    df["pre_exp_purchases"] - df["pre_exp_purchases"].mean()
)
```
CUPED removes variance explained by the pre-experiment covariate:
- `theta` = how much conversion changes per unit of pre-experiment purchases (regression coefficient).
- The adjusted metric `converted_cuped` subtracts out the predictable component, leaving only the "surprise" variation — which is what the experiment actually caused.
- This makes the subsequent t-test more powerful (can detect smaller effects with the same sample size).

**Welch's t-test:**
```python
control = df.loc[~df["is_treatment"].astype(bool), "converted_cuped"]
treatment = df.loc[df["is_treatment"].astype(bool), "converted_cuped"]
_, p_val = stats.ttest_ind(control, treatment, equal_var=False)
```
- Splits users by the dbt-modeled `is_treatment` flag (not string matching).
- `equal_var=False` → Welch's t-test, which does not assume equal variances between groups (safer default).
- If p < 0.05, the treatment effect is statistically significant.

**Metadata logging:**
```python
context.add_output_metadata({...})
```
Attaches the statistical results to the materialization event. These appear in the Dagster UI as structured metadata — no separate dashboard needed.

#### Asset Check: `srm_check`

```python
@asset_check(asset=ab_test_summary_metrics, blocking=True)
def srm_check():
```

**What it does:** Independently re-verifies that randomization is intact.

**Why it exists separately from the asset:** The asset *reports* the SRM p-value as metadata, but this check *enforces* it. With `blocking=True`, if the check fails, Dagster marks the materialization as failed — downstream consumers will not see stale or invalid results.

---

### `ab_testing_dagster/definitions.py` — The Entrypoint

```python
defs = Definitions(
    assets=load_assets_from_modules([assets]),
    resources={"dbt": DbtCliResource(project_dir=dbt_project)},
)
```

This is what Dagster loads when you run `dagster dev`. It:
- Discovers all `@asset` and `@asset_check` decorated functions in `assets.py`.
- Provides the `dbt` resource (a configured CLI wrapper) that `my_dbt_assets` needs to execute `dbt build`.

---

### `dbt_project/` — The dbt Project

| File | Purpose |
|------|---------|
| `dbt_project.yml` | Project name, model paths, materialization config (staging=view, marts=table) |
| `profiles.yml` | DuckDB connection settings; supports `DBT_DUCKDB_PATH` env var override |
| `models/staging/_sources.yml` | Declares `stg_raw_events` as a source (creates lineage edge in dbt) |
| `models/staging/_stg_experiment_users.yml` | Schema tests for the staging model |
| `models/marts/_fct_experiment_users.yml` | Schema tests for the mart model |

**dbt tests explained:**
- `not_null` — the column must never be NULL
- `unique` — no duplicate values (applied to `user_id`)
- `accepted_values` — the column must only contain listed values (e.g., variant must be "control" or "treatment", converted must be 0 or 1)

These run automatically during `dbt build` and will fail the Dagster asset if any test fails.

---

### `pyproject.toml` — Packaging

Declares the project as an installable Python package with all dependencies. The `[tool.dagster]` section tells the Dagster CLI where to find the code location. The `[tool.setuptools.packages.find]` section ensures only `ab_testing_dagster` is packaged (not `dbt_project` or `docs`).

---

## How to Use This Project

### First Time Setup

```bash
cd 2026_07_Dagster
uv venv --python 3.12        # or: python3.12 -m venv .venv
source .venv/bin/activate
pip install -e .
```

### Running the Pipeline

```bash
dagster dev
```

1. Open http://localhost:3000
2. Click **Assets** in the left sidebar
3. Click **Materialize All**
4. Watch the lineage graph light up: ingestion → staging → marts → analytics
5. Click `ab_test_summary_metrics` → latest materialization → **Output Metadata**
6. See: `srm_passed: true`, `cuped_p_value: <some small number>`, `statistically_significant: true`

### Running Without the UI (Programmatic)

```python
from dagster import materialize
from ab_testing_dagster.assets import raw_experiment_events, ab_test_summary_metrics

result = materialize([raw_experiment_events, ab_test_summary_metrics])
```

### Running dbt Tests Standalone

```bash
cd dbt_project
dbt test --profiles-dir .
```

---

## Key Concepts Explained Simply

### Software-Defined Assets (Dagster's Core Idea)

Traditional orchestrators (Airflow) say: "Run task A, then task B, then task C." They don't know what *data* those tasks produce.

Dagster flips this: you declare "this function produces *this table*" and "this function consumes *that table*." Dagster infers the execution order from the data dependencies. Benefits:
- You can materialize a single asset and Dagster automatically materializes its upstream dependencies.
- The UI shows a data lineage graph, not a task DAG.
- Freshness policies can alert when a table is stale.

### CUPED (Variance Reduction)

Imagine two users: one who buys 10x/month and one who buys 0x/month. If both are in your experiment, their outcomes are dominated by their *pre-existing behavior*, not by your treatment. CUPED subtracts out the predictable component:

```
adjusted_outcome = outcome - theta * (covariate - mean_covariate)
```

After adjustment, both users are "normalized" to the same baseline, so the remaining variation is more likely due to the treatment. This gives you more statistical power without collecting more data.

### SRM (Sample Ratio Mismatch)

If you assign users 50/50 but observe 51/49 in your data, something went wrong (buggy assignment code, bot filtering, logging drops). A chi-square test detects this. If SRM is detected, you must NOT trust the experiment results — the groups are not comparable.

### Blocking Asset Checks

A regular asset check reports a warning. A *blocking* check (`blocking=True`) fails the materialization. This means:
- Downstream assets that depend on this one will NOT be materialized.
- The Dagster UI shows a red failure state.
- In production, this prevents bad data from propagating.

---

## How to Extend This Project

### Add a New Metric

1. Add a column in `fct_experiment_users.sql` (e.g., `revenue`).
2. Add dbt tests for it in `_fct_experiment_users.yml`.
3. Create a new `@asset` in `assets.py` with `deps=["fct_experiment_users"]`.
4. Run your statistical test and log metadata.

### Add a New dbt Model

1. Create `models/marts/your_model.sql` using `{{ ref('fct_experiment_users') }}`.
2. Add a schema yml with tests.
3. Run `dbt parse --profiles-dir .` to regenerate the manifest.
4. Dagster automatically picks up the new model on next code load.

### Add a Schedule

In `definitions.py`:
```python
from dagster import ScheduleDefinition, define_asset_job

daily = ScheduleDefinition(
    job=define_asset_job("daily_run", selection="*"),
    cron_schedule="0 6 * * *",
)

defs = Definitions(assets=..., schedules=[daily], resources=...)
```

### Swap DuckDB for Postgres

1. Change `profiles.yml` to use `type: postgres` with connection details.
2. Update `DB_PATH` logic in `assets.py` to use `psycopg2` or `sqlalchemy`.
3. The dbt models (SQL) remain unchanged — that's the point of dbt's abstraction.

---

## File Reference

```
.
├── ab_testing_dagster/
│   ├── __init__.py              # Package marker
│   ├── assets.py                # All assets + asset check + constants
│   └── definitions.py           # Dagster entrypoint (loaded by `dagster dev`)
├── dbt_project/
│   ├── dbt_project.yml          # dbt config: model paths, materializations
│   ├── profiles.yml             # DuckDB connection (env-var overridable)
│   └── models/
│       ├── staging/
│       │   ├── _sources.yml                 # Declares stg_raw_events source
│       │   ├── _stg_experiment_users.yml    # Schema tests (6 tests)
│       │   └── stg_experiment_users.sql     # Staging view
│       └── marts/
│           ├── _fct_experiment_users.yml    # Schema tests (10 tests)
│           └── fct_experiment_users.sql     # Mart table with is_treatment
├── docs/                        # Detailed documentation
├── .gitignore                   # Excludes .venv, *.duckdb, target/, etc.
├── PLAN.md                      # Roadmap for next phases
└── pyproject.toml               # Python packaging + dependencies
```
