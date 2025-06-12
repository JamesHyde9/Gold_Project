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

-- Step 2: Cumulative Analysis --

		-- Tasks: Calculate the total sales per month 
		-- and running total of sales over time

	-- Total sales per month

SELECT 
DATE_FORMAT(order_date, '%Y-%m') AS order_year_month, 
SUM(sales_amount) AS total_sales
FROM gold_fact_sales
WHERE order_date > 2010-01-01
GROUP BY order_year_month
ORDER BY order_year_month ASC
;

	-- Running total

SELECT
order_year_month, 
total_sales,
SUM(total_sales) OVER (ORDER BY order_year_month) AS running_total_sales
FROM
(
SELECT 
DATE_FORMAT(order_date, '%Y-%m') AS order_year_month, 
SUM(sales_amount) AS total_sales
FROM gold_fact_sales
WHERE order_date > 2010-01-01
GROUP BY order_year_month
) t
;

	-- Moving average
    
    SELECT
order_year_month, 
total_sales,
SUM(total_sales) OVER (ORDER BY order_year_month) AS running_total_sales,
AVG(avg_price) OVER (ORDER BY order_year_month) AS moving_average_price
FROM
(
SELECT 
DATE_FORMAT(order_date, '%Y-%m') AS order_year_month, 
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold_fact_sales
WHERE order_date > 2010-01-01
GROUP BY order_year_month
) t
;

-- Step3: Proformancec Analysis --
/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */

	-- yearly proformance of product
    
SELECT 
YEAR(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold_fact_sales f
	left join gold_dim_products p
    ON f.product_key = p.product_key
WHERE order_date > 2010-01-01
GROUP BY YEAR(f.order_date),
product_name
;

	-- Comare avgerage sales to the proformance of the product
    
WITH yearly_product_sales AS (
SELECT 
YEAR(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold_fact_sales f
	left join gold_dim_products p
    ON f.product_key = p.product_key
WHERE order_date > 2010-01-01
GROUP BY YEAR(f.order_date),
product_name
) 
SELECT 
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
	WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
    ELSE 'Avg'
END avg_change
FROM yearly_product_sales
ORDER BY product_name, order_year
;

	-- Year-Over-Year Analysis

WITH yearly_product_sales AS (
SELECT 
YEAR(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold_fact_sales f
	left join gold_dim_products p
    ON f.product_key = p.product_key
WHERE order_date > 2010-01-01
GROUP BY YEAR(f.order_date),
product_name
) 
SELECT 
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
	WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
    ELSE 'Avg'
END avg_change,
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
    ELSE 'No Change'
END py_change
FROM yearly_product_sales
ORDER BY product_name, order_year
;

-- Step 4: Part-To-Whole Analysis

	-- Find which catagories contribute the most to overall sale

SELECT
category,
sales_amount
FROM gold_fact_sales f
LEFT JOIN gold_dim_products p 
ON p.product_key = f.product_key
;

SELECT
category,
SUM(sales_amount) total_sales
FROM gold_fact_sales f
LEFT JOIN gold_dim_products p 
ON p.product_key = f.product_key
GROUP BY category
;

WITH category_sales AS (
SELECT
category,
SUM(sales_amount) total_sales
FROM gold_fact_sales f
LEFT JOIN gold_dim_products p 
ON p.product_key = f.product_key
GROUP BY category)

SELECT 
category,
total_sales,
SUM(total_sales) OVER () overall_sales,
CONCAT(ROUND((total_sales / SUM(total_sales) OVER ())*100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC
;

-- Step 5: Data Segmentation

	/* Segment prducts into cost ranges and
    count how many products fall into each segment*/

	-- Segment prducts into cost ranges

SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
    WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
    ELSE 'Above 1000'
END cost_range
FROM gold_dim_products
;

	-- Number of products in each cost range

WITH product_segments AS (
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
    WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
    ELSE 'Above 1000'
END cost_range
FROM gold_dim_products)

SELECT
cost_range,
COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC
;

	/* Group customers into three segments based on their spending behavior:
		- VIP: Customers with at least 12 months of history and spending more than $5,000.
        - Regular: Customers with at least 12 months of history but spending $5,000 or less.
        - New: Customer with less than 12 months of history.
	And find the total number of customers by each group */
    
SELECT
c.customer_key,
f.sales_amount,
f.order_date
FROM gold_fact_sales f
LEFT JOIN gold_dim_customers c
ON f.customer_key = c.customer_key
;

	-- Determine customer lifespan in months

SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) first_order,
MAX(order_date) last_order,
TIMESTAMPDIFF (month, MIN(order_date), MAX(order_date)) AS lifespan
FROM gold_fact_sales f
LEFT JOIN gold_dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key 
;

	-- Group customer into three segments based on lifespan and spending behavior 

WITH customer_spending AS (
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) first_order,
MAX(order_date) last_order,
TIMESTAMPDIFF (month, MIN(order_date), MAX(order_date)) AS lifespan
FROM gold_fact_sales f
LEFT JOIN gold_dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key 
)

SELECT
customer_key,
total_spending,
lifespan,
CASE WHEN lifespan >= 12 AND total_spending > '5000' THEN 'VIP'
	WHEN lifespan >= 12 AND total_spending <= '5000' THEN 'Regular'
    ELSE 'New'
END customer_status
FROM customer_spending
;

	-- Find the number of individuals in each segment
    
WITH customer_spending AS (
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) first_order,
MAX(order_date) last_order,
TIMESTAMPDIFF (month, MIN(order_date), MAX(order_date)) AS lifespan
FROM gold_fact_sales f
LEFT JOIN gold_dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key 
)

SELECT
CASE WHEN lifespan >= 12 AND total_spending > '5000' THEN 'VIP'
	WHEN lifespan >= 12 AND total_spending <= '5000' THEN 'Regular'
    ELSE 'New'
END customer_status,
COUNT(customer_key) AS total_customers
FROM customer_spending
GROUP BY customer_status
ORDER BY total_customers DESC
;
    
