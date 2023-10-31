# Day 2: Data Warehouse Architectures and Properties

### 1.1 What are the different layers of a data warehouse?

A data warehouse typically consists of several layers that work together to provide a comprehensive solution for data storage and analysis. The key layers include:

- **Data Sources**: This is where data originates, such as transactional databases, external data feeds, and logs.

- **Data Staging**: Data is extracted from source systems and loaded into a staging area for cleaning and transformation.

- **Data Integration**: In this layer, data from various sources is integrated and transformed into a common format.

- **Data Storage**: Data is stored in a structured and optimized format for querying and analysis.

- **Data Access**: This layer provides tools and interfaces for users to access and query the data.

- **Data Presentation**: The presentation layer is where data is visualized and presented to end-users through reports, dashboards, and analytics tools.

**Technical Example using BigQuery Public Dataset:**

Let's explore these layers using a BigQuery public dataset. We'll start by extracting data from the dataset, transforming it, and finally presenting it using BigQuery.

```sql
-- Example query to extract data from a public dataset and load it into a staging table
SELECT
  *
FROM
  `bigquery-public-data.samples.wikipedia`
LIMIT
  10;
```


##2.1 Understanding ETL
ETL stands for Extract, Transform, Load. It is a crucial process in a data warehouse that involves:

- Extract: Retrieving data from source systems.

- Transform: Cleaning, enriching, and structuring the data for analysis.

- Load: Loading the transformed data into the data warehouse for storage and analysis.

ETL is essential to ensure that data is accurate and ready for reporting and analysis.

Technical Example using BigQuery Public Dataset:
```sql
-- Example ETL operation to transform data
-- Extract data
CREATE OR REPLACE TABLE my_project.my_dataset.staging_table AS
SELECT
  *
FROM
  `bigquery-public-data.samples.wikipedia`
WHERE
  date >= '2023-01-01';

-- Transform data
CREATE OR REPLACE TABLE my_project.my_dataset.transformed_table AS
SELECT
  page_title,
  COUNT(*) AS page_views
FROM
  my_project.my_dataset.staging_table
GROUP BY
  page_title;

-- Load transformed data
CREATE OR REPLACE TABLE my_project.my_dataset.final_table AS
SELECT
  *
FROM
  my_project.my_dataset.transformed_table;
```
Let's perform a simple ETL operation using BigQuery. We'll extract data, apply a transformation, and load it into a new table.


### Data Warehouse Architectures
Data warehouses can have various architectures, but two common approaches are:

- Top-Down: Data is centralized and integrated before being presented to users.

- Bottom-Up: Data marts are created for specific business units and then integrated.

Technical Example using BigQuery Public Dataset:
```sql
-- Top-Down Approach
SELECT
  *
FROM
  `bigquery-public-data.samples.wikipedia`
WHERE
  date >= '2023-01-01';

-- Bottom-Up Approach
SELECT
  *
FROM
  `bigquery-public-data.samples.wikipedia`
WHERE
  date >= '2023-01-01'
AND
  page_title = 'Your Specific Business Unit';
```

### OLAP and OLTP Systems
OLAP (Online Analytical Processing) and OLTP (Online Transaction Processing) are two distinct database systems:

- OLAP: Designed for complex querying and analysis, optimized for data warehousing.

- OLTP: Designed for transactional tasks, optimized for handling frequent, small data changes.

Technical Example using BigQuery Public Dataset:
```sql
-- OLAP Query
SELECT
  product_category,
  SUM(sales_amount) AS total_sales
FROM
  `bigquery-public-data.samples.natality`
GROUP BY
  product_category;

-- OLTP Query
SELECT
  customer_name,
  order_date,
  order_total
FROM
  `my_project.my_dataset.orders`
WHERE
  order_date >= '2023-01-01';
```

### OLAP Data Cube
The OLAP data cube is a multidimensional representation of data that allows for efficient slicing, dicing, and drilling to explore data from different perspectives.

Technical Example using BigQuery Public Dataset:
```sql
-- Creating a basic OLAP cube
SELECT
  product_category,
  EXTRACT(MONTH FROM order_date) AS order_month,
  SUM(sales_amount) AS total_sales
FROM
  `bigquery-public-data.samples.natality`
GROUP BY
  product_category,
  order_month;
```
We can create a basic OLAP cube in BigQuery by using a combination of GROUP BY and aggregation functions.

### OLAP vs. OLTP Scenarios
Understanding when to use OLAP and OLTP systems depends on your specific use cases:

- OLAP is suitable for complex analysis and reporting.
- OLTP is ideal for day-to-day transactional operations.

```sql
-- OLAP Scenario: Sales Analysis
SELECT
  product_category,
  SUM(sales_amount) AS total_sales
FROM
  `bigquery-public-data.samples.natality`
GROUP BY
  product_category;

-- OLTP Scenario: Order Processing
SELECT
  customer_name,
  order_date,
  order_total
FROM
  `my_project.my_dataset.orders`
WHERE
  order_date >= '2023-01-01';

```

### OLTP
OLTP systems are designed for transactional processing, capturing real-time data changes, and supporting frequent data updates.

```sql
-- Simulating OLTP Order Insert
INSERT INTO
  `my_project.my_dataset.orders` (customer_name, order_date, order_total)
VALUES
  ('DF 11', '2023-10-31', 150.99);
```