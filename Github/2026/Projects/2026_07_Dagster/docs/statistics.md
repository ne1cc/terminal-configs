# Statistical Methodology

## Overview

The analytics asset (`ab_test_summary_metrics`) implements two industry-standard techniques for rigorous online experimentation:

1. **Sample Ratio Mismatch (SRM) detection**
2. **CUPED variance reduction**

Thresholds are defined as module-level constants in `assets.py`:

```python
SRM_ALPHA = 0.01
SIGNIFICANCE_ALPHA = 0.05
```

---

## SRM Check

### Purpose

Detects whether the randomization mechanism is broken. If variant assignment deviates from the expected 50/50 split, all downstream conclusions are invalid.

### Method

Pearson's chi-square goodness-of-fit test on observed variant counts.

```
H0: P(control) = P(treatment) = 0.5
```

### Decision Rule

| p-value | Interpretation |
|---------|----------------|
| > `SRM_ALPHA` (0.01) | Randomization healthy — proceed |
| <= `SRM_ALPHA` (0.01) | SRM detected — results untrustworthy |

### Implementation

```python
observed = df["variant"].value_counts()
_, srm_p_value = stats.chisquare(observed)
```

---

## CUPED (Controlled-experiment Using Pre-Experiment Data)

### Purpose

Reduces variance in the metric of interest by leveraging a pre-experiment covariate (here: `pre_exp_purchases`). Lower variance means higher statistical power to detect the same effect size with fewer users.

### Formula

```
Y_cuped = Y - theta * (X - E[X])

where:
  Y = converted (binary outcome)
  X = pre_exp_purchases (covariate)
  theta = Cov(Y, X) / Var(X)
```

### Expected Variance Reduction

With a correlation of ~0.4 between purchases and conversion, CUPED reduces variance by rho^2 ≈ 16% (remaining variance is 1 - rho^2 ≈ 84% of the original). In practice with this synthetic data, the reduction is sufficient to detect the 3.5pp lift at p < 0.05 with 50k users.

### Implementation

```python
theta = df["converted"].cov(df["pre_exp_purchases"]) / df["pre_exp_purchases"].var()
df["converted_cuped"] = df["converted"] - theta * (
    df["pre_exp_purchases"] - df["pre_exp_purchases"].mean()
)
```

---

## Hypothesis Test

### Method

Welch's t-test (unequal variances) on the CUPED-adjusted metric between control and treatment groups. Groups are identified via the dbt-modeled `is_treatment` column.

```
H0: mu_control = mu_treatment
H1: mu_control != mu_treatment  (two-sided)
```

### Decision Rule

| p-value | Interpretation |
|---------|----------------|
| < `SIGNIFICANCE_ALPHA` (0.05) | Statistically significant lift detected |
| >= `SIGNIFICANCE_ALPHA` (0.05) | No significant difference |

### Implementation

```python
control = df.loc[~df["is_treatment"].astype(bool), "converted_cuped"]
treatment = df.loc[df["is_treatment"].astype(bool), "converted_cuped"]
_, p_val = stats.ttest_ind(control, treatment, equal_var=False)
```

---

## Output Metadata (Dagster UI)

| Key | Type | Description |
|-----|------|-------------|
| `srm_p_value` | float | Chi-square p-value for randomization check |
| `srm_passed` | bool | True if p > `SRM_ALPHA` |
| `cuped_p_value` | float | Welch's t-test p-value on adjusted metric |
| `statistically_significant` | bool | True if p < `SIGNIFICANCE_ALPHA` |
| `sample_size` | int | Total users in experiment |

---

## Data Generation Parameters

The ingestion asset uses a local NumPy generator (`default_rng(42)`) for reproducibility:

| Parameter | Distribution | Value |
|-----------|-------------|-------|
| `variant` | Categorical | 50/50 control/treatment |
| `pre_exp_purchases` | Poisson | lambda = 1.2 |
| `converted` (control) | Bernoulli | p = 0.12 |
| `converted` (treatment) | Bernoulli | p = 0.155 (lift = +3.5pp) |

Conversion probabilities are applied via a single vectorized `rng.binomial(1, probs)` call using a per-user probability array, avoiding redundant RNG draws.

---

## References

- Deng, A. et al. (2013). "Improving the Sensitivity of Online Controlled Experiments by Utilizing Pre-Experiment Data" (CUPED). WSDM.
- Fabijan, A. et al. (2019). "The Benefits of Controlled Experiments at Scale." IEEE Software.
