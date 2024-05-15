-- ** C. Data Allocation Challenge **--
-- Step 1: Generate the running customer balance
WITH running_balance AS (
    SELECT customer_id, txn_date, txn_type,txn_amount,
		   SUM(
			   CASE 
				   WHEN txn_type = 'deposit' THEN txn_amount
                   WHEN txn_type = 'withdrawal' THEN -txn_amount
                   WHEN txn_type = 'purchase' THEN -txn_amount
                   ELSE 0
			   END) OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_balance
    FROM customer_transactions
),
-- Step 2: Customer balance at the end of each month
end_of_month_balance AS (
    SELECT customer_id,
		   DATE_FORMAT(txn_date, '%Y-%m') AS txn_month,
		   running_balance,
           ROW_NUMBER() OVER (PARTITION BY customer_id, DATE_FORMAT(txn_date, '%Y-%m') ORDER BY txn_date DESC) AS rn
    FROM running_balance
), closing_balances AS (
    SELECT customer_id, txn_month, running_balance AS closing_balance
    FROM end_of_month_balance
    WHERE rn = 1
),
-- Step 3: Minimum, average, and maximum values of the running balance
balance_stats AS (
    SELECT customer_id,
           MIN(running_balance) AS min_balance,
           AVG(running_balance) AS avg_balance,
           MAX(running_balance) AS max_balance
    FROM running_balance
    GROUP BY customer_id
),
-- Step 4: Data allocation for each option
-- Option 1: Based on the balance at the end of the previous month
option1_data AS (
    SELECT customer_id, txn_month,
           LAG(closing_balance) OVER (PARTITION BY customer_id ORDER BY txn_month) AS data_allocation
    FROM closing_balances
),
-- Option 2: Based on the average balance over the previous 30 days
option2_data AS (
    SELECT customer_id,
		   DATE_FORMAT(txn_date, '%Y-%m') AS txn_month,
           AVG(running_balance) OVER (PARTITION BY customer_id ORDER BY txn_date RANGE BETWEEN INTERVAL 30 DAY PRECEDING AND CURRENT ROW) AS data_allocation
    FROM running_balance
),
-- Option 3: Real-time updates (using running balance)
option3_data AS (
    SELECT customer_id,
           DATE_FORMAT(txn_date, '%Y-%m') AS txn_month,
           running_balance AS data_allocation
    FROM running_balance
),
-- Final step: Combine all options and summarize the required data per month
monthly_data AS (
    SELECT customer_id, txn_month, data_allocation, 'Option 1' AS option_type
    FROM option1_data
    UNION ALL
    SELECT customer_id, txn_month, data_allocation, 'Option 2' AS option_type
    FROM option2_data
    UNION ALL
    SELECT customer_id, txn_month, data_allocation, 'Option 3' AS option_type
    FROM option3_data
)
-- Summarize the total data required per month for each option
SELECT txn_month, option_type,
       SUM(data_allocation) AS total_data_required
FROM monthly_data
GROUP BY txn_month, option_type
ORDER BY txn_month, option_type;
