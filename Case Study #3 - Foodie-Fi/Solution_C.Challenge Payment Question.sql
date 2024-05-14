DROP TABLE IF EXISTS payments;
CREATE TEMPORARY TABLE payments AS
SELECT customer_id,
	   plan_id,
       plan_name,
	   DATE_FORMAT(payment_date, '%Y-%m-%d') AS payment_date,
	   CASE
		   WHEN LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY plan_id) != plan_id 
           AND DATEDIFF(payment_date, LAG(payment_date) OVER (PARTITION BY customer_id ORDER BY plan_id)) < 30 
           THEN amount - LAG(amount) OVER (PARTITION BY customer_id ORDER BY plan_id)
		   ELSE amount
	    END AS amount,
		RANK() OVER (PARTITION BY customer_id ORDER BY payment_date) AS payment_order
FROM (
    SELECT customer_id,
		   s.plan_id,
		   plan_name,
		   CASE
			   WHEN s.plan_id != 0  THEN start_date
			   WHEN s.plan_id = 4 THEN NULL
			   WHEN LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date) IS NOT NULL 
               THEN LEAD(start_date) OVER (PARTITION BY customer_id ORDER BY start_date)
			   ELSE STR_TO_DATE('2020-12-31', '%Y-%m-%d')
		   END AS payment_date, price AS amount
    FROM subscriptions AS s
	JOIN plans AS p ON s.plan_id = p.plan_id
    WHERE s.plan_id != 0 AND start_date < '2021-01-01'
    GROUP BY customer_id, s.plan_id, plan_name, start_date, price
) AS t
ORDER BY customer_id;
  
SELECT * FROM payments;