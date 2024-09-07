# 🥑 Case Study #3 - Foodie-Fi
## A. Customer Journey
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
```TSQL
select
	s.customer_id,
	s.plan_id,
	p.plan_name,
	lead(p.plan_name) over(partition by customer_id order by start_date asc) as next_plan,
	s.start_date,
	lead(start_date) over(partition by customer_id order by start_date asc) as next_plan_date,
   DATEDIFF(day, start_date,lead(start_date) over(partition by customer_id order by start_date asc))as days_took_to_subscribe
	from foodie_fi.subscriptions s
left join foodie_fi.plans p on p.plan_id = s.plan_id
where s.customer_id in (1, 2, 11, 13, 15, 16, 18, 19);
```
| customer_id | plan_id | plan_name     | next_plan     | start_date | next_plan_date | days_took_to_subscribe |
|-------------|---------|---------------|---------------|------------|----------------|------------------------|
| 1           | 0       | trial         | basic monthly | 2020-08-01 | 2020-08-08     | 7                      |
| 1           | 1       | basic monthly | NULL          | 2020-08-08 | NULL           | NULL                   |
| 2           | 0       | trial         | pro annual    | 2020-09-20 | 2020-09-27     | 7                      |
| 2           | 3       | pro annual    | NULL          | 2020-09-27 | NULL           | NULL                   |
| 11          | 0       | trial         | churn         | 2020-11-19 | 2020-11-26     | 7                      |
| 11          | 4       | churn         | NULL          | 2020-11-26 | NULL           | NULL                   |
| 13          | 0       | trial         | basic monthly | 2020-12-15 | 2020-12-22     | 7                      |
| 13          | 1       | basic monthly | pro monthly   | 2020-12-22 | 2021-03-29     | 97                     |
| 13          | 2       | pro monthly   | NULL          | 2021-03-29 | NULL           | NULL                   |
| 15          | 0       | trial         | pro monthly   | 2020-03-17 | 2020-03-24     | 7                      |
| 15          | 2       | pro monthly   | churn         | 2020-03-24 | 2020-04-29     | 36                     |
| 15          | 4       | churn         | NULL          | 2020-04-29 | NULL           | NULL                   |
| 16          | 0       | trial         | basic monthly | 2020-05-31 | 2020-06-07     | 7                      |
| 16          | 1       | basic monthly | pro annual    | 2020-06-07 | 2020-10-21     | 136                    |
| 16          | 3       | pro annual    | NULL          | 2020-10-21 | NULL           | NULL                   |
| 18          | 0       | trial         | pro monthly   | 2020-07-06 | 2020-07-13     | 7                      |
| 18          | 2       | pro monthly   | NULL          | 2020-07-13 | NULL           | NULL                   |
| 19          | 0       | trial         | pro monthly   | 2020-06-22 | 2020-06-29     | 7                      |
| 19          | 2       | pro monthly   | pro annual    | 2020-06-29 | 2020-08-29     | 61                     |
| 19          | 3       | pro annual    | NULL          | 2020-08-29 | NULL           | NULL                   |


Customer 1 signed up for a free trial on the 1st of August 2020 and decided to subscribe to the basic monthly plan right after it ended.

Customer 2 signed up for a free trial on the 20th of September 2020 and decided to upgrade to the pro annual plan right after it ended.

Customer 11 signed up for a free trial on the 19th of November 2020 and decided to cancel their subscription on the billing date.

Customer 13 signed up for a free trial on the 15th of December 2020, decided to subscribe to the basic monthly plan right after it ended and upgraded to the pro monthly plan three months later.

Customer 15 signed up for a free trial on the 17th of March 2020 and then decided to upgrade to the pro monthly plan right after it ended for one month before cancelling it.

Customer 16 signed up for a free trial on the 31st of May 2020, decided to subscribe to the basic monthly plan right after it ended and upgraded to the pro annual plan four months later.

Customer 18 signed up for a free trial on the 6th of July 2020 and then went on to pay for the pro monthly plan right after it ended.

Customer 19 signed up for a free trial on the 22nd of June 2020, went on to pay for the pro monthly plan right after it ended and upgraded to the pro annual plan two months in.

Customer 19 signed up to 7-day free trial on 22/06/2020. After that time, he/she upgraded the subscription to pro monthly plan on 29/06/2020. After 2 months using that plan, he/she upgraded to pro annual plan on 29/08/2020.

---
My solution for **[B. Data Analysis Questions](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution/B.%20Data%20Analysis%20Questions.md)**.
