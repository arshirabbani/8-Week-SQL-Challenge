------------------------
--CASE STUDY QUESTIONS--
------------------------

--Author: Arshi Rabbani
--Date: 25/08/2024
--Tool used: SQL Server


---1. How many pizzas were ordered?

select count(order_id) as total_pizzas from #customer_orders_temp;

---2. How many unique customer orders were made?

select count(distinct order_id) as unique_order_count from #customer_orders_temp;

---3. How many successful orders were delivered by each runner?

select runner_id, count(order_id) as successful_order_count
from #runner_orders_temp
where cancellation is null
group by runner_id;

---4. How many of each type of pizza was delivered?

select pizza_name , count( co.order_id)  as  pizza_delivered
from pizza_runner.#customer_orders_temp co
inner join pizza_runner.pizza_names pn on co.pizza_id = pn.pizza_id
inner join #runner_orders_temp ro on ro.order_id = co.order_id
where cancellation is null
group by pizza_name

---5. How many Vegetarian and Meatlovers were ordered by each customer?

select customer_id,
sum(case when pizza_name = 'Meatlovers' then 1 else 0 end) as Meatlovers_pizza,
sum(case when pizza_name = 'Vegetarian' then 1 else 0 end) as Vegetarian_pizza
from #customer_orders_temp co
inner join pizza_runner.pizza_names pn on co.pizza_id = pn.pizza_id
group by customer_id;

---6. What was the maximum number of pizzas delivered in a single order?

select TOP 1 co.order_id, count(pizza_id) as max_pizza_count
from #customer_orders_temp co
inner join #runner_orders_temp  ro on ro.order_id = co.order_id
where cancellation is null
group by co.order_id
order by pizza_count desc;

---7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select customer_id,
sum(case when (exclusions != '' or extras != '') then 1 else 0 end) as had_change,
sum(case when (exclusions = '' and extras = '') then 1 else 0 end) as no_change
from #customer_orders_temp co
inner join #runner_orders_temp ro on ro.order_id = co.order_id
where cancellation is null
group  by customer_id;

---8. How many pizzas were delivered that had both exclusions and extras?

select count( pizza_id) as pizza_count_with_both_changes
from #customer_orders_temp co
inner join #runner_orders_temp ro on ro.order_id = co.order_id
where cancellation is null
and exclusions  != '' and extras != '';

---9. What was the total volume of pizzas ordered for each hour of the day?

select DATEPART(hour, order_time) as hour_of_day, 
count(pizza_id) as pizzas_ordered
from #customer_orders_temp co
group by DATEPART(hour, order_time);

---10. What was the volume of orders for each day of the week?

select DATENAME(WEEKDAY, order_time) as week_day,
count(order_id) as pizzas_ordered
from #customer_orders_temp co
group by DATENAME(WEEKDAY, order_time),  DATEPART(WEEKDAY, order_time) --for weekdayorder
order by DATEPART(WEEKDAY, order_time);