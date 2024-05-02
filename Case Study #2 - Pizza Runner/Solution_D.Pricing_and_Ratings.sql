-- D. Pricing and Ratings -- 
-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
-- how much money has Pizza Runner made so far if there are no delivery fees?
SELECT 
	SUM(CASE WHEN p.pizza_name = 'Meatlovers' THEN 12 ELSE 10
		END) AS Total_amount_$
FROM runner_orders_temp AS r
JOIN customer_orders_temp AS c ON r.order_id = c.order_id
JOIN pizza_names AS p ON c.pizza_id = p.pizza_id
WHERE r.cancellation IS NULL;


-- 2. What if there was an additional $1 charge for any pizza extras?
	-- Add cheese is $1 extra
WITH pizza_prices AS (
    SELECT pizza_id,
           CASE 
               WHEN pizza_name = 'Meatlovers' THEN 12 ELSE 10
           END AS base_price
    FROM pizza_names
),
order_totals AS (
    SELECT c.order_id,
           c.pizza_id,
           COUNT(DISTINCT SUBSTRING_INDEX(SUBSTRING_INDEX(c.extras, ',', numbers.n), ',', -1)) AS num_extras
    FROM customer_orders_temp c
    CROSS JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    ) numbers
    WHERE numbers.n <= 1 + (LENGTH(c.extras) - LENGTH(REPLACE(c.extras, ',', '')))
    GROUP BY c.order_id, c.pizza_id
)
SELECT SUM(p.base_price + ot.num_extras) AS total_amount_$
FROM order_totals ot
JOIN pizza_prices p ON ot.pizza_id = p.pizza_id;

-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner,
-- how would you design an additional table for this new dataset - generate a schema for this new table and insert 
-- your own data for ratings for each successful customer order between 1 to 5.
CREATE DATABASE IF NOT EXISTS new_pizza_runner;
USE new_pizza_runner;

CREATE TABLE pizza_toppings (
  topping_id INT PRIMARY KEY,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

CREATE TABLE pizza_names (
  pizza_id INT PRIMARY KEY,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

CREATE TABLE pizza_recipes (
  pizza_id INT,
  FOREIGN KEY(pizza_id) REFERENCES pizza_names(pizza_id) ON DELETE CASCADE,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

CREATE TABLE runners (
  runner_id INT PRIMARY KEY,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');
CREATE TABLE runner_orders (
    order_id INT PRIMARY KEY,
    runner_id INT,
    pickup_time VARCHAR(19),
    distance VARCHAR(7),
    duration VARCHAR(10),
    cancellation VARCHAR(23),
    FOREIGN KEY (runner_id) REFERENCES runners(runner_id) ON DELETE CASCADE
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  (1, 1, '2020-01-01 18:15:34', '20', '32', ''),
  (2, 1, '2020-01-01 19:10:54', '20', '27', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4', '20', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, null, null, null, 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25', '25', 'null'),
  (8, 2, '2020-01-10 00:15:02', '23.4', '15', 'null'),
  (9, 2, null, null, null, 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10', '10', 'null');
  
CREATE TABLE customer_orders (
    order_id INT,
    customer_id INT,
    pizza_id INT,
    exclusions VARCHAR(4),
    extras VARCHAR(4),
    order_time TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES runner_orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (pizza_id) REFERENCES pizza_names(pizza_id) ON DELETE CASCADE
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  (1, 101, 1, '', '', '2020-01-01 18:05:02'),
  (2, 101, 1, '', '', '2020-01-01 19:00:52'),
  (3, 102, 1, '', '', '2020-01-02 23:51:23'),
  (3, 102, 2, '', NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 2, '4', '', '2020-01-04 13:23:46'),
  (5, 104, 1, NULL, '1', '2020-01-08 21:00:29'),
  (6, 101, 2, NULL, 'null', '2020-01-08 21:03:13'),
  (7, 105, 2, NULL, '1', '2020-01-08 21:20:29'),
  (8, 102, 1, NULL, 'null', '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2020-01-10 11:22:59'),
  (10, 104, 1, NULL, NULL, '2020-01-11 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');

CREATE TABLE customer_ratings (
    customer_id INT,
    order_id INT,
    rating INT,
    PRIMARY KEY (customer_id, order_id),
    FOREIGN KEY (order_id) REFERENCES customer_orders(order_id) ON DELETE CASCADE
);

INSERT INTO customer_ratings
    (customer_id, order_id, rating)
VALUES
    (101, 1, 4),
    (102, 2, 4),
    (103, 1, 3),
    (104, 3, 5),
    (105, 4, 2);
DROP DATABASE new_pizza_runner;
-- 4. Using your newly generated table - can you join all of the information together to form a table which has 
-- the following information for successful deliveries?
	-- customer_id
	-- order_id
	-- runner_id
	-- rating
	-- order_time
	-- pickup_time
	-- Time between order and pickup
	-- Delivery duration
	-- Average speed
	-- Total number of pizzas
SELECT c.customer_id, c.order_id, r.runner_id, cr.rating, c.order_time, ro.pickup_time,
	   TIMESTAMPDIFF(SECOND, c.order_time, ro.pickup_time)/60 AS time_between_order_pickup_minutes,
	   ro.duration AS delivery_duration, ro.distance/(ro.duration/60) AS average_speed,
	   COUNT(c.pizza_id) AS total_number_of_pizzas
FROM customer_orders c
JOIN runner_orders ro ON c.order_id = ro.order_id
JOIN runners r ON ro.runner_id = r.runner_id
JOIN customer_ratings cr ON c.order_id = cr.order_id
GROUP BY c.customer_id, c.order_id, r.runner_id, cr.rating, c.order_time, ro.pickup_time, ro.duration, ro.distance;

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner
-- is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
SELECT 
    SUM(
        CASE 
            WHEN pn.pizza_name = 'Meatlovers' THEN 12 
            ELSE 10
        END
    ) AS revenue_from_customer,
    -- Calculate the total amount paid to the runner, based on the distance traveled
    -- The runner is paid $0.30 for each kilometer traveled
    SUM(
        CASE 
            WHEN ro.cancellation IS NULL THEN ro.distance * 0.3
            ELSE 0
        END
    ) AS paid_for_runner,

    -- Calculate the total amount of money left for Pizza Runner after deducting the payment to the runner from the total revenue
    SUM(
        CASE 
            WHEN ro.cancellation IS NULL THEN (CASE WHEN pn.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END) - ro.distance * 0.3
            ELSE 0
        END
    ) AS Total_money_Pizza_Runner_have_left
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id;



			









    