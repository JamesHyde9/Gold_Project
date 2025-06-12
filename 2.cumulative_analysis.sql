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
