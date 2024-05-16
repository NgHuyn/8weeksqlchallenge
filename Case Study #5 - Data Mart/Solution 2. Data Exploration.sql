-- ** 2. Data Exploration ** --
-- 1. What day of the week is used for each week_date value?
SELECT DISTINCT DAYNAME(week_date) AS day
FROM clean_weekly_sales;

-- 2. What range of week numbers are missing from the dataset?
DROP TABLE IF EXISTS expected_week_numbers;
CREATE TEMPORARY TABLE expected_week_numbers (week_number INT);

INSERT INTO expected_week_numbers (week_number)
VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12),
	   (13), (14), (15), (16), (17), (18), (19), (20), (21), (22), (23), 
       (24), (25), (26), (27), (28), (29), (30), (31), (32), (33), (34), 
       (35), (36), (37), (38), (39), (40), (41), (42), (43), (44), (45),
       (46), (47), (48), (49), (50), (51), (52);

SELECT week_number
FROM expected_week_numbers
WHERE week_number NOT IN(SELECT week_number FROM clean_weekly_sales)
GROUP BY week_number
ORDER BY week_number;

-- 3. How many total transactions were there for each year in the dataset?
SELECT calendar_year,
	   SUM(transactions) AS Total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;

-- 4. What is the total sales for each region for each month?
SELECT region, month_number, 
	   SUM(sales) AS Total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;

-- 5. What is the total count of transactions for each platform
SELECT platform,
       SUM(transactions) AS Total_count
FROM clean_weekly_sales
GROUP BY platform;

-- 6. What is the percentage of sales for Retail vs Shopify for each month?
SELECT calendar_year, month_number,
       ROUND(100 * SUM(CASE WHEN platform = 'Retail' THEN sales ELSE 0 END) / SUM(sales), 2) AS retail_percentage,
       ROUND(100 * SUM(CASE WHEN platform = 'Shopify' THEN sales ELSE 0 END) / SUM(sales), 2) AS shopify_percentage
FROM clean_weekly_sales
GROUP BY calendar_year, month_number
ORDER BY calendar_year, month_number;

-- 7. What is the percentage of sales by demographic for each year in the dataset?
SELECT calendar_year,
	   ROUND(100 * SUM(CASE WHEN demographic = 'Couples' THEN sales ELSE 0 END) / SUM(sales), 2) AS couples_percentage,
       ROUND(100 * SUM(CASE WHEN demographic= 'Families' THEN sales ELSE 0 END) / SUM(sales), 2) AS families_percentage,
       ROUND(100 * SUM(CASE WHEN demographic = 'unknown' THEN sales ELSE 0 END) / SUM(sales), 2) AS unknown_percentage
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;
	
-- 8. Which age_band and demographic values contribute the most to Retail sales?
SELECT age_band, demographic,
	   SUM(sales) AS retail_sales
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY retail_sales DESC
LIMIT 1;
-- The majority of the highest retail sales are contributed by unknown age_band and demographic.

-- 9. Can we use the avg_transaction column to find the average transaction size for each year 
-- for Retail vs Shopify? If not - how would you calculate it instead?
/*
 We can use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify.
 On the other hand, we can calculates the average transaction size by dividing the total sales
 for the entire dataset by the total number of transactions
 */
SELECT calendar_year, platform,
       AVG(avg_transaction) AS average_transaction_size,
       SUM(sales) / SUM(transactions) AS avg_transaction_group
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;