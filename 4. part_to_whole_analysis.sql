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