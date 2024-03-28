-- C. Ingredient Optimisation -- 
-- 1. What are the standard ingredients for each pizza?
SELECT 
	p.pizza_id,
    p.pizza_name,
	GROUP_CONCAT(t.topping_name SEPARATOR ', ') AS toppings
FROM pizza_names AS p
JOIN pizza_recipes_temp AS r
	ON p.pizza_id = r.pizza_id
JOIN pizza_toppings AS t
	ON r.topping = t.topping_id
GROUP BY p.pizza_id, p.pizza_name
ORDER BY p.pizza_id;

-- 2. What was the most commonly added extra?
CREATE TEMPORARY TABLE customer_orders_temp_extras AS
SELECT
  order_id,
  customer_id,
  pizza_id,
  SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', n), ',', -1) AS extra
FROM
  customer_orders
JOIN
  (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) AS numbers
  ON CHAR_LENGTH(extras) - CHAR_LENGTH(REPLACE(extras, ',', '')) >= n - 1;

SELECT 
	COUNT(c.extra) AS "The most commonly added extra",
	p.topping_name
FROM customer_orders_temp_extras AS c
JOIN pizza_toppings AS p
	ON c.extra = p.topping_id
GROUP BY p.topping_name
LIMIT 1;

-- 3. What was the most common exclusion?
CREATE TEMPORARY TABLE customer_orders_temp_exclusion AS
SELECT
  order_id,
  customer_id,
  pizza_id,
  SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', n), ',', -1) AS exclusion
FROM
  customer_orders
JOIN
  (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) AS numbers
  ON CHAR_LENGTH(exclusions) - CHAR_LENGTH(REPLACE(exclusions, ',', '')) >= n - 1;

SELECT 
	COUNT(c.exclusion) AS "The most common exclusion",
	p.topping_name
FROM customer_orders_temp_exclusion AS c
JOIN pizza_toppings AS p
	ON c.exclusion = p.topping_id
GROUP BY p.topping_name
LIMIT 1;

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
	-- Meat Lovers
	-- Meat Lovers - Exclude Beef
	-- Meat Lovers - Extra Bacon
	-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
    
-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table 
-- and add a 2x in front of any relevant ingredients
	-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
-- Create a temporary table to hold the toppings and their counts
DROP TABLE IF EXISTS topping_counts;
CREATE TEMPORARY TABLE topping_counts (
    topping VARCHAR(50),
    count INT DEFAULT 0
);

-- Iterate over each row in the customer_orders_temp table
DECLARE i INT DEFAULT 0;
DECLARE n INT;

SELECT COUNT(*) INTO n FROM customer_orders_temp;

WHILE i < n DO
    -- Select each row from the customer_orders_temp table
    SELECT t.extras, t.exclusions
    INTO @extras, @exclusions
    FROM customer_orders_temp t
    LIMIT i, 1;

    -- Insert the toppings from extras into the topping_counts table
    INSERT INTO topping_counts (topping, count)
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(@extras, ',', j), ',', -1)), 1
    FROM customer_orders_temp
    WHERE @extras IS NOT NULL AND @extras <> '' AND @extras <> 'null'
    UNION ALL
    -- Insert the toppings from exclusions into the topping_counts table
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(@exclusions, ',', j), ',', -1)), 1
    FROM customer_orders_temp
    WHERE @exclusions IS NOT NULL AND @exclusions <> '' AND @exclusions <> 'null';
    
    SET i = i + 1;
END WHILE;

-- Update the counts for each topping in the topping_counts table
UPDATE topping_counts
SET count = (
    SELECT COUNT(*)
    FROM customer_orders_temp t
    WHERE t.extras LIKE CONCAT('%', topping, '%')
    OR t.exclusions LIKE CONCAT('%', topping, '%')
);

-- Select the toppings and their counts from the topping_counts table
SELECT topping, count
FROM topping_counts
ORDER BY count DESC;





