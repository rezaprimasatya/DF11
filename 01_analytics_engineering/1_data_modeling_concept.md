# Data Modeling Concepts

## ETL vs ELT
![etlvselt](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*oDC1xiYkyjZezvUETYkrGg.png)

```sh
ETL is the process of extracting the sources, then transforming and loading them into a data warehouse.
```

pros:
- slightly more stable and compliant data analysis.
- lower storage cost (only transformed data is stored)

cons:
- take a longer time to implement data analysis, because the data has to be transformed before going to a data warehouse.
- higher compute costs

```sh
ELT is the process of transforming the data once it is in the data warehouse.
```

pros:
- faster and more flexible for data analysis because the raw data has already been loaded into the data warehouse
- lower maintenance
- lower storage cost (depends on the cloud data warehousing’s storage cost)

cons:
- higher data transformation/query cost (if the data transformation process is not optimized)


# Kimball's Dimensional Modeling

Kimball's Dimensional Modeling is a design concept used in data warehousing to simplify the database structure so it can be easily understood and navigated by analysts, enabling faster query performance and ease of use. This technique involves the creation of "fact" and "dimension" tables.

## Core Components

- **Fact Tables:** These contain the measures, metrics, or facts of a business process. It’s usually numeric transaction data.
- **Dimension Tables:** These are descriptive or categorical information and are used to slice the data within the fact tables.

## Principles

1. **Simplicity:** Structures are designed to be understandable and navigable by users.
2. **Consistency:** Conformity in naming conventions, measurement units, attribute behaviors, etc., across various dimension tables.
3. **Adaptability:** Should be flexible for further expansion or scaling.

## Star Schema

The basic arrangement of Kimball's Dimensional Modeling is the "star schema." In this, the central fact table is surrounded by dimension tables, each relation representing a 'point' in the 'star'.

---

## Technical Example: Sales Data Warehouse

Imagine a business scenario where we are designing a data warehouse for sales.

### Fact Table

- **FactSales**
  - Sale_ID (Primary Key)
  - Date_Key (Foreign Key)
  - Customer_Key (Foreign Key)
  - Product_Key (Foreign Key)
  - Sales_Amount
  - Quantity_Sold

### Dimension Tables

- **DimDate**
  - Date_Key (Primary Key)
  - Date
  - Month
  - Quarter
  - Year

- **DimCustomer**
  - Customer_Key (Primary Key)
  - Customer_Name
  - Gender
  - Email
  - Country

- **DimProduct**
  - Product_Key (Primary Key)
  - Product_Name
  - Category
  - Price

### SQL Query Example

To illustrate the interaction with this model, here’s an example SQL query that an analyst might use to summarize sales by product category and year.

```sql
SELECT 
  P.Category AS Product_Category, 
  D.Year AS Year, 
  SUM(F.Sales_Amount) AS Total_Sales
FROM 
  FactSales F
  JOIN DimDate D ON F.Date_Key = D.Date_Key
  JOIN DimProduct P ON F.Product_Key = P.Product_Key
GROUP BY 
  P.Category, 
  D.Year
ORDER BY 
  Total_Sales DESC;
```



# Why implement a Star Schema?
A star schema simplifies complex data structures into a central fact table surrounded by dimension tables. This structure streamlines data access and reporting, making it an ideal choice for large datasets like the NYC Taxi dataset.

### Here’s why a star schema is beneficial:

- Performance: Star schemas optimize query performance, as they reduce the complexity of joins and aggregations. Moreover the dimensions are also denormalised.
- Simplicity: They provide a straightforward way to organize data for analysis, making it easier for data analysts and business users to work with the data.
- Scalability: Star schemas can be expanded by adding more dimensions as needed, allowing for flexible and scalable data analysis.

### Implementing Star Schema on New York taxi dataset

Let’s see how we can implement Star schema on BigQuery. For this tutorial we will be using New York taxi public dataset which is available on BigQuery’s public dataset and see how we can create facts and dimensions from it. We’ll create a three dimensions and one fact table.

New York taxi dataset schema:

```sh
    vendor_id: STRING -- A unique identifier for each taxi trip.
    pickup_datetime: TIMESTAMP -- The date and time when the trip started.
    dropoff_datetime: TIMESTAMP -- The date and time when the trip ended.
    passenger_count: INT64 -- The number of passengers in the taxi.
    trip_distance: NUMERIC -- The distance of the taxi trip. 
    rate_code: STRING -- A code that specifies the rate or pricing structure for the trip.
    store_and_fwd_flag: STRING -- A flag indicating whether the trip data was stored in the vehicle before being forwarded to the server.
    payment_type: STRING -- Payment method used for the taxi ride. 
    fare_amount: NUMERIC -- The base fare amount for the trip.
    extra: NUMERIC -- An additional numeric amount added to the fare. This could include extra charges for specific circumstances or services.
    mta_tax: NUMERIC -- The Metropolitan Transportation Authority (MTA) tax amount added to the fare. This is a tax collected to support public transportation in New York City.
    tip_amount: NUMERIC -- The tip amount given by the passenger.
    tolls_amount: NUMERIC -- The toll amount paid during the trip.
    imp_surcharge: NUMERIC -- Surcharge amount related to specific regulations or fees.
    airport_fee: NUMERIC -- Fee related to airport pickups or drop-offs if applicable.
    total_amount: NUMERIC -- The total fare amount paid by the passenger.
    pickup_location_id: STRING -- An identifier for the pickup location. This could be a code or reference to a specific location.
    dropoff_location_id: STRING -- An identifier for the drop-off location. Similar to pickup_location_id, this represents the destination of the trip.
```

From this schema first we need to split the fields which are considered as facts and which are considered as dimensions.

### Facts
```sh
passenger_count
trip_distance
fare_amount
extra
mta_tax
tip_amount
tolls_amount
imp_surcharge
airport_fee
total_amount
vendor_id
```

### Dimension
```sh
vendor_id
pickup_datetime
dropoff_datetime
rate_code
store_and_fwd_flag
payment_type
pickup_location_id
dropoff_location_id
```


## Let's try

### Fact Table

```sql
-- Create fact table
CREATE OR REPLACE TABLE df11-403602.nyc_taxi.fact_trips AS
SELECT
  CAST(vendor_id AS INT) AS vendor_id
  passenger_count,
  trip_distance,
  fare_amount,
  extra,
  mta_tax,
  tip_amount,
  tolls_amount,
  imp_surcharge,
  airport_fee,
  total_amount,
  pickup_datetime,
  dropoff_datetime,
  CAST(payment_type AS INT) AS payment_id
FROM
  `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`
```


### Dimension Tables

- Time Dimension

```sql
-- Create Time Dimension Table
CREATE OR REPLACE TABLE df11-403602.nyc_taxi.dim_time AS
SELECT
  pickup_datetime AS pickup_datetime,
  dropoff_datetime AS dropoff_datetime,
  EXTRACT(YEAR FROM pickup_datetime) AS pickup_year,
  EXTRACT(MONTH FROM pickup_datetime) AS pickup_month,
  EXTRACT(DAY FROM pickup_datetime) AS pickup_day,
  EXTRACT(HOUR FROM pickup_datetime) AS pickup_hour,
  EXTRACT(DAYOFWEEK FROM pickup_datetime) AS pickup_day_of_week,
  EXTRACT(YEAR FROM dropoff_datetime) AS dropoff_year,
  EXTRACT(MONTH FROM dropoff_datetime) AS dropoff_month,
  EXTRACT(DAY FROM dropoff_datetime) AS dropoff_day,
  EXTRACT(HOUR FROM dropoff_datetime) AS dropoff_hour,
  EXTRACT(DAYOFWEEK FROM dropoff_datetime) AS dropoff_day_of_week
FROM 
  `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`;
```

- Payment Dimension
```sql
-- Create a dimension table for Payment Method
CREATE OR REPLACE TABLE df11-403602.nyc_taxi.dim_payment
(
  payment_id INT,
  payment_detail STRING,
);

INSERT INTO df11-403602.nyc_taxi.dim_payment
(payment_id, payment_detail)
VALUES
(1, 'Credit card'),
(2, 'Cash'),
(3, 'No charge'),
(4, 'Dispute'),
(5, 'Unknown'),
(6, 'Voided trip');
```

- Vendor Dimension

```sql
-- Create a dimension table for Payment Method
CREATE OR REPLACE TABLE df11-403602.nyc_taxi.dim_vendor
(
  vendor_id INT,
  vendor_name STRING,
  vendor_address STRING
);

INSERT INTO df11-403602.nyc_taxi.dim_payment
(payment_id, payment_detail)
VALUES
(1, 'Creative Mobile Technologies, LLC'),
(2, 'VeriFone Inc');
```

Now our fact table is surrounded by dimension tables.
Let’s now query the entire data by combining dimension tables with fact tables using joins.
```sql
SELECT
  passenger_count,
  trip_distance,
  fare_amount,
  extra,
  mta_tax,
  tip_amount,
  tolls_amount,
  imp_surcharge,
  airport_fee,
  total_amount,
  fact_trips.pickup_datetime,
  dim_time.pickup_year,
  dim_time.pickup_month,
  dim_time.pickup_day,
  fact_trips.dropoff_datetime,
  -- It seems like you've repeated 'dim_time.dropoff_datetime' multiple times. You should list it only once.
  dim_time.dropoff_datetime, 
  fact_trips.vendor_id,
  dim_vendor.vendor_name,
  fact_trips.payment_id,
  dim_payment.payment_detail
FROM
  df11-403602.nyc_taxi.fact_trips AS fact_trips
JOIN
  df11-403602.nyc_taxi.dim_time AS dim_time
ON
  fact_trips.pickup_datetime = dim_time.pickup_datetime AND fact_trips.dropoff_datetime = dim_time.dropoff_datetime
JOIN
  df11-403602.nyc_taxi.dim_vendor AS dim_vendor
ON
  fact_trips.vendor_id = dim_vendor.vendor_id
JOIN
  df11-403602.nyc_taxi.dim_payment AS dim_payment
ON
  fact_trips.payment_id = dim_payment.payment_id
```
