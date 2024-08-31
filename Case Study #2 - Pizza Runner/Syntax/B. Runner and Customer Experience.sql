-------------------------------
--Author: Arshi Rabbani
--Date: 25/08/2024
--Tool used: SQL Server

---1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

select 
DATENAME(WEEK, registration_date) as week_of_month,
Count(1) as runner_signed_up
from pizza_runner.runners
group  by DATENAME(WEEK, registration_date);

---2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

with pick_up as (
select runner_id, co.order_id,
datediff(minute, order_time, pickup_time) as time_taken_to_pick
from #customer_orders_temp co
inner join #runner_orders_temp ro on ro.order_id = co.order_id
where ro.cancellation is NULL
group by runner_id, co.order_id,co.order_time, pickup_time
)
select runner_id, avg(time_taken_to_pick) as time_taken_to_pick
from pick_up group by runner_id;

---3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

with pizza_prep as (
select co.order_id, count(pizza_id) as pizza_count,
DATEDIFF(minute, order_time, pickup_time) as  prepare_time
from #customer_orders_temp co
inner join #runner_orders_temp ro on ro.order_id = co.order_id
where ro.cancellation is NULL
group by co.order_id, order_time, pickup_time)
select  pizza_count, avg(prepare_time) as avg_prepare_time 
from pizza_prep group by pizza_count;

---4. What was the average distance travelled for each customer?

select customer_id, 
round(avg( distance),1) avg_distance_travelled
from #customer_orders_temp co
inner join #runner_orders_temp ro on ro.order_id = co.order_id
where ro.cancellation is NULL
group by customer_id;

---5. What was the difference between the longest and shortest delivery times for all orders?

with delivery_time as (
select co.order_id, 
DATEDIFF(minute, order_time, pickup_time) as delivery_time
from #customer_orders_temp co
inner join #runner_orders_temp ro 
on ro.order_id = co.order_id
where ro.cancellation is NULL)
select max(delivery_time) as max_delivery_time, 
min(delivery_time) as min_delivery_time,
max(delivery_time) - min(delivery_time) as diff_bw_long_short
from delivery_time;

---6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

select runner_id, co.order_id, distance as distance_km,
duration as duration_min, 
round((distance / duration)*60,2) as speed_kmh
from #customer_orders_temp co
inner join #runner_orders_temp ro on ro.order_id = co.order_id
where ro.cancellation is NULL
group by runner_id, co.order_id, distance,duration
order by runner_id;

---7. What is the successful delivery percentage for each runner?

select runner_id,
count(order_id) as total_order,
count(distance) as delivered_orders,
100* count(distance)/ count(order_id) as successful_perc
from  #runner_orders_temp
group by runner_id;