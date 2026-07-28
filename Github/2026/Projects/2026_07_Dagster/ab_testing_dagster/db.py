import os
from contextlib import contextmanager
from pathlib import Path

import pandas as pd

WAREHOUSE = os.environ.get("WAREHOUSE", "duckdb")

DBT_PROJECT_DIR = Path(__file__).joinpath("..", "..", "dbt_project").resolve()
DUCKDB_PATH = DBT_PROJECT_DIR / "dev.duckdb"


@contextmanager
def get_connection(read_only=False):
    if WAREHOUSE == "postgres":
        import psycopg2

        conn = psycopg2.connect(
            host=os.environ.get("PG_HOST", "localhost"),
            port=os.environ.get("PG_PORT", "5432"),
            user=os.environ.get("PG_USER", "dagster"),
            password=os.environ.get("PG_PASSWORD", "dagster"),
            dbname=os.environ.get("PG_DBNAME", "ab_testing"),
        )
        conn.set_session(readonly=read_only, autocommit=True)
        try:
            yield conn
        finally:
            conn.close()
    else:
        import duckdb

        conn = duckdb.connect(str(DUCKDB_PATH), read_only=read_only)
        try:
            yield conn
        finally:
            conn.close()


def write_dataframe(conn, df: pd.DataFrame, table: str):
    if WAREHOUSE == "postgres":
        from io import StringIO

        buf = StringIO()
        df.to_csv(buf, index=False, header=False)
        buf.seek(0)
        cur = conn.cursor()
        columns = ", ".join(df.columns)
        cur.copy_expert(
            f"COPY {table} ({columns}) FROM STDIN WITH CSV", buf
        )
        cur.close()
    else:
        conn.register("_tmp_df", df)
        conn.execute(f"INSERT INTO {table} SELECT * FROM _tmp_df")
        conn.unregister("_tmp_df")


def read_sql(conn, sql: str) -> pd.DataFrame:
    if WAREHOUSE == "postgres":
        return pd.read_sql(sql, conn)
    else:
        return conn.execute(sql).df()
