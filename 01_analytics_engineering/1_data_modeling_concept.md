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
