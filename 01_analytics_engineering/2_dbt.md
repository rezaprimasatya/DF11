<p align="center">
  <img src="https://raw.githubusercontent.com/dbt-labs/dbt/ec7dee39f793aa4f7dd3dae37282cc87664813e4/etc/dbt-logo-full.svg" alt="dbt logo" width="500"/>
</p>
<p align="center">
  <a href="https://github.com/dbt-labs/dbt-bigquery/actions/workflows/main.yml">
    <img src="https://github.com/dbt-labs/dbt-bigquery/actions/workflows/main.yml/badge.svg?event=push" alt="Unit Tests Badge"/>
  </a>
  <a href="https://github.com/dbt-labs/dbt-bigquery/actions/workflows/integration.yml">
    <img src="https://github.com/dbt-labs/dbt-bigquery/actions/workflows/integration.yml/badge.svg?event=push" alt="Integration Tests Badge"/>
  </a>
</p>

**[dbt](https://www.getdbt.com/)** enables data analysts and engineers to transform their data using the same practices that software engineers use to build applications.

dbt is the T in ELT. Organize, cleanse, denormalize, filter, rename, and pre-aggregate the raw data in your warehouse so that it's ready for analysis.

## dbt-bigquery

The `dbt-bigquery` package contains all of the code enabling dbt to work with Google BigQuery. For
more information on using dbt with BigQuery, consult [the docs](https://docs.getdbt.com/docs/profile-bigquery).

## Getting started

- [Install dbt](https://docs.getdbt.com/docs/installation)

```sh
pip install dbt-bigquery
```

This will install dbt-core and dbt-postgres only:

```sh
Core:
  - installed: 1.6.6
  - latest:    1.6.6 - Up to date!

Plugins:
  - bigquery: 1.6.7 - Up to date!
```

## Upgrade adapters
```sh
pip install --upgrade dbt-bigquery
```

## Install dbt-core only
```sh
pip install --upgrade dbt-core
```

