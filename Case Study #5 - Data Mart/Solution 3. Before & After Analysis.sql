-- ** 3. Before & After Analysis ** --
-- 1. What is the total sales for the 4 weeks before and after 2020-06-15? 
-- What is the growth or reduction rate in actual values and percentage of sales?
WITH total_sales AS (
	SELECT week_date, week_number, 
		   SUM(sales) AS total_sales
	FROM clean_weekly_sales
	WHERE (week_number BETWEEN 21 AND 28) AND (calendar_year = 2020)
	GROUP BY week_date, week_number
)
, four_week_before_after AS (
	SELECT SUM(CASE WHEN week_number BETWEEN 21 AND 24 THEN total_sales END) AS sales_before,
		   SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN total_sales END) AS sales_after
	FROM total_sales
)

SELECT sales_after - sales_before AS sales_variance, 
	   ROUND(100 * (sales_after - sales_before) / sales_before, 2) AS variance_percentage
FROM four_week_before_after;

-- 2. What about the entire 12 weeks before and after?
WITH total_sales AS (
	SELECT week_date, week_number, 
		   SUM(sales) AS total_sales
	FROM clean_weekly_sales
	WHERE (week_number BETWEEN 13 AND 37) AND (calendar_year = 2020)
	GROUP BY week_date, week_number
)
, four_week_before_after AS (
	SELECT SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN total_sales END) AS sales_before,
		   SUM(CASE WHEN week_number BETWEEN 25 AND 37 THEN total_sales END) AS sales_after
	FROM total_sales
)

SELECT sales_after - sales_before AS sales_variance, 
	   ROUND(100 * (sales_after - sales_before) / sales_before, 2) AS variance_percentage
FROM four_week_before_after;

-- 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
-- 4 weeks after and before
WITH total_sales AS (
	SELECT calendar_year, week_number, 
		   SUM(sales) AS total_sales
	FROM clean_weekly_sales
	WHERE week_number BETWEEN 21 AND 28
	GROUP BY calendar_year, week_number
)
, four_week_before_after AS (
	SELECT calendar_year,
		   SUM(CASE WHEN week_number BETWEEN 21 AND 24 THEN total_sales END) AS sales_before,
		   SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN total_sales END) AS sales_after
	FROM total_sales
    GROUP BY calendar_year
)

SELECT calendar_year,
	   sales_after - sales_before AS sales_variance, 
	   ROUND(100 * (sales_after - sales_before) / sales_before, 2) AS variance_percentage
FROM four_week_before_after;

-- 12 weeks after and before
WITH total_sales AS (
	SELECT calendar_year, week_number, 
		   SUM(sales) AS total_sales
	FROM clean_weekly_sales
	WHERE week_number BETWEEN 13 AND 37
	GROUP BY calendar_year, week_number
)
, four_week_before_after AS (
	SELECT calendar_year,
		   SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN total_sales END) AS sales_before,
		   SUM(CASE WHEN week_number BETWEEN 25 AND 37 THEN total_sales END) AS sales_after
	FROM total_sales
    GROUP BY calendar_year
)

SELECT calendar_year,
	   sales_after - sales_before AS sales_variance, 
	   ROUND(100 * (sales_after - sales_before) / sales_before, 2) AS variance_percentage
FROM four_week_before_after;











