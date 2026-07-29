from __future__ import annotations

import numpy as np
import pandas as pd
import scipy.stats as stats


def guardrail_test(
    control: pd.Series,
    treatment: pd.Series,
    margin: float,
    alpha: float = 0.05,
) -> dict:
    """One-sided non-inferiority test.

    H0: treatment mean - control mean <= -margin (treatment is worse by at least margin)
    H1: treatment mean - control mean > -margin (treatment is non-inferior)

    Returns dict with passed, p_value, ci_lower, diff.
    """
    diff = treatment.mean() - control.mean()
    se = np.sqrt(control.var() / len(control) + treatment.var() / len(treatment))

    z = (diff - (-margin)) / se if se > 0 else 0.0
    p_value = 1.0 - stats.norm.cdf(z)

    z_crit = stats.norm.ppf(1 - alpha)
    ci_lower = diff - z_crit * se

    passed = bool(p_value < alpha and ci_lower > -margin)

    return {
        "passed": passed,
        "p_value": float(p_value),
        "ci_lower": float(ci_lower),
        "diff": float(diff),
        "se": float(se),
        "margin": margin,
    }
