-- ** A. Customer Journey ** -- 
-- Based off the 8 sample customers provided in the sample from the subscriptions table, 
-- write a brief description about each customer’s onboarding journey.
SELECT s.customer_id, p.plan_id, p.plan_name, s.start_date
FROM plans p 
JOIN subscriptions s ON p.plan_id = s.plan_id
WHERE s.customer_id IN (1, 2, 11, 13, 15, 16, 18, 19);

/*
1. Customer 1:
- Signed up for a free trial on August 1, 2020
- Subcribed to the basic monthly plan immediately after the 7-day trial.
2. Customer 2:
- Signed up for a free trial on September 20, 2020
- Upgraded to the pro annual plan immediately after the 7-day trial.
3. Customer 11:
- Signed up for a free trial on November 19, 2020
- Canceled the subscription immediately after the 7-day trial.
4. Customer 13:
- Signed up for a free trial on December 15, 2020.
- Subcribed to the basic monthly plan immediately after the 7-day trial.
- Upgraded to the pro monthly plan after approximately 97 days (around 3 months later).
5. Customer 15:
- Signed up for a free trial on March 17, 2020.
- Upgraded to the pro monthly plan immediately after the 7-day trial.
- Canceled the subscription after 36 days.
6. Customer 16:
- Signed up for a free trial on May 31, 2020.
- Upgraded to the basic monthly plan.
- After more than 4 months, upgraded to the pro annual plan.
7. Customer 18:
- Signed up for a free trial on July 6, 2020.
- Upgraded to the pro monthly plan immediately after the 7-day trial.
8. Customer 19:
- Signed up for a free trial on June 22, 2020.
- Upgraded to the pro monthly plan.
- Later, upgraded to the pro annual plan.
*/