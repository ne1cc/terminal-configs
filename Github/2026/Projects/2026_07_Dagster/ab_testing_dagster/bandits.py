import numpy as np
from dataclasses import dataclass


@dataclass(frozen=True)
class BanditResult:
    n_rounds: int
    n_arms: int
    total_reward: int
    cumulative_regret: float
    final_allocation: list[float]
    best_arm: int
    converged_round: int | None


def thompson_sampling(
    true_rates: list[float],
    n_rounds: int = 1000,
    batch_size: int = 100,
    seed: int = 42,
) -> BanditResult:
    """Beta-Bernoulli Thompson sampling for multi-armed bandit allocation.

    Each round: sample from Beta(successes+1, failures+1) per arm,
    allocate batch to arm with highest sample, observe Bernoulli outcomes.
    """
    rng = np.random.default_rng(seed)
    n_arms = len(true_rates)
    true_rates_arr = np.array(true_rates)
    best_arm_rate = true_rates_arr.max()

    successes = np.zeros(n_arms)
    failures = np.zeros(n_arms)
    pulls = np.zeros(n_arms)
    total_reward = 0
    cumulative_regret = 0.0
    converged_round = None

    for round_num in range(1, n_rounds + 1):
        samples = rng.beta(successes + 1, failures + 1)
        chosen = int(np.argmax(samples))

        outcomes = rng.binomial(1, true_rates_arr[chosen], size=batch_size)
        n_success = int(outcomes.sum())
        n_fail = batch_size - n_success

        successes[chosen] += n_success
        failures[chosen] += n_fail
        pulls[chosen] += 1
        total_reward += n_success

        regret = (best_arm_rate - true_rates_arr[chosen]) * batch_size
        cumulative_regret += regret

        if converged_round is None and round_num > 10:
            pull_share = pulls[chosen] / pulls.sum()
            if pull_share > 0.9:
                converged_round = round_num

    total_pulls = successes + failures
    final_allocation = (total_pulls / total_pulls.sum()).tolist()
    best_arm = int(np.argmax(successes / (total_pulls + 1e-10)))

    return BanditResult(
        n_rounds=n_rounds,
        n_arms=n_arms,
        total_reward=total_reward,
        cumulative_regret=float(cumulative_regret),
        final_allocation=final_allocation,
        best_arm=best_arm,
        converged_round=converged_round,
    )


def fixed_split_comparison(
    true_rates: list[float],
    n_rounds: int = 1000,
    batch_size: int = 100,
    seed: int = 42,
) -> dict:
    """Simulate equal fixed allocation for comparison with Thompson sampling."""
    rng = np.random.default_rng(seed)
    n_arms = len(true_rates)
    true_rates_arr = np.array(true_rates)
    best_arm_rate = true_rates_arr.max()

    total_reward = 0
    cumulative_regret = 0.0

    for _ in range(n_rounds):
        chosen = rng.integers(0, n_arms)
        outcomes = rng.binomial(1, true_rates_arr[chosen], size=batch_size)
        total_reward += int(outcomes.sum())
        cumulative_regret += (best_arm_rate - true_rates_arr[chosen]) * batch_size

    return {
        "total_reward": total_reward,
        "cumulative_regret": float(cumulative_regret),
        "allocation": [1.0 / n_arms] * n_arms,
    }
