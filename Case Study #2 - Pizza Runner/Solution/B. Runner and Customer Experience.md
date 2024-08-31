# 🍕 Case Study #2 - Pizza Runner
## B. Runner and Customer Experience

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
```TSQL
select 
DATENAME(WEEK, registration_date) as week_of_month,
Count(1) as runner_signed_up
from pizza_runner.runners
group  by DATENAME(WEEK, registration_date);
```
| week_of_month | runner_signed_up  |
|-------------|---------------|
| 1           | 1             |
| 2           | 2             |
| 3           | 1             |

---
### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
```TSQL
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
```
| runner_id | time_taken_to_pick  |
|-----------|---------------|
| 1         | 14            |
| 2         | 20            |
| 3         | 10            |

---
### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
```TSQL
with pizza_prep as (
select co.order_id, count(pizza_id) as pizza_count,
DATEDIFF(minute, order_time, pickup_time) as  prepare_time
from #customer_orders_temp co
inner join #runner_orders_temp ro on ro.order_id = co.order_id
where ro.cancellation is NULL
group by co.order_id, order_time, pickup_time)
select  pizza_count, avg(prepare_time) as avg_prepare_time 
from pizza_prep group by pizza_count;
```
| pizza_count | avg_prepare_time  |
|-------------|----------------|
| 1           | 12             |
| 2           | 18             |
| 3           | 30             |

* More pizzas, longer time to prepare. 
* 2 pizzas took 6 minutes more to prepare, 3 pizza took 12 minutes more to prepare.
* On average, it took 6 * (number of pizzas - 1) minutes more to prepare the next pizza.

---
### 4. What was the average distance travelled for each customer?
```TSQL
select customer_id, 
round(avg( distance),1) avg_distance_travelled
from #customer_orders_temp co
inner join #runner_orders_temp ro on ro.order_id = co.order_id
where ro.cancellation is NULL
group by customer_id;
```
| customer_id | avg_distance_travelled  |
|-------------|-------------------|
| 101         | 20                |
| 102         | 16.7              |
| 103         | 23.4              |
| 104         | 10                |
| 105         | 25                |

---
### 5. What was the difference between the longest and shortest delivery times for all orders?
```TSQL
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
```
| max_delivery_time| min_delivery_time | diff_bw_long_short|
|------------------|-------------------|------------------|
| 30               | 10                | 20               |

---
### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
```TSQL
select runner_id, co.order_id, distance as distance_km,
duration as duration_min, 
round((distance / duration)*60,2) as speed_kmh
from #customer_orders_temp co
inner join #runner_orders_temp ro on ro.order_id = co.order_id
where ro.cancellation is NULL
group by runner_id, co.order_id, distance,duration
order by runner_id;
```
| runner_id | order_id | distance_km | duration_min | speed_kmh  |
|-----------|----------|-------------|--------------|------------|
| 1         | 1        | 20          | 32           | 37.5       |
| 1         | 2        | 20          | 27           | 44.4       |
| 1         | 3        | 13.4        | 20           | 40.2       |
| 1         | 10       | 10          | 10           | 60         |
| 2         | 4        | 23.4        | 40           | 35.1       |
| 2         | 7        | 25          | 25           | 60         |
| 2         | 8        | 23.4        | 15           | 93.6       |
| 3         | 5        | 10          | 15           | 40         |

* Runner ```1``` had the average speed from 37.5 km/h to 60 km/h
* Runner ```2``` had the average speed from 35.1 km/h to 93.6 km/h. With the same distance (23.4 km), order ```4``` was delivered at 35.1 km/h, while order ```8``` was delivered at 93.6 km/h. There must be something wrong here!
* Runner ```3``` had the average speed at 40 km/h

---
### 7. What is the successful delivery percentage for each runner?
```TSQL

select runner_id,
count(order_id) as total_order,
count(distance) as delivered_orders,
100* count(distance)/ count(order_id) as successful_perc
from  #runner_orders_temp
group by runner_id;

```
| runner_id | total_order | delivered_orders | successful_pct  |
|-----------|-------------|------------------|-----------------|
| 1         | 4           | 4                | 100             |
| 2         | 3           | 4                | 75              |
| 3         | 1           | 2                | 50              |

---
My solution for **[C. Ingredient Optimisation].**
