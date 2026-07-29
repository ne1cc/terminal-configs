from dagster import asset, AssetExecutionContext

from .bandits import thompson_sampling, fixed_split_comparison


@asset(
    group_name="bandit",
    compute_kind="python",
)
def thompson_sampling_simulation(context: AssetExecutionContext):
    """Simulates adaptive allocation via Thompson sampling vs fixed split.

    Uses the experiment's true conversion rates (control=12%, treatment=15.5%)
    to demonstrate how a bandit would allocate traffic adaptively.
    """
    true_rates = [0.12, 0.155]

    bandit = thompson_sampling(true_rates, n_rounds=500, batch_size=100, seed=42)
    fixed = fixed_split_comparison(true_rates, n_rounds=500, batch_size=100, seed=42)

    regret_reduction = (
        (fixed["cumulative_regret"] - bandit.cumulative_regret)
        / fixed["cumulative_regret"] * 100
        if fixed["cumulative_regret"] > 0
        else 0.0
    )

    context.add_output_metadata({
        "bandit_total_reward": bandit.total_reward,
        "fixed_total_reward": fixed["total_reward"],
        "bandit_cumulative_regret": bandit.cumulative_regret,
        "fixed_cumulative_regret": fixed["cumulative_regret"],
        "regret_reduction_pct": float(regret_reduction),
        "final_allocation_control": bandit.final_allocation[0],
        "final_allocation_treatment": bandit.final_allocation[1],
        "best_arm": bandit.best_arm,
        "converged_round": bandit.converged_round,
        "n_rounds": bandit.n_rounds,
        "batch_size": 100,
    })

    context.log.info(
        "bandit_simulation_complete",
        extra={
            "regret_reduction_pct": regret_reduction,
            "converged_round": bandit.converged_round,
        },
    )
