-- ** B. Customer Transactions ** --
-- 1. What is the unique count and total amount for each transaction type?
SELECT txn_type,
	   COUNT(txn_type) AS Unique_count,
	   SUM(txn_amount) AS Total_amount
FROM customer_transactions
GROUP BY txn_type;

-- 2. What is the average total historical deposit counts and amounts for all customers?
SELECT SUM(txn_amount) AS Total_deposit_total,
	   AVG(txn_amount) AS Avg_deposit_total
FROM customer_transactions
WHERE txn_type = 'deposit';

-- 3. For each month - how many Data Bank customers make more than 1 deposit 
-- and either 1 purchase or 1 withdrawal in a single month?
WITH monthly_transactions AS (
    SELECT customer_id,
		   DATE_FORMAT(txn_date, '%Y-%m') AS txn_month,
		   txn_type
    FROM customer_transactions
), transaction_counts AS (
    SELECT customer_id,
		   txn_month,
           SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
           SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
           SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
    FROM monthly_transactions
    GROUP BY customer_id, txn_month
), filtered_customers AS (
    SELECT customer_id,
		   txn_month
    FROM transaction_counts
    WHERE deposit_count > 1 AND (purchase_count >= 1 OR withdrawal_count >= 1)
)
SELECT txn_month,
	   COUNT(DISTINCT customer_id) AS customer_count
FROM filtered_customers
GROUP BY txn_month
ORDER BY txn_month;

-- 4. What is the closing balance for each customer at the end of the month?
WITH monthly_transactions AS (
    SELECT customer_id,
           DATE_FORMAT(txn_date, '%Y-%m') AS txn_month,
           txn_date, txn_type, txn_amount
    FROM customer_transactions
), transactions_with_balance AS (
    SELECT customer_id, txn_month, txn_date, txn_type, txn_amount,
        SUM(
            CASE 
                WHEN txn_type = 'deposit' THEN txn_amount
                WHEN txn_type = 'withdrawal' THEN -txn_amount
                WHEN txn_type = 'purchase' THEN -txn_amount
                ELSE 0
            END
        ) OVER (PARTITION BY customer_id ORDER BY txn_date) AS cumulative_balance
    FROM monthly_transactions
), end_of_month_balance AS (
    SELECT customer_id, txn_month, cumulative_balance,
		   ROW_NUMBER() OVER (PARTITION BY customer_id, txn_month ORDER BY txn_date DESC) AS rn
    FROM transactions_with_balance
)
SELECT customer_id, txn_month, cumulative_balance AS closing_balance
FROM end_of_month_balance
WHERE rn = 1
ORDER BY customer_id, txn_month;

-- 5. What is the percentage of customers who increase their closing balance by more than 5%?
WITH monthly_transactions AS (
    SELECT customer_id,
           DATE_FORMAT(txn_date, '%Y-%m') AS txn_month,
           txn_date, txn_type, txn_amount
    FROM customer_transactions
), transactions_with_balance AS (
    SELECT customer_id, txn_month, txn_date, txn_type, txn_amount,
        SUM(
            CASE 
                WHEN txn_type = 'deposit' THEN txn_amount
                WHEN txn_type = 'withdrawal' THEN -txn_amount
                WHEN txn_type = 'purchase' THEN -txn_amount
                ELSE 0
            END
        ) OVER (PARTITION BY customer_id ORDER BY txn_date) AS cumulative_balance
    FROM monthly_transactions
), end_of_month_balance AS (
    SELECT customer_id, txn_month, cumulative_balance,
		   ROW_NUMBER() OVER (PARTITION BY customer_id, txn_month ORDER BY txn_date DESC) AS rn
    FROM transactions_with_balance
), closing_balances AS (
	SELECT customer_id, txn_month, cumulative_balance AS closing_balance
	FROM end_of_month_balance
	WHERE rn = 1
	ORDER BY customer_id, txn_month
), balance_comparison AS (
    SELECT customer_id, txn_month, closing_balance,
		   LAG(closing_balance, 1) OVER (PARTITION BY customer_id ORDER BY txn_month) AS prev_closing_balance
    FROM closing_balances
), balance_increase AS (
    SELECT customer_id,
		   txn_month,
           closing_balance,
           prev_closing_balance,
           CASE 
			   WHEN prev_closing_balance IS NOT NULL AND closing_balance > prev_closing_balance * 1.05 THEN 1
			   ELSE 0
			END AS increase_flag
    FROM balance_comparison
)
SELECT 100.0 * SUM(increase_flag) / COUNT(DISTINCT customer_id) AS percentage_increase
FROM balance_increase;


