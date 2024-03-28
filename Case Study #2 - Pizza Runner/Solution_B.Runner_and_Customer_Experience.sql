-- B. Runner and Customer Experience -- 
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT WEEK(registration_date) AS registration_week, 
    COUNT(runner_id) AS number_of_runners_singed_up
FROM runners
GROUP BY WEEK(registration_date);

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH time_taken_cte AS (
	SELECT 
		c.order_id, 
		c.order_time, 
		r.pickup_time, 
		TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS pickup_minutes
	FROM customer_orders_temp AS c
	JOIN runner_orders_temp AS r
		ON c.order_id = r.order_id
	WHERE r.distance != 0
	GROUP BY c.order_id, c.order_time, r.pickup_time
)

SELECT AVG(pickup_minutes) AS avg_time_to_pick_up
FROM time_taken_cte;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH time_prep_cte AS (
	SELECT 
		COUNT(c.order_id) AS number_of_pizzas,
		c.order_id, 
		c.order_time, 
		r.pickup_time, 
		TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS pickup_minutes
	FROM customer_orders_temp AS c
	JOIN runner_orders_temp AS r
		ON c.order_id = r.order_id
	WHERE r.distance != 0
	GROUP BY c.order_id, c.order_time, r.pickup_time
)

SELECT 
	number_of_pizzas,
    AVG(pickup_minutes) AS avg_times
FROM time_prep_cte
GROUP BY number_of_pizzas;

-- 4. What was the average distance travelled for each customer?
SELECT 
	c.customer_id,
    AVG(r.distance) AS avg_travelled_distance
FROM customer_orders_temp AS c
JOIN runner_orders_temp AS r
	ON c.order_id = r.order_id
WHERE r.distance IS NOT NULL
GROUP BY c.customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration) - MIN(duration) AS the_delivery_time_difference
FROM runner_orders_temp;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
	order_id,
	runner_id,
	AVG(distance / (duration / 60)) AS "Avg speed (km/h)"
FROM runner_orders_temp
WHERE duration IS NOT NULL
GROUP BY order_id, runner_id;
-- Runner 1’s average speed runs from 37.5km/h to 60km/h.
-- Runner 2’s average speed runs from 35.1km/h to 93.6km/h. This runner's work efficiency is quite high and effective
-- Runner 3’s average speed is 40km/h

-- 7. What is the successful delivery percentage for each runner?
WITH delivery_cte AS (
	SELECT 
		runner_id,
		SUM(CASE 
				WHEN cancellation IS NULL THEN 1
				ELSE 0
			END) AS successful,
		COUNT(order_id) AS total_orders
	FROM runner_orders_temp
	GROUP BY runner_id
)

SELECT 
	runner_id,
    (successful / total_orders)*100 AS percentage_of_successful_delivery
FROM delivery_cte;


