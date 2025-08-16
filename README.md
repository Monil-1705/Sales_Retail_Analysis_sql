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

   
```sql
SELECT * FROM retail_sales
WHERE 
	transactions_id IS NULL OR
	sale_date IS NULL OR
	sale_time IS NULL OR
	customer_id IS NULL OR
	gender IS NULL OR
	age IS NULL OR
	category IS NULL OR
	quantity IS NULL OR
	price_per_unit IS NULL OR
	cogs IS NULL OR
	total_sale IS NULL;

-- There are 10 rows in which the 'age' column has null values and 3 rows in which the 'quantity','price_per_unit','cogs', and 'total_sale' column, all have missing values

-- DELETING the rows which have null values in 'quantity','price_per_unit','cogs', and 'total_sale' columns. 
DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL OR
	sale_date IS NULL OR
	sale_time IS NULL OR
	customer_id IS NULL OR
	gender IS NULL OR
	category IS NULL OR
	quantity IS NULL OR
	price_per_unit IS NULL OR
	cogs IS NULL OR
	total_sale IS NULL;

-- Filling the NULLs in 'age' column with Median age as per gender and category

UPDATE retail_sales r1
SET age = r2.median_age
FROM (
	SELECT 
		gender,
		category,
		ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY age)) AS median_age
	FROM retail_sales
	WHERE age IS NOT NULL
	GROUP BY gender, category
) r2
WHERE r1.age IS NULL
	AND r1.gender = r2.gender
	AND r1.category = r2.category;
```

## Key Business Questions Solved

 **The project answers 16 analytical questions using SQL:**

 - **1. Sales made on a specific date (2022-11-05).**
```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

 - **2. Clothing sales with quantity > 3 in November 2022.**
```sql
SELECT * FROM retail_sales
WHERE 
    category = 'Clothing'
    AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND quantity > 3;

			---------- OTHER WAY ------------

SELECT * FROM retail_sales
WHERE category = 'Clothing'
	AND EXTRACT(YEAR FROM sale_date) = 2022
	AND EXTRACT(MONTH FROM sale_date) = 11
	AND quantity > 3;
```

 - **3.Total sales & orders for each category.**
```sql
SELECT 
    category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM retail_sales
GROUP BY category;

```

 - **4. Average age of customers in the Beauty category.**
```sql
SELECT ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty';
```

 - **5. Transactions with sales > 1000.**
```sql
SELECT * FROM retail_sales
WHERE total_sale > 1000;
```

 - **6. Transaction count by gender & category.**
```sql
SELECT 
    category,
    gender,
    COUNT(*) as total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY 1;
```

 - **7. Best-selling month each year (using window functions).**
```sql
SELECT
	year,
	month,
	avg_sales
FROM (
	SELECT 
		year,
		month,
		avg_sales,
		RANK() OVER(PARTITION BY year ORDER BY avg_sales DESC) AS rank
	FROM (
		SELECT 
			EXTRACT(YEAR FROM sale_date) AS year,
			EXTRACT(MONTH FROM sale_date) AS month,
			ROUND(AVG(total_sale)::"numeric", 2) AS avg_sales
		FROM retail_sales
		GROUP BY 1, 2
	) AS monthly_sales
) AS ranked
WHERE rank = 1;
```

 - **8. Top 5 customers by total sales.**
```sql
SELECT
	customer_id,
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY SUM(total_sale) DESC
LIMIT 5;
```

 - **9. Customers who purchased from all categories.**
```sql
SELECT COUNT(*) AS count_of_customers_in_all_categories 
FROM (
	SELECT customer_id
	FROM retail_sales
	GROUP BY customer_id
	HAVING COUNT(DISTINCT category) = (
		SELECT COUNT(DISTINCT category)
		FROM retail_sales
	)
) AS t;
```

 - **10. Number of orders by shift (Morning, Afternoon, Evening).**
```sql
WITH hourly_sales AS (
	SELECT *,
		CASE
			WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift
	FROM retail_sales
)
SELECT 
	shift,
	count(*) AS total_orders
FROM hourly_sales
GROUP BY shift;
```

 - **11. Repeat vs One-time customers.**
```sql
SELECT 
	CASE 
		WHEN order_count = 1 THEN 'One_time'
		ELSE 'Repeat'
	END AS customer_type,
	COUNT(*) AS num_of_customers
FROM (
	SELECT 
		customer_id,
		COUNT(*) AS order_count
	FROM retail_sales
	GROUP BY customer_id
) t
GROUP BY customer_type;
```

 - **12. Top 10 customers by Customer Lifetime Value (CLV).**
```sql
SELECT 
	customer_id,
	SUM(total_sale) AS customer_lifetime_value
FROM retail_sales
GROUP BY customer_id
ORDER BY customer_lifetime_value DESC
LIMIT 10;
```

 - **13. Category contribution % to overall sales.**
```sql
SELECT 
	category,
	ROUND((SUM(total_sale) * 100 / SUM(SUM(total_sale)) OVER())::"numeric", 2) AS percentage_contribution
FROM retail_sales
GROUP BY category
ORDER BY percentage_contribution DESC;
```

 - **14. Highest-selling day of the week.**
```sql
SELECT
	TO_CHAR(sale_date, 'Day') AS weekday,
	SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;
```

 - **15. Peak sales hour of the day.**
```sql
SELECT
	EXTRACT(HOUR FROM sale_time) AS hour,
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;
```

 - **16. Gross profit by category.**
```sql
SELECT 
	category,
	ROUND(SUM(total_sale - cogs)::"numeric", 2) AS gross_profit
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;
```

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
