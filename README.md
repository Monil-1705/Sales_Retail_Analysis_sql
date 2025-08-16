# Retail Sales Analysis (SQL Project)
## Project Overview

 - **This project focuses on analyzing retail sales data using SQL.**

 - **The dataset contains transaction-level information including customer demographics, product categories, sales amount, quantity, and time of purchase.**

 - **The goal is to perform data cleaning, exploratory data analysis (EDA), and business insights generation through SQL queries.**

## Dataset Description

The dataset (retail_sales) has the following columns:

| Column            | Description                                      |
| ----------------- | ------------------------------------------------ |
| `transactions_id` | Unique transaction identifier                    |
| `sale_date`       | Date of sale                                     |
| `sale_time`       | Time of sale                                     |
| `customer_id`     | Unique customer identifier                       |
| `gender`          | Gender of customer                               |
| `age`             | Age of customer                                  |
| `category`        | Product category (Clothing, Electronics, Beauty) |
| `quantity`        | Number of items purchased                        |
| `price_per_unit`  | Price per item                                   |
| `cogs`            | Cost of goods sold                               |
| `total_sale`      | Total sale value                                 |

## Data Cleaning

 - **Removed rows with null values in critical numeric fields (quantity, price_per_unit, cogs, total_sale).**

 - **Imputed missing values in the age column using the median age per gender & category.**

 - **Ensured data consistency across categories and transactions.**

## Key Business Questions Solved

 **The project answers 16 analytical questions using SQL:**

 - **Sales made on a specific date (2022-11-05).**

 - **Clothing sales with quantity > 3 in November 2022.**

 - **Total sales & orders for each category.**

 - **Average age of customers in the Beauty category.**

 - **Transactions with sales > 1000.**

 - **Transaction count by gender & category.**

 - **Best-selling month each year (using window functions).**

 - **Top 5 customers by total sales.**

 - **Customers who purchased from all categories.**

 - **Number of orders by shift (Morning, Afternoon, Evening).**

 - **Repeat vs One-time customers.**

 - **Top 10 customers by Customer Lifetime Value (CLV).**

 - **Category contribution % to overall sales.**

 - **Highest-selling day of the week.**

 - **Peak sales hour of the day.**

 - **Gross profit by category.**

## Insights Gained

 - **Electronics category contributes the highest % to overall sales.**

 - **Clothing generates the highest gross profit despite lower contribution %.**

 - **Sunday is the highest-selling day of the week.**

 - **Sales peak between 7 PM and 8 PM.**

 - **All customers in this dataset are repeat customers (no one-time buyers).**

 - **Top customers (IDs: 3, 1, 5, 2, 4) drive a large portion of total sales.**

## Tech Stack

 - **SQL (PostgreSQL)**

 - **Window Functions (RANK)**

 - **Aggregations & Grouping**

 - **CTEs (WITH clauses)**

 - **Data Cleaning with UPDATE, DELETE**

## Future Improvements

 - **Add visualization layer using Tableau/Power BI for interactive dashboards.**

 - **Perform RFM (Recency, Frequency, Monetary) analysis for customer segmentation.**

 - **Extend queries to support trend forecasting with time-series data.**

 - **Optimize performance with indexes on sale_date, category, and customer_id.**

## Files in Repository

 - **p1_Retail_Sales_Analysis.sql → Full SQL script with cleaning, queries, and insights.**

 - **retail_sales.csv  → Raw dataset.**

 - **README.md → Project documentation.**

## How to Run

 - **Create the retail_sales table in PostgreSQL (DDL included in .sql file).**

 - **Import dataset (COPY or INSERT).**

 - **Run queries from p1_Retail_Sales_Analysis.sql in sequence.**
 
 - **Review both query outputs and insights.**

### This project demonstrates how SQL alone can generate powerful business insights from retail sales data.
