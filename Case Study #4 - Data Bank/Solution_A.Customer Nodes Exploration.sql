-- ** A. Customer Nodes Exploration ** --
-- 1. How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id) AS Total_number_of_unique_nodes
FROM customer_nodes;

-- 2. What is the number of nodes per region?
SELECT r.region_id, r.region_name, 
	   COUNT(DISTINCT c.node_id) AS Total_number_of_nodes
FROM regions r
JOIN customer_nodes c ON r.region_id = c.region_id
GROUP BY r.region_id, r.region_name
ORDER BY r.region_id;

-- 3. How many customers are allocated to each region?
SELECT r.region_id, r.region_name,
	   COUNT(DISTINCT c.customer_id) AS Total_number_of_customers
FROM regions r
JOIN customer_nodes c ON r.region_id = c.region_id
GROUP BY r.region_id, r.region_name
ORDER BY r.region_id;

-- 4. How many days on average are customers reallocated to a different node?
WITH date_diff AS (
	SELECT customer_id, start_date,
		   LEAD(start_date, 1) OVER(PARTITION BY customer_id ORDER BY start_date) - INTERVAL 1 DAY AS end_date
	FROM customer_nodes
)
SELECT AVG(DATEDIFF(end_date, start_date)) AS avg_day
FROM date_diff;

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
WITH date_diff AS (
    SELECT customer_id, region_id, start_date, 
		   LEAD(start_date) OVER(PARTITION BY customer_id ORDER BY start_date) - INTERVAL 1 DAY AS end_date
    FROM customer_nodes
), date_diff_in_region AS (
    SELECT region_id, 
		   DATEDIFF(end_date, start_date) AS day_diff
    FROM date_diff
    WHERE end_date IS NOT NULL
)
SELECT region_id,
       MAX(CASE WHEN percentile = 50 THEN day_diff ELSE NULL END) AS median,
       MAX(CASE WHEN percentile = 80 THEN day_diff ELSE NULL END) AS p80,
       MAX(CASE WHEN percentile = 95 THEN day_diff ELSE NULL END) AS p95
FROM (
	SELECT region_id, day_diff,
		   NTILE(100) OVER(PARTITION BY region_id ORDER BY day_diff) AS percentile
    FROM date_diff_in_region
) percentiles
WHERE percentile IN (50, 80, 95)
GROUP BY region_id
ORDER BY region_id;








