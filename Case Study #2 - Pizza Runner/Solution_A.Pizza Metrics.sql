-- A. Pizza Metrics -- 
-- 1. How many pizzas were ordered?
SELECT COUNT(*) AS 'Total Number Of Pizzas Ordered'
FROM customer_orders_temp;

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS 'Number Of Unique Customer Orders'
FROM customer_orders_temp;

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS 'Number Of Successful Orders'
FROM runner_orders_temp
WHERE cancellation IS NULL
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT cus_ord.pizza_id, COUNT(cus_ord.pizza_id) AS 'Numbee Of Pizza Delivered'
FROM customer_orders_temp AS cus_ord
INNER JOIN runner_orders_temp AS run_ord ON cus_ord.order_id = run_ord.order_id
WHERE run_ord.cancellation IS NULL
GROUP BY cus_ord.pizza_id;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT cus_ord.customer_id, pi.pizza_name, COUNT(cus_ord.pizza_id) AS 'Number Of Ordered'
FROM customer_orders_temp AS cus_ord
INNER JOIN pizza_names AS pi ON cus_ord.pizza_id = pi.pizza_id
GROUP BY cus_ord.customer_id, pi.pizza_name
ORDER BY cus_ord.customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT order_id, COUNT(pizza_id) AS 'Maximum Number Of Pizzas Delivered'
FROM customer_orders_temp
WHERE order_id NOT IN (SELECT order_id FROM runner_orders WHERE cancellation IS NOT NULL)
GROUP BY order_id
ORDER BY COUNT(pizza_id) DESC
LIMIT 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT cus_ord.customer_id,
       SUM(CASE
               WHEN (exclusions IS NOT NULL
                     OR extras IS NOT NULL) THEN 1
               ELSE 0
           END) AS change_in_pizza,
       SUM(CASE
               WHEN (exclusions IS NULL
                     AND extras IS NULL) THEN 1
               ELSE 0
           END) AS no_change_in_pizza
FROM customer_orders_temp AS cus_ord
INNER JOIN runner_orders_temp AS run_ord ON cus_ord.order_id = run_ord.order_id
WHERE run_ord.cancellation IS NULL
GROUP BY cus_ord.customer_id
ORDER BY cus_ord.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT cus_ord.customer_id,
	SUM(CASE
               WHEN (exclusions IS NOT NULL
                     AND extras IS NOT NULL) THEN 1
               ELSE 0
           END) AS number_of_piz_have_both_change
FROM customer_orders_temp AS cus_ord
INNER JOIN runner_orders_temp AS run_ord ON cus_ord.order_id = run_ord.order_id
WHERE run_ord.cancellation IS NULL 
GROUP BY cus_ord.customer_id
ORDER BY cus_ord.customer_id;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT HOUR(order_time) AS hour_of_day,
	COUNT(order_id) AS total_volumn
FROM customer_orders_temp
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time);

-- 10. What was the volume of orders for each day of the week?
SELECT DAYNAME(order_time) AS day_of_week,
	   COUNT(DISTINCT order_id) AS volume_of_orders
FROM customer_orders_temp
GROUP BY DAYNAME(order_time);

