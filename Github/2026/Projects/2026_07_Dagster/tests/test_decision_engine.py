import pytest

from ab_testing_dagster.decision_engine import decide, Decision


class TestShip:
    def test_clear_ship(self):
        d = decide(
            p_value=0.001, ci_lower=0.01, ci_upper=0.05,
            power=0.95, alpha=0.05, target_power=0.80,
            guardrail_passed=True, sequential_can_stop=True,
        )
        assert d.verdict == "ship"
        assert d.confidence_level == pytest.approx(0.999)
        assert any("Sequential" in r for r in d.reasons)

    def test_ship_without_sequential(self):
        d = decide(
            p_value=0.03, ci_lower=0.001, ci_upper=0.04,
            power=0.85, alpha=0.05, target_power=0.80,
            guardrail_passed=True, sequential_can_stop=False,
        )
        assert d.verdict == "ship"
        assert not any("Sequential" in r for r in d.reasons)


class TestKill:
    def test_significant_negative(self):
        d = decide(
            p_value=0.001, ci_lower=-0.05, ci_upper=-0.01,
            power=0.95, alpha=0.05, target_power=0.80,
            guardrail_passed=True,
        )
        assert d.verdict == "kill"

    def test_kill_even_if_guardrail_failed(self):
        d = decide(
            p_value=0.01, ci_lower=-0.03, ci_upper=-0.005,
            power=0.90, alpha=0.05, target_power=0.80,
            guardrail_passed=False,
        )
        assert d.verdict == "kill"


class TestHold:
    def test_not_significant(self):
        d = decide(
            p_value=0.15, ci_lower=-0.01, ci_upper=0.04,
            power=0.60, alpha=0.05, target_power=0.80,
            guardrail_passed=True,
        )
        assert d.verdict == "hold"
        assert any("Not statistically significant" in r for r in d.reasons)

    def test_ci_includes_zero(self):
        d = decide(
            p_value=0.04, ci_lower=-0.001, ci_upper=0.03,
            power=0.85, alpha=0.05, target_power=0.80,
            guardrail_passed=True,
        )
        assert d.verdict == "hold"
        assert any("includes zero" in r for r in d.reasons)

    def test_underpowered(self):
        d = decide(
            p_value=0.02, ci_lower=0.005, ci_upper=0.04,
            power=0.65, alpha=0.05, target_power=0.80,
            guardrail_passed=True,
        )
        assert d.verdict == "hold"
        assert any("Underpowered" in r for r in d.reasons)

    def test_guardrail_violation(self):
        d = decide(
            p_value=0.01, ci_lower=0.01, ci_upper=0.05,
            power=0.90, alpha=0.05, target_power=0.80,
            guardrail_passed=False,
        )
        assert d.verdict == "hold"
        assert any("Guardrail" in r for r in d.reasons)


class TestDecisionDataclass:
    def test_frozen(self):
        d = decide(
            p_value=0.001, ci_lower=0.01, ci_upper=0.05,
            power=0.95, alpha=0.05, target_power=0.80,
            guardrail_passed=True,
        )
        with pytest.raises(AttributeError):
            d.verdict = "hold"
