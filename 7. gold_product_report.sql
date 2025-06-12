/* 
================================================================================================
Product Report
================================================================================================
Purpose:
	- This report consolidates key product metrics and behaviors
    
Highlights:
	1. Gathers essential fields such as name, catagory, subcatagory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
		- total orders
        - total sales
        - total quantaty sold
        - lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last sale)
        - average order value (AOV)
        - average monthly spend
================================================================================================
*/

CREATE VIEW gold_report_products AS
WITH base_query AS (
/*----------------------------------------------------------------------------------------------
Base Query: Retrieves core columns from tables
----------------------------------------------------------------------------------------------*/
SELECT 
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.quantity,
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost
FROM gold_fact_sales f
LEFT JOIN gold_dim_products p
ON p.product_key = f.product_key
WHERE order_date IS NOT NULL), 

product_aggregation AS (
/*----------------------------------------------------------------------------------------------
Aggregates product-level metrics
----------------------------------------------------------------------------------------------*/
SELECT
product_key,
product_name,
category,
subcategory,
cost,
TIMESTAMPDIFF (month, MIN(order_date), CURDATE()) AS lifespan,
MAX(order_date) AS last_sale_date,
COUNT(DISTINCT order_number) AS total_orders,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query
GROUP BY 
	product_key,
	product_name,
	category,
	subcategory,
    cost)
/*----------------------------------------------------------------------------------------------
Final Query: Segments products by revenue and compute KPIs
----------------------------------------------------------------------------------------------*/
SELECT
product_key,
product_name,
category,
subcategory,
cost,
last_sale_date,
-- Compute recency
TIMESTAMPDIFF (month, last_sale_date, CURDATE()) recency_months,
-- Segments products by revenue
CASE
	WHEN total_sales > 50000 THEN 'High-Performer'
    WHEN total_sales >= 10000 THEN 'Mid-Range'
    ELSE 'Low-Performer'
END AS product_proformance,
lifespan,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,
-- Compute average order revenue (AOR)
CASE
	WHEN total_orders = 0 THEN 0
    ELSE total_sales / total_orders
END AS avg_order_revenue,
-- Compute average monthly revenue
CASE
	WHEN lifespan = 0 THEN total_sales
    ELSE total_sales / lifespan
END AS avg_monthly_revenue
FROM product_aggregation
;



