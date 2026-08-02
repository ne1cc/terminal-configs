import duckdb
import numpy as np
import pandas as pd
import pytest
from unittest.mock import patch

from dagster import materialize

from ab_testing_dagster.assets import (
    raw_experiment_events,
    daily_partitions,
)
from ab_testing_dagster.analytics import (
    ab_test_revenue_metrics,
    ab_test_segment_metrics,
    ab_test_sequential_metrics,
)


@pytest.fixture
def tmp_db(tmp_path):
    """Create a temporary DuckDB with synthetic data for analytics tests."""
    db_path = tmp_path / "test.duckdb"
    rng = np.random.default_rng(42)
    n = 10000

    users = pd.DataFrame({
        "user_id": np.arange(1, n + 1),
        "variant": rng.choice(["control", "treatment"], size=n, p=[0.5, 0.5]),
        "pre_exp_purchases": rng.poisson(lam=1.2, size=n),
    })
    probs = np.where(users["variant"] == "treatment", 0.155, 0.12)
    users["converted"] = rng.binomial(1, probs)
    base_revenue = rng.lognormal(mean=2.5, sigma=0.8, size=n)
    treatment_mult = np.where(users["variant"] == "treatment", 1.15, 1.0)
    users["revenue"] = users["converted"] * base_revenue * treatment_mult
    users["arrived_at"] = rng.integers(1, 29, size=n)
    users["is_treatment"] = (users["variant"] == "treatment").astype(int)

    con = duckdb.connect(str(db_path))
    con.execute("CREATE TABLE fct_experiment_users AS SELECT * FROM users")
    con.close()

    return db_path


class TestPartitionedIngestion:
    def test_single_partition_creates_table(self, tmp_path):
        db_path = tmp_path / "ingest.duckdb"
        with patch("ab_testing_dagster.assets.DB_PATH", db_path):
            keys = daily_partitions.get_partition_keys()
            result = materialize([raw_experiment_events], partition_key=keys[0])

        assert result.success
        con = duckdb.connect(str(db_path), read_only=True)
        count = con.execute("SELECT COUNT(*) FROM stg_raw_events").fetchone()[0]
        con.close()
        assert count > 0

    def test_partition_is_idempotent(self, tmp_path):
        db_path = tmp_path / "ingest.duckdb"
        with patch("ab_testing_dagster.assets.DB_PATH", db_path):
            keys = daily_partitions.get_partition_keys()
            materialize([raw_experiment_events], partition_key=keys[0])
            materialize([raw_experiment_events], partition_key=keys[0])

            con = duckdb.connect(str(db_path), read_only=True)
            count = con.execute("SELECT COUNT(*) FROM stg_raw_events").fetchone()[0]
            con.close()

        n_per_day = 50000 // 28
        assert count == n_per_day

    def test_multiple_partitions_accumulate(self, tmp_path):
        db_path = tmp_path / "ingest.duckdb"
        with patch("ab_testing_dagster.assets.DB_PATH", db_path):
            keys = daily_partitions.get_partition_keys()
            for k in keys[:3]:
                materialize([raw_experiment_events], partition_key=k)

            con = duckdb.connect(str(db_path), read_only=True)
            count = con.execute("SELECT COUNT(*) FROM stg_raw_events").fetchone()[0]
            days = con.execute("SELECT COUNT(DISTINCT arrived_at) FROM stg_raw_events").fetchone()[0]
            con.close()

        n_per_day = 50000 // 28
        assert count == n_per_day * 3
        assert days == 3


class TestRevenueMetrics:
    def test_materializes_with_significant_result(self, tmp_db):
        with patch("ab_testing_dagster.analytics.DB_PATH", tmp_db):
            result = materialize([ab_test_revenue_metrics])

        assert result.success
        meta = result.get_asset_materialization_events()[0].materialization.metadata
        assert meta["srm_passed"].value is True
        assert meta["sample_size"].value == 10000



class TestSegmentMetrics:
    def test_materializes_with_segments(self, tmp_db):
        with patch("ab_testing_dagster.analytics.DB_PATH", tmp_db):
            result = materialize([ab_test_segment_metrics])

        assert result.success
        meta = result.get_asset_materialization_events()[0].materialization.metadata
        assert meta["n_segments"].value >= 2
        assert meta["srm_passed"].value is True


class TestSequentialMetrics:
    def test_materializes_and_detects_effect(self, tmp_db):
        with patch("ab_testing_dagster.analytics.DB_PATH", tmp_db):
            result = materialize([ab_test_sequential_metrics])

        assert result.success
        meta = result.get_asset_materialization_events()[0].materialization.metadata
        assert meta["srm_passed"].value is True
        assert meta["n_looks"].value == 28
        assert meta["final_always_valid_p"].value < 0.05

    def test_confidence_interval_excludes_zero(self, tmp_db):
        with patch("ab_testing_dagster.analytics.DB_PATH", tmp_db):
            result = materialize([ab_test_sequential_metrics])

        meta = result.get_asset_materialization_events()[0].materialization.metadata
        assert meta["final_ci_lower"].value > 0
