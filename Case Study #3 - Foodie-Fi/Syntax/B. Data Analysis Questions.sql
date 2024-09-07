------------------------------
--B. Data Analysis Questions--
------------------------------

--1. How many customers has Foodie-Fi ever had?

select  count(distinct customer_id) as total_customers from foodie_fi.subscriptions;

--2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value?

select 
DATENAME(MONTH, start_date) as month,
Count(customer_id) as customer_count
from foodie_fi.subscriptions
where plan_id = 0
group by DATENAME(MONTH, start_date), 
DATEPART(MONTH, start_date) 
order by DATEPART(MONTH, start_date) 

--3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name?

select 
DATEPART(YEAR, START_DATE) as Year,
plan_name, count(customer_id) as customer_count
from foodie_fi.subscriptions s 
inner join foodie_fi.plans p 
on s.plan_id = p.plan_id
where DATEPART(YEAR, START_DATE) > 2020
group  by plan_name,
DATEPART(YEAR, START_DATE);


--4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

with churn_count as (
select 
sum(case when plan_id = 4 then 1 else 0 end ) as churn_cust,
count (distinct customer_id) as total_cust
from foodie_fi.subscriptions)
select churn_cust, 
round(100* cast(churn_cust as decimal)/ cast(total_cust as decimal), 1) as churn_perc
from churn_count;


--5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

with nextplan as (
select customer_id,
case when plan_id = 0 and 
lead(plan_id) over(partition by customer_id order by start_date) = 4 then 1 else 0 end  as churn_cust
from foodie_fi.subscriptions
)
select sum(churn_cust) total_churn_post_trial,
round (cast(sum(churn_cust) as decimal)/ cast(count(distinct customer_id) as decimal) * 100, 0)  churn_post_trial_perc
from nextplan;


--6. What is the number and percentage of customer plans after their initial free trial?

with customer_plan as (
select customer_id,plan_id, 
case when plan_id = 0 then lead(plan_id) over(partition by customer_id order by start_date)
else null end as post_trial_plan
from foodie_fi.subscriptions s),
total_customer as (select count(distinct customer_id) as total_customer from foodie_fi.subscriptions
)
select plan_name,
count(post_trial_plan) as customer_per_plan,
round(cast(count(post_trial_plan) as decimal)/ cast(total_customer as decimal) * 100,2) as perc_of_total
from total_customer,
customer_plan c,
foodie_fi.plans p 
where c.post_trial_plan = p.plan_id
group by plan_name, total_customer;


--7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

with customer_plan as (
select customer_id, plan_id, start_date,
rank() over(partition by customer_id order by start_date desc) as rank
from foodie_fi.subscriptions where  start_date <= '2020-12-31')
, total_customer as (select count(distinct customer_id) as total_customer from foodie_fi.subscriptions
where start_date <= '2020-12-31'
)
select p.plan_id, p.plan_name,
count(customer_id) as customer_per_plan,
round(cast(count(customer_id) as decimal)/ cast(total_customer as decimal) * 100,2) as perc_of_total
from total_customer t,
customer_plan c,
foodie_fi.plans p 
where c.plan_id = p.plan_id and rank = 1
group by p.plan_id, p.plan_name, total_customer
order by p.plan_id;


--8. How many customers have upgraded to an annual plan in 2020?

select plan_name, count(customer_id) as cust_count
from foodie_fi.subscriptions s
inner join foodie_fi.plans p on s.plan_id = p.plan_id
where DATEPART(year, start_date) = 2020
and p.plan_id = 3
group by plan_name;
  
  
--9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

with join_date as (
select customer_id, min(start_date) as join_date
from foodie_fi.subscriptions group by customer_id),
upgrade_date as (select customer_id, start_date as upgrade_date
from foodie_fi.subscriptions where plan_id = 3 )
select avg(DATEDIFF(day, join_date, upgrade_date))  avg_days_to_upgrade
from join_date j
inner join upgrade_date u
on j.customer_id = u.customer_id;


--10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)?
WITH join_date AS ( 
                   SELECT customer_id,
                          MIN(start_date) AS join_date
                   FROM   foodie_fi.subscriptions
                   GROUP  BY customer_id
                  ),
  upgrade_date AS (
                   SELECT customer_id,
                          start_date AS upgrade_date
                   FROM   foodie_fi.subscriptions
                   WHERE  plan_id = 3
                   GROUP  BY customer_id, start_date
                   ),
  buckets AS ( 
                  SELECT 
				  
				  case when DATEDIFF(day,join_date, upgrade_date) between 0 and 30 then '0 - 30'
				  when DATEDIFF(day,join_date, upgrade_date) between 31 and 60 then '31 - 60'
				  when DATEDIFF(day,join_date, upgrade_date) between 61 and 90 then '61 - 90'
				  when DATEDIFF(day,join_date, upgrade_date) between 91 and 120 then '91 - 120'
				  when DATEDIFF(day,join_date, upgrade_date) between 121 and 150 then '121 - 150'
				  when DATEDIFF(day,join_date, upgrade_date) between 151 and 180 then '151 -180'
				  when DATEDIFF(day,join_date, upgrade_date) between 181 and 210 then '181 - 210'
				  when DATEDIFF(day,join_date, upgrade_date) between 211 and 240 then '211 - 240'
				  when DATEDIFF(day,join_date, upgrade_date) between 241 and 270 then '241 - 270'
				  when DATEDIFF(day,join_date, upgrade_date) between 271 and 300 then '271 - 300'
				  when DATEDIFF(day,join_date, upgrade_date) between 301 and 330 then '301 - 330'
				  when DATEDIFF(day,join_date, upgrade_date) between 331 and 360 then '331 - 360'
				  end AS bucket,
				  u.customer_id,
				  DATEDIFF(day,join_date, upgrade_date) as days_took
                 FROM   join_date AS j
                  JOIN   upgrade_date AS u
                  ON     j.customer_id = u.customer_id
                                  )
select cast (bucket as text) as period,
       count(customer_id) as cust_count,
       avg(days_took) as average_days
FROM   buckets
GROUP  BY bucket
order by bucket


--11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
 
with downgraded_basic as (
select customer_id,plan_id, start_date,
case when plan_id = 2 and lead(plan_id) over(partition by customer_id order by start_date) = 1 then 1
else 0 end as downgraded_basic
from foodie_fi.subscriptions
where DATEPART(year, start_date) = 2020
)
select sum(downgraded_basic) as downgraded from downgraded_basic;
