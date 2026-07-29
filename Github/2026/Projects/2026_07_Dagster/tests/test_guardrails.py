import numpy as np
import pandas as pd
import pytest

from ab_testing_dagster.guardrails import guardrail_test


@pytest.fixture
def rng():
    return np.random.default_rng(123)


class TestGuardrailPass:
    def test_positive_treatment_passes(self, rng):
        control = pd.Series(rng.normal(10.0, 2.0, 5000))
        treatment = pd.Series(rng.normal(10.5, 2.0, 5000))
        result = guardrail_test(control, treatment, margin=0.5, alpha=0.05)
        assert result["passed"] is True
        assert result["p_value"] < 0.05
        assert result["ci_lower"] > -0.5

    def test_equal_treatment_passes(self, rng):
        control = pd.Series(rng.normal(10.0, 2.0, 10000))
        treatment = pd.Series(rng.normal(10.0, 2.0, 10000))
        result = guardrail_test(control, treatment, margin=0.5, alpha=0.05)
        assert result["passed"] is True


class TestGuardrailFail:
    def test_large_negative_fails(self, rng):
        control = pd.Series(rng.normal(10.0, 2.0, 5000))
        treatment = pd.Series(rng.normal(9.0, 2.0, 5000))
        result = guardrail_test(control, treatment, margin=0.5, alpha=0.05)
        assert result["passed"] is False

    def test_margin_boundary(self, rng):
        control = pd.Series(rng.normal(10.0, 1.0, 50000))
        treatment = pd.Series(rng.normal(9.4, 1.0, 50000))
        result = guardrail_test(control, treatment, margin=0.5, alpha=0.05)
        assert result["passed"] is False
        assert result["ci_lower"] < -0.5


class TestOutput:
    def test_returns_all_keys(self, rng):
        control = pd.Series(rng.normal(5.0, 1.0, 100))
        treatment = pd.Series(rng.normal(5.1, 1.0, 100))
        result = guardrail_test(control, treatment, margin=0.2)
        assert set(result.keys()) == {"passed", "p_value", "ci_lower", "diff", "se", "margin"}
