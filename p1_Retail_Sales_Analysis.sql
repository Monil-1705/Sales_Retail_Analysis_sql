-- Creating table

-- DROP TABLE IF EXISTS retail_sales;

-- CREATE TABLE retail_sales(
-- 	transactions_id INT PRIMARY KEY,
-- 	sale_date DATE,
-- 	sale_time TIME,
-- 	customer_id INT,
-- 	gender VARCHAR(6),
-- 	age INT,
-- 	category VARCHAR(15),
-- 	quantity INT,
-- 	price_per_unit FLOAT,
-- 	cogs FLOAT,
-- 	total_sale FLOAT
-- );

SELECT * FROM retail_sales
LIMIT 10;

SELECT COUNT(*) FROM retail_sales;

-- Data Cleaning

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

-- Data Exploration

-- How many sales we have?
SELECT COUNT(*) as total_sales FROM retail_sales;

-- How many uniuque customers we have ?

SELECT COUNT(DISTINCT customer_id) AS unique_customers FROM retail_sales;

-- How many unique categories we have ?

SELECT COUNT(DISTINCT category) AS total_categories FROM retail_sales;

SELECT DISTINCT category FROM retail_sales;


-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)



 -- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022

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


-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT 
    category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM retail_sales
GROUP BY category;

-- INSIGHT : The category with the most number of orders is 'Clothing'
-- 			 and category with the most total_sale is Electronics


-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- INSIGHT : Average age of the customers who purchased items from the 'Beauty' category is 40.42


-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT * FROM retail_sales
WHERE total_sale > 1000;


-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT 
    category,
    gender,
    COUNT(*) as total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY 1;

-- INSIGHT : Total Most transactions has been done by Females.  


-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

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

-- INSIGHT : In 2022, July was the best selling MONTH
--		and  In 2023, February was the best selling MONTH
--      and  overall July, 2022 was the best selling MONTH


-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

SELECT
	customer_id,
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY SUM(total_sale) DESC
LIMIT 5;

-- INSIGHT : Customers with customer_id 3, 1, 5, 2, and 4 are the top 5 customers based on the total sales.


-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

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

-- INSIGHT : There are total 128 customers who have purchased at least one item from each category (i.e. Clothing, Electronics, and Beauty) 


-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)

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

-- INSIGHT : The most number of orders had come in evening.


-- Q.11  Write a SQL query to get number of Repeat Customers and One-time Customers

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

-- INSIGHT : In this dataset, all the customers have more than one transactions. So all the customers are repeated and not a single customer is one_time.


-- Q.12 Write a query to find the TOP 10 customers based on Customer Lifetime Value (CLV). CLV = total_sales made by the customer.

SELECT 
	customer_id,
	SUM(total_sale) AS customer_lifetime_value
FROM retail_sales
GROUP BY customer_id
ORDER BY customer_lifetime_value DESC
LIMIT 10;

-- Q.13 Write a query to find the Category Contribution % to Total Sales

SELECT 
	category,
	ROUND((SUM(total_sale) * 100 / SUM(SUM(total_sale)) OVER())::"numeric", 2) AS percentage_contribution
FROM retail_sales
GROUP BY category
ORDER BY percentage_contribution DESC;

-- INSIGHT : Electronics category has the highest % of contribution in the total_sales


-- Q.14 Write a query to find the Highest Selling Day of the Week

SELECT
	TO_CHAR(sale_date, 'Day') AS weekday,
	SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;

-- INSIGHT : Sunday is the Highest Selling Day of the Week


-- Q.15 Write a query to find Peak Hour of Sales

SELECT
	EXTRACT(HOUR FROM sale_time) AS hour,
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;

-- INSIGHT : During 7 PM to 8 PM in the evening, the sales peak.


-- Q.16 : Write a query to find Gross Profit by Category

SELECT 
	category,
	ROUND(SUM(total_sale - cogs)::"numeric", 2) AS gross_profit
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;

-- INSIGHT : Clothing has the highest gross profit.ABORT
