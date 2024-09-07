-----------------------
--A. Customer Journey--
-----------------------

--Based off the 8 sample customers provided in the sample from the subscriptions table, 
--write a brief description about each customer’s onboarding journey.

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



