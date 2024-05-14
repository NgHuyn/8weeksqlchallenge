-- ** B. Data Analysis Questions ** --
-- 1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS Total_number_of_customers
FROM subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset 
-- use the start of the month as the group by value
SELECT DATE_FORMAT(start_date, '%Y-%m-01') AS month, COUNT(*) AS Total_number_of_trial_plan
FROM subscriptions
WHERE plan_id = 0
GROUP BY month
ORDER BY month;

-- What plan start_date values occur after the year 2020 for our dataset?
-- Show the breakdown by count of events for each plan_name
SELECT p.plan_name, COUNT(p.plan_name) AS count_of_events
FROM plans p
JOIN subscriptions s ON p.plan_id = s.plan_id
WHERE YEAR(start_date) > 2020
GROUP BY p.plan_name;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
WITH churned_customer AS (
    SELECT COUNT(DISTINCT customer_id) AS churned_customer_count
    FROM subscriptions
    WHERE plan_id = 4
),
total_customer AS (
    SELECT COUNT(DISTINCT customer_id) AS total_customer_count
    FROM subscriptions
)
SELECT churned_customer_count,
       ROUND((churned_customer_count / total_customer_count) * 100, 1) AS percentage_of_churned_customers
FROM churned_customer, total_customer;

-- 5. How many customers have churned straight after their initial free trial 
-- what percentage is this rounded to the nearest whole number?
WITH churned_after_trial AS(
  SELECT customer_id,
		 CASE 
			 WHEN plan_id = 4 AND LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) = 0 THEN 1 ELSE 0
		 END as churned_cases
  FROM subscriptions
)

SELECT 
  SUM(churned_cases) as churned_customers,
  FLOOR(SUM(churned_cases) / CAST(COUNT(DISTINCT customer_id) AS float) * 100) as churn_percentage
FROM churned_after_trial;

-- 6. What is the number and percentage of customer plans after their initial free trial?
SELECT COUNT(DISTINCT customer_id) INTO @total FROM subscriptions;

WITH plans_after_trial AS(
  SELECT plan_id, customer_id,
		 ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) as plan_order
  FROM subscriptions
  WHERE plan_id <> 0
)

SELECT p2.plan_name,
	   COUNT(p1.plan_id) AS plans_after_trial,
       COUNT(p1.plan_id) / @total * 100 AS percentage
FROM plans_after_trial p1
JOIN plans p2
ON p1.plan_id = p2.plan_id
WHERE p1.plan_order = 1 -- Only take the first plan after initial free trial
GROUP BY p2.plan_name;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH next_dates AS (
  SELECT customer_id,
		 plan_id,
		 start_date,
		 LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_date
  FROM subscriptions
  WHERE start_date <= '2020-12-31'
)

SELECT plan_id, 
	   COUNT(DISTINCT customer_id) AS customers,
	   ROUND((COUNT(DISTINCT customer_id) / @total)*100, 1) AS percentage
FROM next_dates
WHERE next_date IS NULL -- customer's current plan ends before 2020-12-31
GROUP BY plan_id;

-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT COUNT(DISTINCT customer_id) AS annual_plan_customers_count
FROM subscriptions
WHERE start_date <= '2020-12-31' AND plan_id = 3;	

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH join_day AS (
    SELECT customer_id,
		   start_date AS start_day
    FROM subscriptions
    WHERE plan_id = 0
),
annual_day AS (
    SELECT customer_id,
		   start_date AS annual_day
    FROM subscriptions
    WHERE plan_id = 3
)
SELECT AVG(DATEDIFF(annual_day, start_day)) AS avg_day_to_take_annual_plan
FROM join_day j
JOIN annual_day a ON j.customer_id = a.customer_id;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH join_day AS (
    SELECT customer_id,
           start_date AS start_day
    FROM subscriptions
    WHERE plan_id = 0
),
annual_day AS (
    SELECT customer_id,
           start_date AS annual_day
    FROM subscriptions
    WHERE plan_id = 3
),
periods AS (
    SELECT j.customer_id,
           FLOOR(DATEDIFF(a.annual_day, j.start_day) / 30) * 30 AS period_start
    FROM join_day j
    JOIN annual_day a ON j.customer_id = a.customer_id
)
SELECT 
    CONCAT(period_start, '-', period_start + 30, ' days') AS period,
    COUNT(*) AS count_in_period,
    AVG(DATEDIFF(a.annual_day, j.start_day)) AS avg_day
FROM periods p
JOIN join_day j ON p.customer_id = j.customer_id
JOIN annual_day a ON p.customer_id = a.customer_id
GROUP BY period, period_start
ORDER BY period_start;

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH downgraded_customers AS(
   SELECT CASE 
			  WHEN plan_id = 2 AND LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) = 1 THEN 1 ELSE 0
		  END AS downgraded
   FROM subscriptions
)
SELECT SUM(downgraded) AS total_customer_downgraded
FROM downgraded_customers;
