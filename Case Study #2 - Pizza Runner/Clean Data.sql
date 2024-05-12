DROP TABLE IF EXISTS customer_orders_temp;
CREATE TEMPORARY TABLE customer_orders_temp AS (
	SELECT order_id, customer_id, pizza_id,
		   CASE
			   WHEN exclusions = '' THEN NULL
			   WHEN exclusions = 'null' THEN NULL
			   ELSE exclusions
		   END AS exclusions,
		   CASE
			   WHEN extras = '' THEN NULL
			   WHEN extras = 'null' THEN NULL
			   ELSE extras
		   END AS extras,
		   order_time
	FROM customer_orders
);
SELECT * FROM customer_orders_temp;

DROP TABLE IF EXISTS runner_orders_temp;
CREATE TEMPORARY TABLE runner_orders_temp AS (
	SELECT order_id,
		   runner_id,
		   CASE
			   WHEN pickup_time LIKE 'null' THEN NULL
			   ELSE pickup_time
		   END AS pickup_time,
		   CASE
			   WHEN distance LIKE 'null' THEN NULL
			   ELSE CAST(regexp_replace(distance, '[a-z]+', '') AS FLOAT)
		   END AS distance,
		   CASE
			   WHEN duration LIKE 'null' THEN NULL
			   ELSE CAST(regexp_replace(duration, '[a-z]+', '') AS FLOAT)
		   END AS duration,
		   CASE
			   WHEN cancellation LIKE '' THEN NULL
			   WHEN cancellation LIKE 'null' THEN NULL
			   ELSE cancellation
		   END AS cancellation
	FROM runner_orders
);
SELECT * FROM runner_orders_temp;

DROP TABLE IF EXISTS pizza_recipes_temp;
CREATE TEMPORARY TABLE pizza_recipes_temp(pizza_id int, topping int);
DROP PROCEDURE IF EXISTS GetToppings;

DELIMITER $$
CREATE PROCEDURE GetToppings()
BEGIN
	DECLARE i INT DEFAULT 0;
    DECLARE j INT DEFAULT 0;
	DECLARE n INT DEFAULT 0;
    DECLARE x INT DEFAULT 0;
    DECLARE id  INT;
	DECLARE topping_in TEXT;
    DECLARE topping_out TEXT;

 	SET i = 0;
    SELECT COUNT(*) FROM pizza_recipes INTO n;

	WHILE i < n DO  -- Iterate per row
		SELECT pizza_id, toppings INTO id, topping_in FROM pizza_recipes LIMIT i,1 ; -- Select each row and store values in id, topping_in variables
		SET x = (CHAR_LENGTH(topping_in) - CHAR_LENGTH( REPLACE ( topping_in, ' ', '') ))+1; -- Find the number of toppings in the row

        SET j = 1;
		WHILE j <= x DO -- Iterate over each element in topping
			SET topping_out = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(topping_in, ',', j), ',', -1));
            -- SUBSTRING_INDEX(topping_in, ',', j -> Returns a substring from a string before j occurences of comma
            -- (SUBSTRING_INDEX(SUBSTRING_INDEX(topping_in, ',', j), ',', -1)) -> Returns the last topping from the substring found above, element at -1 index
			INSERT INTO pizza_recipes_temp VALUES(id, topping_out);  -- Insert pizza_id and the topping into table pizza_info
			SET j = j + 1; -- Increment the counter to find the next pizza topping in the row
        END WHILE;
        SET i = i + 1;-- Increment the counter to fetch the next row
	END WHILE;
END$$
DELIMITER ;

CALL GetToppings();

SELECT *
FROM pizza_recipes_temp;

SELECT t.order_id,
       t.customer_id,
       t.pizza_id,
       trim(j1.exclusions) AS exclusions,
       trim(j2.extras) AS extras,
       t.order_time
FROM customer_orders_temp t
INNER JOIN json_table(trim(replace(json_array(t.exclusions), ',', '","')), '$[*]' columns (exclusions varchar(50) PATH '$')) j1
INNER JOIN json_table(trim(replace(json_array(t.extras), ',', '","')), '$[*]' columns (extras varchar(50) PATH '$')) j2 ;