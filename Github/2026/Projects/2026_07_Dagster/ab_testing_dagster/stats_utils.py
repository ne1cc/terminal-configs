import numpy as np
import pandas as pd
import scipy.stats as stats


def srm_p_value(variant_counts: pd.Series) -> float:
    _, p = stats.chisquare(variant_counts)
    return float(p)


def cuped_adjust(
    df: pd.DataFrame, outcome_col: str, covariate_col: str = "pre_exp_purchases"
) -> pd.Series:
    theta = df[outcome_col].cov(df[covariate_col]) / df[covariate_col].var()
    return df[outcome_col] - theta * (df[covariate_col] - df[covariate_col].mean())


def welch_test(control: pd.Series, treatment: pd.Series) -> dict:
    t_stat, p_val = stats.ttest_ind(control, treatment, equal_var=False)
    diff = treatment.mean() - control.mean()
    se = np.sqrt(control.var() / len(control) + treatment.var() / len(treatment))
    return {"t_stat": float(t_stat), "p_value": float(p_val), "diff": float(diff), "se": float(se)}


def mean_diff_ci(control: pd.Series, treatment: pd.Series, alpha: float = 0.05) -> tuple:
    diff = treatment.mean() - control.mean()
    se = np.sqrt(control.var() / len(control) + treatment.var() / len(treatment))
    df_num = (control.var() / len(control) + treatment.var() / len(treatment)) ** 2
    df_den = (control.var() / len(control)) ** 2 / (len(control) - 1) + (
        treatment.var() / len(treatment)
    ) ** 2 / (len(treatment) - 1)
    dof = df_num / df_den
    t_crit = stats.t.ppf(1 - alpha / 2, dof)
    return (float(diff - t_crit * se), float(diff + t_crit * se))


def cohens_h(p_treatment: float, p_control: float) -> float:
    return float(2 * np.arcsin(np.sqrt(p_treatment)) - 2 * np.arcsin(np.sqrt(p_control)))


def cohens_d(control: pd.Series, treatment: pd.Series) -> float:
    n_c, n_t = len(control), len(treatment)
    pooled_std = np.sqrt(
        ((n_c - 1) * control.var() + (n_t - 1) * treatment.var()) / (n_c + n_t - 2)
    )
    return float((treatment.mean() - control.mean()) / pooled_std)


def posthoc_power(effect: float, n_control: int, n_treatment: int, alpha: float = 0.05) -> float:
    se = np.sqrt(1 / n_control + 1 / n_treatment)
    z_alpha = stats.norm.ppf(1 - alpha / 2)
    z_stat = abs(effect) / se
    power = 1 - stats.norm.cdf(z_alpha - z_stat) + stats.norm.cdf(-z_alpha - z_stat)
    return float(power)


def always_valid_p_and_ci(
    daily_stats: list[dict], tau: float = 0.05, alpha: float = 0.05
) -> dict:
    """Gaussian-mixture mSPRT over cumulative daily looks.

    Each entry in daily_stats: {"n_c": int, "n_t": int, "mean_c": float, "mean_t": float, "var_c": float, "var_t": float}
    """
    results = []
    earliest_stop = None

    for i, look in enumerate(daily_stats, start=1):
        n_c, n_t = look["n_c"], look["n_t"]
        if n_c < 2 or n_t < 2:
            results.append({"day": i, "p_value": 1.0, "ci_lower": -np.inf, "ci_upper": np.inf})
            continue

        diff = look["mean_t"] - look["mean_c"]
        sigma2 = look["var_c"] / n_c + look["var_t"] / n_t
        n_eff = 1.0 / sigma2 if sigma2 > 0 else 0.0

        # mSPRT likelihood ratio with normal mixing (variance tau^2)
        v_n = n_eff * sigma2  # = 1 for normalized, but keep general
        rho2 = tau**2
        log_lr = 0.5 * np.log(rho2 / (rho2 + sigma2)) + (diff**2) / (2 * (rho2 + sigma2))
        lr = np.exp(log_lr)

        p_val = min(1.0, 1.0 / lr) if lr > 0 else 1.0

        # Confidence sequence: |diff| <= sqrt(2 * (rho2 + sigma2) * log(1/alpha))
        radius = np.sqrt(2 * (rho2 + sigma2) * np.log(1.0 / alpha))
        ci_lower = diff - radius
        ci_upper = diff + radius

        results.append({"day": i, "p_value": float(p_val), "ci_lower": float(ci_lower), "ci_upper": float(ci_upper)})

        if p_val < alpha and earliest_stop is None:
            earliest_stop = i

    final = results[-1] if results else {"p_value": 1.0, "ci_lower": -np.inf, "ci_upper": np.inf}
    return {
        "can_stop_early": earliest_stop is not None,
        "earliest_stop_day": earliest_stop,
        "final_always_valid_p": final["p_value"],
        "final_ci_lower": final["ci_lower"],
        "final_ci_upper": final["ci_upper"],
        "looks": results,
    }
