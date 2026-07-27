FROM python:3.12-slim

WORKDIR /opt/dagster/app

RUN pip install --no-cache-dir uv

COPY pyproject.toml .
COPY ab_testing_dagster/ ab_testing_dagster/
COPY dbt_project/ dbt_project/

RUN uv pip install --system -e .

ENV DAGSTER_HOME=/opt/dagster/dagster_home
RUN mkdir -p $DAGSTER_HOME

COPY dagster.yaml $DAGSTER_HOME/dagster.yaml
COPY workspace.yaml $DAGSTER_HOME/workspace.yaml

EXPOSE 3000

CMD ["dagster-webserver", "-h", "0.0.0.0", "-p", "3000", "-w", "/opt/dagster/dagster_home/workspace.yaml"]
