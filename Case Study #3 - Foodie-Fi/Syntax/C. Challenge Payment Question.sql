---------------------------------
--C. Challenge Payment Question--
---------------------------------

/*
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid 
by each customer in the subscriptions table with the following requirements:
- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments
*/


--Use a recursive CTE to increment rows for all monthly paid plans in 2020 until customers changing their plans, except 'pro annual'
WITH dateRecursion AS (
  SELECT 
    s.customer_id,
    s.plan_id,
    p.plan_name,
    s.start_date AS payment_date,
    CASE 
       WHEN LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) IS NULL THEN '2020-12-31'
            ELSE DATEADD(MONTH, 
		   DATEDIFF(MONTH, start_date, LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date)),
		   start_date) END AS last_date,
    p.price AS amount
  FROM foodie_fi.subscriptions s
  JOIN foodie_fi.plans p ON s.plan_id = p.plan_id
  
  WHERE p.plan_name NOT IN ('trial')
    AND YEAR(start_date) = 2020

  UNION ALL

  SELECT 
    customer_id,
    plan_id,
    plan_name,
    DATEADD(MONTH, 1, payment_date) AS payment_date,
    last_date,
    amount
  FROM dateRecursion
   WHERE DATEADD(MONTH, 1, payment_date) <= last_date
    AND plan_name != 'pro annual'
)
--Create a new table [payments]
SELECT 
  customer_id,
  plan_id,
  plan_name,
  payment_date,
  amount,
  ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS payment_order
INTO payments
FROM dateRecursion
WHERE amount IS NOT NULL
ORDER BY customer_id
OPTION (MAXRECURSION 365);



