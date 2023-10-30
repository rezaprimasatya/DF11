# Anatomy of a dbt model: written mode vs compiled sources

At the beginning of the model, we are going to use config macros inside the jinja block. We can use the macros function to help us to generate the DDL code to create a materialization model when it is compiled.


Materializations are strategies for persisting dbt models in a data warehouse (https://docs.getdbt.com/docs/build/materializations).

dbt has 4 materialization strategies:

## view
- table: a materialized table will drop the model if it already exists in the data warehouse and create a new table.
    - incremental: a materialization strategy that allows us to run our model incrementally in a table. So, we can only run the model, transform and insert the latest data to an existing table.
    - ephemeral: similar to having a CTE separated in another file that we could embed that.

## Seeds, Sources and Ref
There are 3 ways to load data to our data warehouse:

### sources
- sources are the data loaded to our data warehouse that we use as sources for our models.
- configuration is defined in a .yaml file.
- then, in a select statement, we can use macro source to resolve the name to the right schema.
- the advantage of defining source in a .yml file is: we can validate the freshness of our sources https://docs.getdbt.com/reference/resource-properties/freshness.
- will resolve the correct schema for us. build the dependencies -> build the lineage automatically.

### seeds
- it is simply a copy command. It copies the CSV files under seed folder to data warehouse.
- it is recommended for data that doesn’t change frequently, otherwise create a data pipeline.
- we have the benefit of version control since we store the CSV files in our repository, so the data changes is tracked via version control.

### ref
- ref is a macro that underlying tables and views that were built in the data warehouse
- ref runs the same code in any environment, it will resolve the correct schema.
- Dependencies are built automatically; ref encapsulates the location of data.