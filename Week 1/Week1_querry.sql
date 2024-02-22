-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price) AS total_amount
FROM Sales AS s JOIN Menu AS m
ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) AS visit_days
FROM Sales 
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
SELECT sub.customer_id, sub.product_name
FROM (
  SELECT S.customer_id, 
         M.product_name, 
         S.order_date,
         ROW_NUMBER() OVER (PARTITION BY S.customer_id ORDER BY S.order_date) AS rn
  FROM Menu M
  JOIN Sales S ON M.product_id = S.product_id
  GROUP BY S.customer_id, M.product_name, S.order_date
) AS sub
WHERE sub.rn = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- S1:
WITH rank_item AS (
	SELECT m.product_id, m.product_name, COUNT(*) AS times_ord
	FROM Menu M
	JOIN Sales S ON M.product_id = S.product_id
    GROUP BY m.product_id, m.product_name
) 

SELECT rank_item.product_name, 
	RANK() OVER (ORDER BY times_ord DESC) AS rank_purchased,
    rank_item.times_ord
FROM rank_item
LIMIT 1;

-- S2:
SELECT m.product_name, COUNT(s.product_id) AS product_count
FROM Menu m
JOIN Sales s ON m.product_id = s.product_id
GROUP BY m.product_name
ORDER BY product_count DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
WITH rank_ord AS (
	SELECT s.customer_id, m.product_name, COUNT(s.product_id) AS count_ord,
		RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) as rank_item
	FROM Menu m
	JOIN Sales s ON m.product_id = s.product_id
	GROUP BY s.customer_id, m.product_name
)

SELECT rank_ord.customer_id, rank_ord.product_name, rank_ord.count_ord
FROM rank_ord
WHERE rank_ord.rank_item = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH temp AS (
	SELECT s.customer_id, me.product_name, s.order_date, m.join_date
	FROM Sales s
	INNER JOIN Members m ON s.customer_id = m.customer_id
	INNER JOIN Menu me ON me.product_id = s.product_id
	WHERE m.join_date <= s.order_date
)

SELECT r.customer_id, r.product_name, r.order_date
FROM (
	SELECT temp.customer_id, temp.product_name, temp.order_date,
		RANK() OVER (PARTITION BY temp.customer_id ORDER BY temp.order_date) AS rank_item
	FROM temp
) AS r
WHERE r.rank_item = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH temp AS (
	SELECT s.customer_id, me.product_name, s.order_date, m.join_date
	FROM Sales s
	INNER JOIN Members m ON s.customer_id = m.customer_id
	INNER JOIN Menu me ON me.product_id = s.product_id
	WHERE m.join_date > s.order_date
)

SELECT r.customer_id, r.product_name, r.order_date, r.join_date
FROM (
	SELECT *,
		RANK() OVER (PARTITION BY temp.customer_id ORDER BY temp.order_date) AS rank_item
	FROM temp
) AS r;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, COUNT(*) AS total_items, SUM(me.price) AS amount_spent
FROM Sales s
INNER JOIN Members m ON s.customer_id = m.customer_id
INNER JOIN Menu me ON me.product_id = s.product_id
WHERE m.join_date > s.order_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id, 
    SUM(
        CASE 
            WHEN product_name = 'sushi' THEN price * 20  -- 2x multiplier for sushi
            ELSE price * 10  -- Regular points for other products
        END
    ) AS total_points
FROM Sales s
INNER JOIN Menu me ON s.product_id = me.product_id
GROUP BY customer_id
ORDER BY customer_id;
    
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?
WITH program_last_day AS (
	SELECT join_date, customer_id,
          DATE_ADD(join_date, INTERVAL 7 DAY) AS program_last_date
   FROM Members)
   
SELECT s.customer_id,
       SUM(CASE
               WHEN order_date BETWEEN join_date AND program_last_date THEN price*20
               WHEN order_date NOT BETWEEN join_date AND program_last_date
                    AND product_name = 'sushi' THEN price*20
               WHEN order_date NOT BETWEEN join_date AND program_last_date
                    AND product_name != 'sushi' THEN price*10
           END) AS points
FROM Menu AS m
INNER JOIN Sales AS s ON m.product_id = s.product_id
INNER JOIN program_last_day AS d ON d.customer_id = s.customer_id
AND order_date <= '2021-01-31'
AND order_date >= join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;













