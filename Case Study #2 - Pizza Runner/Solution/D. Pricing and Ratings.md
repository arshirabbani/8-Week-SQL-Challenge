# 🍕 Case Study #2 - Pizza Runner
## D. Pricing and Ratings
### 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

```TSQL
select sum(case when pizza_id = 1 then 12 when pizza_id = 2 then 10 end ) as money_earned
from #customer_orders_temp co
inner join #runner_orders_temp ro on co.order_id = ro.order_id
where cancellation is  null;
```
| money_earned  |
|---------------|
| 138           |

---
### 2. What if there was an additional $1 charge for any pizza extras?
* Add cheese is $1 extra
```TSQL
DECLARE @money_earned INT
SET @money_earned =  /* 138 (result from previous query) OR */
( select sum(case when pizza_id = 1 then 12 when pizza_id = 2 then 10 end ) as money_earned
from #customer_orders_temp co
inner join #runner_orders_temp ro on co.order_id = ro.order_id
where cancellation is  null 
) 

select @money_earned + sum(case when topping_name= 'Cheese' then 2 ELSE 1 END)  as total_earned
from #extras_temp et
inner Join pizza_runner.pizza_toppings pt on  pt.topping_id = extra_id;
```
| total_earned  |
|----------------|
| 145            |

---
### 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
```TSQL
DROP TABLE IF EXISTS pizza_runner.ratings
CREATE TABLE pizza_runner.ratings (
  order_id INT,
  rating INT
);
INSERT INTO pizza_runner.ratings 
  (order_id, rating)
VALUES
  (1,4),  (2,1),  (3,4),  (4,5),  (5,3),  (6,4),  (7,2),  (8,5),  (9,3),  (10,4);
  
SELECT *   FROM pizza_runner.ratings;
 ```
| order_id | rating  |
|----------|---------|
| 1        | 4       |
| 2        | 1       |
| 3        | 4       |
| 4        | 5       |
| 5        | 3       |
| 6        | 4       |
| 7        | 2       |
| 8        | 5       |
| 9        | 3       |
| 10       | 4       |

---
### 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?


```TSQL
select 
co.customer_id,
co.order_id,
ro.runner_id,
r.rating,
co.order_time,
ro.pickup_time,
datediff(minute, co.order_time, ro.pickup_time) as time_to_pick,
ro.duration,
round(avg(distance/ duration * 60), 2) avg_speed,
count(co.pizza_id) as pizza_count
from #customer_orders_temp co
inner join #runner_orders_temp ro on co.order_id = ro.order_id
inner join pizza_runner.ratings r on co.order_id = r.order_id
where ro.cancellation IS NULL
group by co.customer_id,
co.order_id,
ro.runner_id,
r.rating,
co.order_time,
ro.pickup_time,
ro.duration;

  ```
| customer_id | order_id | runner_id | order_time              | pickup_time             | time_to_pick    | duration | avg_speed | pizza_count  |
|-------------|----------|-----------|-------------------------|-------------------------|-----------------|----------|-----------|--------------|
| 101         | 1        | 1         | 2020-01-01 18:05:02.000 | 2020-01-01 18:15:34.000 | 10              | 32       | 37.5      | 1            |
| 101         | 2        | 1         | 2020-01-01 19:00:52.000 | 2020-01-01 19:10:54.000 | 10              | 27       | 44.4      | 1            |
| 102         | 3        | 1         | 2020-01-02 23:51:23.000 | 2020-01-03 00:12:37.000 | 21              | 20       | 40.2      | 2            |
| 102         | 8        | 2         | 2020-01-09 23:54:33.000 | 2020-01-10 00:15:02.000 | 21              | 15       | 93.6      | 1            |
| 103         | 4        | 2         | 2020-01-04 13:23:46.000 | 2020-01-04 13:53:03.000 | 30              | 40       | 35.1      | 3            |
| 104         | 5        | 3         | 2020-01-08 21:00:29.000 | 2020-01-08 21:10:57.000 | 10              | 15       | 40        | 1            |
| 104         | 10       | 1         | 2020-01-11 18:34:49.000 | 2020-01-11 18:50:20.000 | 16              | 10       | 60        | 2            |
| 105         | 7        | 2         | 2020-01-08 21:20:29.000 | 2020-01-08 21:30:45.000 | 10              | 25       | 60        | 1            |

---
### 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
```TSQL
DECLARE @money_earned INT
SET @money_earned = 138 -- (result of first query)

select @money_earned as revenue,
sum(distance * 0.3) as paid_to_runner,
 @money_earned - sum(distance * 0.3) as money_left
from #runner_orders_temp;
```
| revenue | paid_to_runner | money_left  |
|---------|----------------|-------------|
| 138     | 43.56          | 94.44       |

---
My solution for **[E. Bonus questions]**.
