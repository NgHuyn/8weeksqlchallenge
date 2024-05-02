-- C. Ingredient Optimisation -- 
-- Prepare somethings -- 
-- Create a temporary table cleaned_toppings to split toppings and join to get the name of each topping
DROP TABLE IF EXISTS cleaned_toppings;
CREATE TEMPORARY TABLE cleaned_toppings AS
SELECT p.pizza_id,
       CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p.toppings, ',', n), ',', -1)) AS UNSIGNED) AS topping_id,
       pt.topping_name
FROM pizza_recipes p
CROSS JOIN
  (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) AS numbers
JOIN pizza_toppings AS pt ON CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(p.toppings, ',', n), ',', -1)) AS UNSIGNED) = pt.topping_id
WHERE CHAR_LENGTH(p.toppings) - CHAR_LENGTH(REPLACE(p.toppings, ',', '')) >= n - 1;

-- Add a record_id column to assign an ID for each order
ALTER TABLE customer_orders_temp
ADD COLUMN record_id INT AUTO_INCREMENT PRIMARY KEY;

-- Create the extras table
DROP TABLE IF EXISTS extras;
CREATE TEMPORARY TABLE extras AS
SELECT c.record_id,
       TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(c.extras, ',', n), ',', -1)) AS topping_id
FROM customer_orders_temp c
CROSS JOIN
  (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) AS numbers
WHERE CHAR_LENGTH(c.extras) - CHAR_LENGTH(REPLACE(c.extras, ',', '')) >= n - 1;

-- Create the exclusions table
DROP TABLE IF EXISTS exclusions;
CREATE TEMPORARY TABLE exclusions AS
SELECT c.record_id,
       TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(c.exclusions, ',', n), ',', -1)) AS topping_id
FROM customer_orders_temp c
CROSS JOIN
  (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) AS numbers
WHERE CHAR_LENGTH(c.exclusions) - CHAR_LENGTH(REPLACE(c.exclusions, ',', '')) >= n - 1;

-- Solution -- 
-- 1. What are the standard ingredients for each pizza?
SELECT p.pizza_id,
	   p.pizza_name,
       GROUP_CONCAT(t.topping_name SEPARATOR ', ') AS toppings
FROM pizza_names AS p
JOIN pizza_recipes_temp AS r ON p.pizza_id = r.pizza_id
JOIN pizza_toppings AS t ON r.topping = t.topping_id
GROUP BY p.pizza_id, p.pizza_name
ORDER BY p.pizza_id;

-- 2. What was the most commonly added extra?
CREATE TEMPORARY TABLE customer_orders_temp_extras AS
SELECT order_id,
	   customer_id,
       pizza_id,
       SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', n), ',', -1) AS extra
FROM customer_orders
JOIN
  (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) AS numbers
  ON CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) >= n - 1;

SELECT COUNT(c.extra) AS "The most commonly added extra",
	   p.topping_name
FROM customer_orders_temp_extras AS c
JOIN pizza_toppings AS p ON c.extra = p.topping_id
GROUP BY p.topping_name
ORDER BY COUNT(c.extra) DESC
LIMIT 1;

-- 3. What was the most common exclusion?
CREATE TEMPORARY TABLE customer_orders_temp_exclusion AS
SELECT order_id,
	   customer_id,
       pizza_id,
       SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', n), ',', -1) AS exclusion
FROM customer_orders
JOIN
  (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) AS numbers
  ON CHAR_LENGTH(exclusions) - CHAR_LENGTH(REPLACE(exclusions, ',', '')) >= n - 1;

SELECT COUNT(c.exclusion) AS "The most common exclusion",
	   p.topping_name
FROM customer_orders_temp_exclusion AS c
JOIN pizza_toppings AS p ON c.exclusion = p.topping_id
GROUP BY p.topping_name
ORDER BY COUNT(c.exclusion) DESC
LIMIT 1;

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
	-- Meat Lovers
	-- Meat Lovers - Exclude Beef
	-- Meat Lovers - Extra Bacon
	-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
WITH extras_cte AS (
	SELECT record_id,
		   CONCAT('Extra ', GROUP_CONCAT(t.topping_name SEPARATOR ', ')) as record_options
	FROM extras e
	JOIN pizza_toppings t ON e.topping_id = t.topping_id
	GROUP BY record_id
),
exclusions_cte AS (
	SELECT record_id,
		   CONCAT('Exclude ', GROUP_CONCAT(t.topping_name SEPARATOR ', ')) as record_options
	FROM exclusions e
	JOIN pizza_toppings t ON e.topping_id = t.topping_id
	GROUP BY record_id
),
union_cte AS (
	SELECT * FROM extras_cte
	UNION
	SELECT * FROM exclusions_cte
)

SELECT c.record_id,
	   CONCAT_WS(' - ', p.pizza_name, GROUP_CONCAT(cte.record_options SEPARATOR ' - ')) AS Order_item
FROM customer_orders_temp c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
LEFT JOIN union_cte cte ON c.record_id = cte.record_id
GROUP BY c.record_id, p.pizza_name
ORDER BY 1;

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table 
-- and add a 2x in front of any relevant ingredients
	-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH ingredients_cte AS (
	SELECT c.record_id, 
		   p.pizza_name,
		   CASE
			   WHEN t.topping_id IN (SELECT topping_id FROM extras e WHERE c.record_id = e.record_id)
			   THEN CONCAT('2x', t.topping_name)
			   ELSE t.topping_name
		   END as topping
	FROM customer_orders_temp c
	JOIN pizza_names p ON c.pizza_id = p.pizza_id
	JOIN cleaned_toppings t ON c.pizza_id = t.pizza_id
	WHERE t.topping_id NOT IN (SELECT topping_id FROM exclusions e WHERE c.record_id = e.record_id)
)

SELECT record_id,
	   CONCAT(pizza_name, ': ', GROUP_CONCAT(topping SEPARATOR ', ')) as ingredients_list
FROM ingredients_cte
GROUP BY record_id, pizza_name
ORDER BY 1;

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
-- Create a CTE to calculate the total number of ingredients used
WITH ingredients_cte AS (
SELECT c.record_id,
	   t.topping_name,
	CASE
		-- if extra ingredient add 2
		WHEN t.topping_id 
		IN (select topping_id from extras e where e.record_id = c.record_id) 
		THEN 2
		-- if excluded ingredient add 0
		WHEN t.topping_id 
		IN (select topping_id from exclusions e where e.record_id = c.record_id) 
		THEN 0
		-- normal ingredient add 1
		ELSE 1 
	END as times_used
	FROM customer_orders_temp c
    JOIN cleaned_toppings t ON c.pizza_id = t.pizza_id
) 

SELECT topping_name,
	   SUM(times_used) AS times_used 
FROM ingredients_cte
GROUP BY topping_name
ORDER BY times_used DESC;