-- Step 1: Assess Change over Time --

	-- Check the data for missing values

SELECT order_date, sales_amount
From gold_fact_sales
WHERE order_date IS NOT NULL
ORDER BY order_date ASC
;

	-- Exclude Rows without dates

SELECT order_date, sales_amount
From gold_fact_sales
WHERE order_date > 2010-01-01
ORDER BY order_date ASC
;

	-- Total sale per day

SELECT order_date, 
SUM(sales_amount) AS total_sales
From gold_fact_sales
WHERE order_date > 2010-01-01
GROUP BY order_date
ORDER BY order_date ASC
;

	-- Total sales per year

SELECT 
YEAR(order_date) AS order_year, 
SUM(sales_amount) AS total_sales
From gold_fact_sales
WHERE order_date > 2010-01-01
GROUP BY order_year
ORDER BY order_year ASC
;

	-- Total sales and customers per year

SELECT 
YEAR(order_date) AS order_year, 
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) as total_customers
From gold_fact_sales
WHERE order_date > 2010-01-01
GROUP BY order_year
ORDER BY order_year ASC
;

	-- Total sales, customers, and units sold per year

SELECT 
YEAR(order_date) AS order_year, 
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as units_sold
From gold_fact_sales
WHERE order_date > 2010-01-01
GROUP BY order_year
ORDER BY order_year ASC
;

	-- Most Profitable Months: Total sales, customers, and units sold per month

SELECT 
MONTH(order_date) AS order_month, 
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as units_sold
From gold_fact_sales
WHERE order_date > 2010-01-01
GROUP BY order_month
ORDER BY order_month ASC
;

	-- Most Profitable Months By Year: Total sales, customers, and units sold per month each year

SELECT 
YEAR(order_date) AS order_year, 
MONTH(order_date) AS order_month, 
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as units_sold
From gold_fact_sales
WHERE order_date > 2010-01-01
GROUP BY order_year, order_month
ORDER BY order_year, order_month ASC
;

SELECT 
DATE_FORMAT(order_date, '%Y-%m') AS order_year_month, 
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as units_sold
From gold_fact_sales
WHERE order_date > 2010-01-01
GROUP BY order_year_month
ORDER BY order_year_month ASC
;