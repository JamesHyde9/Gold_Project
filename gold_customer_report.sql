/* 
==============================================================================
Customer Report
==============================================================================
Purpose:
	- This report consolidates key customer metrics and behaviors
    
Highlights:
	1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into catagories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
		- total orders
        - total sales
        - total quantaty purchased
        - lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
        - average order value (AOR)
        - average monthly spending
==============================================================================
*/

CREATE VIEW gold_report_customers AS
WITH base_query AS(
/*----------------------------------------------------------------------------
Base Query: Retrieves core columns from tables
----------------------------------------------------------------------------*/
SELECT 
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
TIMESTAMPDIFF (year, c.birthdate, CURDATE()) age
FROM gold_fact_sales f
LEFT JOIN gold_dim_customers c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL)

, customer_aggregation AS (
/*----------------------------------------------------------------------------
Aggregates customer-level metrics
----------------------------------------------------------------------------*/
SELECT
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) AS total_orders,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT product_key) AS total_products,
MAX(order_date) AS last_order_date,
TIMESTAMPDIFF (month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY
	customer_key,
	customer_number,
	customer_name,
	age
)
SELECT
customer_key,
customer_number,
customer_name,
age,
CASE 
	WHEN age < 20 THEN 'Under 20'
	WHEN age between 20 AND 29 THEN '20-29'
    WHEN age between 30 AND 39 THEN '30-39'
    WHEN age between 40 AND 49 THEN '40-49'
    WHEN age > 50 THEN '50 and above'
END age_group,
CASE 
	WHEN lifespan >= 12 AND total_sales > '5000' THEN 'VIP'
	WHEN lifespan >= 12 AND total_sales <= '5000' THEN 'Regular'
    ELSE 'New'
END customer_status,
last_order_date,
-- Compute recency
TIMESTAMPDIFF (month, last_order_date, CURDATE()) AS recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
-- Compute average order value (AVO)
CASE 
	WHEN total_orders = 0 THEN 0
	ELSE total_sales / total_orders 
END AS avg_order_value,
-- Compute average monthly spending
CASE 
	WHEN lifespan = 0 THEN total_sales
    ELSE total_sales / lifespan
END AS avg_monthly_spend
FROM customer_aggregation
;


