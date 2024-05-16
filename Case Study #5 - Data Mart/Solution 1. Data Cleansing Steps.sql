-- ** 1. Data Cleansing Steps ** --
/*
- Convert the week_date to a DATE format
- Add a week_number as the second column for each week_date value, 
for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
- Add a month_number with the calendar month for each week_date value as the 3rd column
- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
- Add a new column called age_band after the original segment column using the following mapping on 
the number inside the segment value
*/
DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TEMPORARY TABLE clean_weekly_sales AS (
SELECT STR_TO_DATE(week_date, '%d/%m/%y') AS week_date,
       WEEK(STR_TO_DATE(week_date, '%d/%m/%y')) AS week_number,
       MONTH(STR_TO_DATE(week_date, '%d/%m/%y')) AS month_number,
       YEAR(STR_TO_DATE(week_date, '%d/%m/%y')) AS calendar_year,
       region, 
       platform, 
       segment,
       CASE 
           WHEN RIGHT(segment,1) = '1' THEN 'Young Adults'
           WHEN RIGHT(segment,1) = '2' THEN 'Middle Aged'
           WHEN RIGHT(segment,1) in ('3','4') THEN 'Retirees'
           ELSE 'unknown' END AS age_band,
       CASE 
           WHEN LEFT(segment,1) = 'C' THEN 'Couples'
           WHEN LEFT(segment,1) = 'F' THEN 'Families'
           ELSE 'unknown' END AS demographic,
       transactions,
       ROUND((sales/transactions),2) AS avg_transaction,
       sales
FROM weekly_sales
);

SELECT * FROM clean_weekly_sales;

