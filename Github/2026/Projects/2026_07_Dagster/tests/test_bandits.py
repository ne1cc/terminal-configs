import pytest

from ab_testing_dagster.bandits import thompson_sampling, fixed_split_comparison


class TestThompsonSampling:
    def test_identifies_best_arm(self):
        result = thompson_sampling([0.10, 0.20, 0.15], n_rounds=300, batch_size=100, seed=7)
        assert result.best_arm == 1

    def test_converges(self):
        result = thompson_sampling([0.10, 0.20], n_rounds=500, batch_size=100, seed=42)
        assert result.converged_round is not None
        assert result.converged_round < 400

    def test_allocation_favors_best(self):
        result = thompson_sampling([0.10, 0.25], n_rounds=500, batch_size=100, seed=42)
        assert result.final_allocation[1] > 0.6

    def test_regret_lower_than_fixed(self):
        bandit = thompson_sampling([0.12, 0.155], n_rounds=500, batch_size=100, seed=42)
        fixed = fixed_split_comparison([0.12, 0.155], n_rounds=500, batch_size=100, seed=42)
        assert bandit.cumulative_regret < fixed["cumulative_regret"]

    def test_deterministic_with_seed(self):
        r1 = thompson_sampling([0.1, 0.2], n_rounds=100, seed=99)
        r2 = thompson_sampling([0.1, 0.2], n_rounds=100, seed=99)
        assert r1.total_reward == r2.total_reward
        assert r1.cumulative_regret == r2.cumulative_regret


class TestFixedSplit:
    def test_equal_allocation(self):
        result = fixed_split_comparison([0.1, 0.2, 0.3], n_rounds=100, seed=1)
        assert result["allocation"] == pytest.approx([1/3, 1/3, 1/3])

    def test_returns_reward(self):
        result = fixed_split_comparison([0.5, 0.5], n_rounds=100, batch_size=100, seed=1)
        assert result["total_reward"] > 0
