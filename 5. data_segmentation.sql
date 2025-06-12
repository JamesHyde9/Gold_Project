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