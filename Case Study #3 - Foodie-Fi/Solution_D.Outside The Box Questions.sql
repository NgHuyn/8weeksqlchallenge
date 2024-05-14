-- ** D. Outside The Box Questions ** --
-- 1. How would you calculate the rate of growth for Foodie-Fi?
/*
Start by determining the total revenue for each year.
Calculate the year-over-year growth rate by comparing the revenue of the current year with the revenue of the previous year.
Apply the growth rate formula, if the result is positive, it indicates growth, while a negative result indicates a decline.
*/
-- Revenue Growth Calculation
SELECT EXTRACT(YEAR FROM start_date) AS year,
	   SUM(CASE WHEN p.plan_id NOT IN (0, 4) THEN price ELSE 0 END) AS revenue
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
GROUP BY year
ORDER BY year;

/*
The data provided indicates a significant decrease in Foodie-Fi's revenue from 2020 to 2021. 
In 2020, the revenue stood at 53,663.30 currency units, while in 2021, it decreased to 13,810.20 currency units.

There could be several reasons to explain this decline, including market competition, 
changes in Foodie-Fi's business strategy, or even external factors such as the pandemic or market shifts. 
To understand the cause of this decline better, further analysis of other factors such as product strategy, 
pricing strategy, and customer feedback may be necessary.
*/

-- 2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
/*
1. Revenue Metrics:
- Total Revenue: Track total revenue generated over specific periods, such as monthly, quarterly, or annually.
- Revenue Growth Rate: Measure the percentage change in revenue from one period to another to gauge the company's growth trajectory.
- Average Revenue Per User (ARPU): Calculate the average revenue generated per customer to understand the revenue contribution of each user.
2. Customer Metrics:
- Customer Acquisition Cost (CAC): Determine the cost incurred to acquire a new customer, including marketing and sales expenses.
- Customer Lifetime Value (CLTV): Estimate the total revenue a customer is expected to generate throughout their relationship with Foodie-Fi.
- Churn Rate: Monitor the percentage of customers who unsubscribe or cancel their subscriptions over a specific period.
3. Engagement Metrics:
- Active Users: Monitor the number of active users accessing the platform within a given timeframe.
- Content Consumption: Analyze the frequency and duration of content consumption to gauge user engagement.
- Feature Adoption: Track the adoption rates of new features or services introduced by Foodie-Fi.
4. Market Metrics:
- Market Share: Evaluate Foodie-Fi's market share relative to competitors in the online streaming industry.
- Customer Satisfaction: Measure customer satisfaction through surveys, feedback ratings, and Net Promoter Score (NPS).
*/

-- 3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
/*
To improve customer retention, it's crucial to analyze key customer journeys or experiences that can significantly impact their 
satisfaction and loyalty. Here are some key customer journeys or experiences to analyze further:
1. Onboarding Process:
- Evaluate the ease of the sign-up process and initial account setup.
- Analyze the clarity of communication about available plans, features, and benefits.
- Assess the effectiveness of onboarding tutorials or guides to help customers get started.
2. Content Discovery and Consumption:
- Examine how customers discover new content on the platform.
- Analyze the relevance and personalization of content recommendations.
- Evaluate the user interface and navigation for ease of content exploration.
- Monitor the frequency and duration of content consumption sessions.
3. Customer Support Interactions:
- Track the volume and types of customer support inquiries.
- Assess the responsiveness and effectiveness of customer support responses.
- Analyze customer feedback and sentiment following support interactions.
- Identify common pain points or issues reported by customers.
4. Billing and Payment Process:
- Evaluate the transparency and clarity of billing information.
- Monitor the frequency of billing-related inquiries or issues.
- Assess the ease of updating payment methods or managing subscriptions.
- Analyze customer behavior following failed payment attempts or payment processing errors.
5. Engagement with Features and Benefits:
- Examine usage patterns for premium features or benefits offered by Foodie-Fi.
- Assess the perceived value of different subscription plans and perks.
- Identify features that drive higher engagement and satisfaction among customers.
- Analyze the impact of feature updates or additions on customer retention.
6. Renewal and Churn Prevention:
- Monitor customer renewal rates and identify factors influencing renewal decisions.
- Analyze the timing and frequency of churn among different customer segments.
- Identify signals indicating potential churn, such as declining usage or engagement.
- Develop proactive strategies to prevent churn, such as targeted offers or incentives.
*/

-- 4. If the Foodie-Fi team were to create an exit survey shown to customers who wish
-- to cancel their subscription, what questions would you include in the survey?
/*
1. Overall Experience:
- How would you rate your overall experience with Foodie-Fi?
- What did you like most about Foodie-Fi?
- What aspects of Foodie-Fi could be improved?
2. Reasons for Cancellation:
- What is the primary reason for canceling your Foodie-Fi subscription?
- Did you encounter any specific issues or challenges that influenced your decision to cancel?
- Were there any features or content missing from Foodie-Fi that you were hoping to see?
3. Competitive Comparison:
- Have you tried any alternative services similar to Foodie-Fi? If yes, which ones?
- How does Foodie-Fi compare to these alternative services in terms of content quality, user experience, and value for money?
4. Feedback on Content and Features:
- Which specific types of content did you enjoy the most on Foodie-Fi?
- Were there any features or functionalities of Foodie-Fi that you found particularly useful or enjoyable?
- Were there any features or content categories that you felt were lacking or could be improved?
5. Customer Support and Communication:
- How satisfied were you with the customer support provided by Foodie-Fi during your subscription?
- Did you feel adequately informed about updates, changes, or promotions related to your Foodie-Fi subscription?
6. Future Considerations:
- Would you consider reactivating your Foodie-Fi subscription in the future? If not, why?
- What changes or improvements could Foodie-Fi make to encourage you to reconsider your decision to cancel?
7. Demographic Information:
- Optional: Age range
- Optional: Gender
- Optional: Geographic location
*/

-- 5. What business levers could the Foodie-Fi team use to reduce the customer churn rate?
-- How would you validate the effectiveness of your ideas?
/*
To reduce customer churn rate, Foodie-Fi could:
- Enhance content quality.
- Improve user experience.
- Personalize recommendations.
- Initiate customer engagement efforts.
- Enhance customer support.
- Offer flexible subscription plans.
To validate effectiveness:
- Conduct A/B testing.
- Gather feedback through surveys.
- Analyze retention metrics.
- Study user behavior data.
*/