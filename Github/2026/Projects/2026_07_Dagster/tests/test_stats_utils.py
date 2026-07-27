import numpy as np
import pandas as pd
import pytest

from ab_testing_dagster.stats_utils import (
    srm_p_value,
    cuped_adjust,
    welch_test,
    mean_diff_ci,
    cohens_h,
    cohens_d,
    posthoc_power,
    always_valid_p_and_ci,
)


class TestSrmPValue:
    def test_balanced_split_passes(self):
        counts = pd.Series({"control": 5000, "treatment": 5000})
        assert srm_p_value(counts) > 0.01

    def test_imbalanced_split_fails(self):
        counts = pd.Series({"control": 9000, "treatment": 1000})
        assert srm_p_value(counts) < 0.01


class TestCupedAdjust:
    def test_reduces_variance_when_correlated(self):
        rng = np.random.default_rng(1)
        n = 5000
        x = rng.normal(0, 1, n)
        y = 0.5 * x + rng.normal(0, 0.5, n)
        df = pd.DataFrame({"outcome": y, "pre_exp_purchases": x})

        adjusted = cuped_adjust(df, "outcome")
        assert adjusted.var() < df["outcome"].var()

    def test_preserves_mean_approximately(self):
        rng = np.random.default_rng(2)
        n = 5000
        x = rng.normal(5, 2, n)
        y = rng.normal(10, 1, n)
        df = pd.DataFrame({"outcome": y, "pre_exp_purchases": x})

        adjusted = cuped_adjust(df, "outcome")
        assert abs(adjusted.mean() - df["outcome"].mean()) < 0.1


class TestWelchTest:
    def test_detects_real_difference(self):
        rng = np.random.default_rng(3)
        control = pd.Series(rng.normal(0, 1, 1000))
        treatment = pd.Series(rng.normal(0.5, 1, 1000))
        result = welch_test(control, treatment)
        assert result["p_value"] < 0.05
        assert result["diff"] > 0

    def test_no_false_positive_on_identical(self):
        rng = np.random.default_rng(4)
        control = pd.Series(rng.normal(0, 1, 1000))
        treatment = pd.Series(rng.normal(0, 1, 1000))
        result = welch_test(control, treatment)
        assert result["p_value"] > 0.05


class TestMeanDiffCi:
    def test_ci_contains_true_difference(self):
        rng = np.random.default_rng(5)
        true_diff = 0.3
        control = pd.Series(rng.normal(0, 1, 2000))
        treatment = pd.Series(rng.normal(true_diff, 1, 2000))
        lo, hi = mean_diff_ci(control, treatment, alpha=0.05)
        assert lo < true_diff < hi

    def test_ci_excludes_zero_for_real_effect(self):
        rng = np.random.default_rng(6)
        control = pd.Series(rng.normal(0, 1, 5000))
        treatment = pd.Series(rng.normal(0.5, 1, 5000))
        lo, hi = mean_diff_ci(control, treatment, alpha=0.05)
        assert lo > 0


class TestCohensH:
    def test_zero_for_equal_proportions(self):
        assert cohens_h(0.5, 0.5) == pytest.approx(0.0, abs=1e-10)

    def test_positive_for_higher_treatment(self):
        assert cohens_h(0.15, 0.12) > 0

    def test_known_value(self):
        h = cohens_h(0.5, 0.4)
        assert h == pytest.approx(0.2014, abs=0.001)


class TestCohensD:
    def test_zero_for_identical_distributions(self):
        rng = np.random.default_rng(7)
        data = pd.Series(rng.normal(0, 1, 1000))
        assert cohens_d(data, data) == pytest.approx(0.0, abs=1e-10)

    def test_positive_for_higher_treatment(self):
        rng = np.random.default_rng(8)
        control = pd.Series(rng.normal(0, 1, 1000))
        treatment = pd.Series(rng.normal(0.5, 1, 1000))
        assert cohens_d(control, treatment) > 0


class TestPosthocPower:
    def test_high_power_for_large_effect(self):
        power = posthoc_power(0.5, 5000, 5000, 0.05)
        assert power > 0.99

    def test_low_power_for_tiny_effect_small_sample(self):
        power = posthoc_power(0.01, 50, 50, 0.05)
        assert power < 0.2


class TestAlwaysValidPAndCi:
    def _make_daily_stats(self, n_days=28, n_per_day=1000, effect=0.05, seed=42):
        rng = np.random.default_rng(seed)
        daily_stats = []
        cum_c, cum_t = [], []
        for _ in range(n_days):
            day_c = rng.binomial(1, 0.1, n_per_day)
            day_t = rng.binomial(1, 0.1 + effect, n_per_day)
            cum_c.extend(day_c)
            cum_t.extend(day_t)
            c_arr = np.array(cum_c)
            t_arr = np.array(cum_t)
            daily_stats.append({
                "n_c": len(c_arr),
                "n_t": len(t_arr),
                "mean_c": float(c_arr.mean()),
                "mean_t": float(t_arr.mean()),
                "var_c": float(c_arr.var(ddof=1)),
                "var_t": float(t_arr.var(ddof=1)),
            })
        return daily_stats

    def test_detects_effect_with_large_sample(self):
        daily_stats = self._make_daily_stats(n_days=28, n_per_day=2000, effect=0.05)
        result = always_valid_p_and_ci(daily_stats, tau=0.01, alpha=0.05)
        assert result["can_stop_early"] is True
        assert result["final_always_valid_p"] < 0.05

    def test_no_false_positive_under_null(self):
        daily_stats = self._make_daily_stats(n_days=28, n_per_day=500, effect=0.0, seed=99)
        result = always_valid_p_and_ci(daily_stats, tau=0.01, alpha=0.05)
        assert result["final_always_valid_p"] > 0.05

    def test_ci_narrows_over_time(self):
        daily_stats = self._make_daily_stats(n_days=28, n_per_day=2000, effect=0.05)
        result = always_valid_p_and_ci(daily_stats, tau=0.01, alpha=0.05)
        looks = result["looks"]
        width_early = looks[4]["ci_upper"] - looks[4]["ci_lower"]
        width_late = looks[-1]["ci_upper"] - looks[-1]["ci_lower"]
        assert width_late < width_early

    def test_ci_excludes_zero_when_effect_detected(self):
        daily_stats = self._make_daily_stats(n_days=28, n_per_day=2000, effect=0.05)
        result = always_valid_p_and_ci(daily_stats, tau=0.01, alpha=0.05)
        assert result["final_ci_lower"] > 0
