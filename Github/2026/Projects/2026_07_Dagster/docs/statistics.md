# Statistical Methodology

## Overview

The analytics asset (`ab_test_summary_metrics`) implements two industry-standard techniques for rigorous online experimentation:

1. **Sample Ratio Mismatch (SRM) detection**
2. **CUPED variance reduction**

---

## SRM Check

### Purpose

Detects whether the randomization mechanism is broken. If variant assignment deviates from the expected 50/50 split, all downstream conclusions are invalid.

### Method

Pearson's chi-square goodness-of-fit test on observed variant counts.

```
H₀: P(control) = P(treatment) = 0.5
```

### Decision Rule

| p-value | Interpretation |
|---------|----------------|
| > 0.01 | Randomization healthy — proceed |
| ≤ 0.01 | SRM detected — results untrustworthy |

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
Y_cuped = Y - θ · (X - E[X])

where:
  Y = converted (binary outcome)
  X = pre_exp_purchases (covariate)
  θ = Cov(Y, X) / Var(X)
```

### Expected Variance Reduction

With a correlation of ~0.4 between purchases and conversion, CUPED reduces variance by approximately 1 - ρ² ≈ 16%. In practice with this synthetic data, the reduction is sufficient to detect the 3.5pp lift at p < 0.05 with 50k users.

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

Welch's t-test (unequal variances) on the CUPED-adjusted metric between control and treatment groups.

```
H₀: μ_control = μ_treatment
H₁: μ_control ≠ μ_treatment  (two-sided)
```

### Decision Rule

| p-value | Interpretation |
|---------|----------------|
| < 0.05 | Statistically significant lift detected |
| ≥ 0.05 | No significant difference |

### Implementation

```python
t_stat, p_val = stats.ttest_ind(control, treatment, equal_var=False)
```

---

## Output Metadata (Dagster UI)

| Key | Type | Description |
|-----|------|-------------|
| `srm_p_value` | float | Chi-square p-value for randomization check |
| `srm_passed` | bool | True if p > 0.01 |
| `cuped_p_value` | float | Welch's t-test p-value on adjusted metric |
| `statistically_significant` | bool | True if p < 0.05 |
| `sample_size` | int | Total users in experiment |

---

## References

- Deng, A. et al. (2013). "Improving the Sensitivity of Online Controlled Experiments by Utilizing Pre-Experiment Data" (CUPED). WSDM.
- Fabijan, A. et al. (2019). "The Benefits of Controlled Experiments at Scale." IEEE Software.
