### 1.1 Data Warehouse Data Modeling

Data modeling is a crucial aspect of data warehousing. It involves designing the structure of your data warehouse to ensure efficient data storage, retrieval, and analysis. In this module, we'll explore various concepts related to data modeling.

### 2.1 Understanding Facts and Dimensional Tables

In data warehousing, we distinguish between two types of tables:

- **Facts**: These tables store quantitative data, such as sales figures or quantities, and are typically the focus of analysis.

- **Dimensional Tables**: These tables provide context to facts and contain descriptive attributes like product names, customer details, or dates.

**Technical Example using BigQuery Public Dataset:**

Let's consider a retail dataset in BigQuery. Sales data (facts) could be stored in one table, while information about products, customers, and dates (dimensions) could be stored in separate dimensional tables.

```sql
-- Creating a Sales Facts Table
CREATE TABLE my_project.my_dataset.sales_facts AS
SELECT
  *
FROM
  `bigquery-public-data.samples.sales`;

-- Creating a Product Dimension Table
CREATE TABLE my_project.my_dataset.product_dimension AS
SELECT
  product_id,
  product_name,
  category
FROM
  `bigquery-public-data.samples.products`;
```


### 3.1 One Starry and Snowy Night
In data modeling, two common schema designs are the Star Schema and Snowflake Schema.

- Star Schema: Involves a centralized fact table connected to dimension tables, forming a star-like structure.

- Snowflake Schema: Dimensional tables are further normalized into sub-dimensions, creating a snowflake-like structure.

```sql
-- Creating a Star Schema
CREATE TABLE my_project.my_dataset.sales_facts AS
SELECT
  *
FROM
  `bigquery-public-data.samples.sales`;

CREATE TABLE my_project.my_dataset.product_dimension AS
SELECT
  product_id,
  product_name
FROM
  `bigquery-public-data.samples.products`;

CREATE TABLE my_project.my_dataset.customer_dimension AS
SELECT
  customer_id,
  customer_name
FROM
  `bigquery-public-data.samples.customers`;

```

### 4.1 Fact or Dimension?
Identifying whether an attribute should be stored in a fact table or a dimension table depends on its nature. Facts are numerical and additive, while dimensions are descriptive.

```sql
-- Creating a Sales Facts Table
CREATE TABLE my_project.my_dataset.sales_facts AS
SELECT
  order_id,
  product_id,
  sales_amount
FROM
  `bigquery-public-data.samples.sales`;

-- Creating a Product Dimension Table
CREATE TABLE my_project.my_dataset.product_dimension AS
SELECT
  product_id,
  product_name,
  category
FROM
  `bigquery-public-data.samples.products`;

```

### Kimball's Four Step Process
Kimball's data warehousing methodology involves four key steps:

- Select the Business Process: Identify the business process you want to model.

- Declare the Grain: Define the level of detail for your data, known as the grain.

- Identify the Facts: Determine what facts you need to measure the business process.

- Choose Dimensions: Select dimensions that provide context to your facts.


Let's apply Kimball's four-step process to a sales dataset.

- Select the Business Process: We want to analyze sales.

- Declare the Grain: We'll choose the order-level grain.

- Identify the Facts: Sales revenue, quantity sold, and profit are key facts.

- Choose Dimensions: We'll select product, customer, and date dimensions.

```sql
-- Creating Tables with Kimball's Approach
-- Fact Table (Sales)
CREATE TABLE my_project.my_dataset.sales_facts AS
SELECT
  order_id,
  product_id,
  customer_id,
  order_date,
  sales_amount,
  quantity_sold,
  profit
FROM
  `bigquery-public-data.samples.sales`;

-- Dimension Tables (Product, Customer, Date)
CREATE TABLE my_project.my_dataset.product_dimension AS
SELECT
  product_id,
  product_name,
  category
FROM
  `bigquery-public-data.samples.products`;

-- Similar tables for customer and date dimensions

```

### Ordering Kimball's Steps
The order in which you perform Kimball's steps can impact your data warehouse design. It's crucial to start with the right business process and grain definition before identifying facts and dimensions.

```sql
-- Incorrect Order: Starting with the wrong business process
CREATE TABLE my_project.my_dataset.sales_facts AS
SELECT
  customer_id,
  product_id,
  sales_amount
FROM
  `bigquery-public-data.samples.sales`;

-- Correct Order: Identifying the right business process
CREATE TABLE my_project.my_dataset.sales_facts AS
SELECT
  order_id,
  product_id,
  customer_id,
  sales_amount
FROM
  `bigquery-public-data.samples.sales`;

```

### 7.1 Deciding on the Grain
The grain defines the level of detail in your data. It's crucial to choose an appropriate grain that aligns with your business objectives.

```sql
-- Order-Level Grain (Summary)
CREATE TABLE my_project.my_dataset.sales_order_level AS
SELECT
  order_id,
  SUM(sales_amount) AS total_sales
FROM
  `bigquery-public-data.samples.sales`
GROUP BY
  order_id;

-- Line-Item-Level Grain (Detailed)
CREATE TABLE my_project.my_dataset.sales_line_item_level AS
SELECT
  order_id,
  product_id,
  sales_amount
FROM
  `bigquery-public-data.samples.sales`;

```

### 8.1 Selecting Reasonable Facts
Not all numerical attributes should become facts. It's essential to choose facts that provide meaningful insights and align with your business goals.

```sql
-- Selecting Reasonable Facts
CREATE TABLE my_project.my_dataset.sales_facts AS
SELECT
  order_id,
  product_id,
  customer_id,
  sales_amount,
  profit
FROM
  `bigquery-public-data.samples.sales`;

```

### 9.1 Slowly Changing Dimensions
Slowly Changing Dimensions (SCDs) refer to dimension attributes that change over time. There are three types of SCDs: Type I, Type II, and Type III, each with its own handling strategy.

```sql
-- Handling Type II Slowly Changing Dimension (Customer)
-- Create a new record for the changed attribute
INSERT INTO my_project.my_dataset.customer_dimension
SELECT
  customer_id,
  'John Doe' AS customer_name,
  'New Address' AS address
FROM
  `bigquery-public-data.samples.customers`
WHERE
  customer_id = '123';

-- Deactivate the old record by setting an end date
UPDATE my_project.my_dataset.customer_dimension
SET
  end_date = '2023-10-31'
WHERE
  customer_id = '123'
AND
  end_date IS NULL;

```

### 10.1 Row vs. Column Data Store
Data warehouses can use row-based or column-based storage. Each has its advantages and is suited for different types of queries.

```sql
-- Row-Based Storage
SELECT
  *
FROM
  my_project.my_dataset.sales_facts
WHERE
  product_id = 'ABC';

-- Column-Based Storage
SELECT
  product_id,
  SUM(sales_amount) AS total_sales
FROM
  my_project.my_dataset.sales_facts
GROUP BY
  product_id;

```

### 11.1 Categorizing Row and Column Store Scenarios
Different scenarios require different storage approaches. Understanding when to use row or column stores is essential.

```sql
-- Row-Based Store Scenario (Individual Record Retrieval)
SELECT
  *
FROM
  my_project.my_dataset.product_dimension
WHERE
  product_id = 'XYZ';

-- Column-Based Store Scenario (Aggregated Analysis)
SELECT
  category,
  SUM(sales_amount) AS total_sales
FROM
  my_project.my_dataset.sales_facts
GROUP BY
  category;

```

### 12.1 Why is Column Store Faster?
Column stores are often faster for analytical queries because they store data in a column-wise format, which reduces I/O operations and speeds up query performance.

```sql
-- Analytical Query on Row Store
SELECT
  product_category,
  SUM(sales_amount) AS total_sales
FROM
  my_project.my_dataset.sales_facts
GROUP BY
  product_category;

-- Analytical Query on Column Store
SELECT
  product_category,
  SUM(sales_amount) AS total_sales
FROM
  my_project.my_dataset.sales_facts_columnar
GROUP BY
  product_category;

```

### Which Queries are Faster?
The choice between row and column stores depends on the types of queries you frequently run. Analytical queries benefit from column stores, while transactional queries may favor row stores.

```sql
-- Transactional Query on Row Store
SELECT
  *
FROM
  my_project.my_dataset.product_dimension
WHERE
  product_id = 'XYZ';

-- Analytical Query on Column Store
SELECT
  product_category,
  SUM(sales_amount) AS total_sales
FROM
  my_project.my_dataset.sales_facts_columnar
GROUP BY
  product_category;

```