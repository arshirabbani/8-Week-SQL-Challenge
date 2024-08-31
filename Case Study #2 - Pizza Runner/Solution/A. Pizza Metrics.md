# 🍕 Case Study #2 - Pizza Runner
## A. Pizza Metrics
### Data cleaning
  
  * Create a temporary table ```#customer_orders_temp``` from ```customer_orders``` table:
  	* Convert ```null``` values and ```'null'``` text values in ```exclusions``` and ```extras``` into blank ```''```.
  
  ```TSQL
  SELECT 
    order_id,
    customer_id,
    pizza_id,
    CASE 
    	WHEN exclusions IS NULL OR exclusions LIKE 'null' THEN ''
      	ELSE exclusions 
      	END AS exclusions,
    CASE 
    	WHEN extras IS NULL OR extras LIKE 'null' THEN ''
      	ELSE extras 
      	END AS extras,
    order_time
  INTO #customer_orders_temp
  FROM customer_orders;
  
  SELECT *
  FROM #customer_orders_temp;
  ```
| order_id | customer_id | pizza_id | exclusions | extras | order_time               |
|----------|-------------|----------|------------|--------|--------------------------|
| 1        | 101         | 1        |            |        | 2020-01-01 18:05:02.000  |
| 2        | 101         | 1        |            |        | 2020-01-01 19:00:52.000  |
| 3        | 102         | 1        |            |        | 2020-01-02 23:51:23.000  |
| 3        | 102         | 2        |            |        | 2020-01-02 23:51:23.000  |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46.000  |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46.000  |
| 4        | 103         | 2        | 4          |        | 2020-01-04 13:23:46.000  |
| 5        | 104         | 1        |            | 1      | 2020-01-08 21:00:29.000  |
| 6        | 101         | 2        |            |        | 2020-01-08 21:03:13.000  |
| 7        | 105         | 2        |            | 1      | 2020-01-08 21:20:29.000  |
| 8        | 102         | 1        |            |        | 2020-01-09 23:54:33.000  |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10 11:22:59.000  |
| 10       | 104         | 1        |            |        | 2020-01-11 18:34:49.000  |
| 10       | 104         | 1        | 2,6        | 1,4    | 2020-01-11 18:34:49.000  |
 
  
  * Create a temporary table ```#runner_orders_temp``` from ```runner_orders``` table:
  	* Convert ```'null'``` text values in ```pickup_time```, ```duration``` and ```cancellation``` into ```null``` values. 
	* Cast ```pickup_time``` to DATETIME.
	* Cast ```distance``` to FLOAT.
	* Cast ```duration``` to INT.
  
  ```TSQL
  SELECT 
    order_id,
    runner_id,
    CAST(
    	CASE WHEN pickup_time LIKE 'null' THEN NULL ELSE pickup_time END 
	    AS DATETIME) AS pickup_time,
    CAST(
    	CASE WHEN distance LIKE 'null' THEN NULL
	      WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
	      ELSE distance END
      AS FLOAT) AS distance,
    CAST(
    	CASE WHEN duration LIKE 'null' THEN NULL
	      WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
	      WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
	      WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
	      ELSE duration END
      AS INT) AS duration,
    CASE WHEN cancellation IN ('null', 'NaN', '') THEN NULL 
        ELSE cancellation
        END AS cancellation
INTO #runner_orders_temp
FROM runner_orders;
  
SELECT *
FROM #runner_orders_temp;

```
| order_id | runner_id | pickup_time             | distance | duration | cancellation             |
|----------|-----------|-------------------------|----------|----------|--------------------------|
| 1        | 1         | 2020-01-01 18:15:34.000 | 20       | 32       | NULL                     |
| 2        | 1         | 2020-01-01 19:10:54.000 | 20       | 27       | NULL                     |
| 3        | 1         | 2020-01-03 00:12:37.000 | 13.4     | 20       | NULL                     |
| 4        | 2         | 2020-01-04 13:53:03.000 | 23.4     | 40       | NULL                     |
| 5        | 3         | 2020-01-08 21:10:57.000 | 10       | 15       | NULL                     |
| 6        | 3         | NULL                    | NULL     | NULL     | Restaurant Cancellation  |
| 7        | 2         | 2020-01-08 21:30:45.000 | 25       | 25       | NULL                     |
| 8        | 2         | 2020-01-10 00:15:02.000 | 23.4     | 15       | NULL                     |
| 9        | 2         | NULL                    | NULL     | NULL     | Customer Cancellation    |
| 10       | 1         | 2020-01-11 18:50:20.000 | 10       | 10       | NULL                     |

---
### 1. How many pizzas were ordered?

```TSQL
select count(order_id) as total_pizzas from #customer_orders_temp;
```
| total_pizzas  |
|--------------|
| 14           |

---

### 2. How many unique customer orders were made?
```TSQL
select count(distinct order_id) as unique_order_count from #customer_orders_temp;
```
| unique_order_count  |
|--------------|
| 10           |

---
### 3. How many successful orders were delivered by each runner?
```TSQL
select runner_id, count(order_id) as successful_order_count
from #runner_orders_temp
where cancellation is null
group by runner_id;

```
| runner_id | successful_order_count  |
|-----------|--------------------|
| 1         | 4                  |
| 2         | 3                  |
| 3         | 1                  |

---
### 4. How many of each type of pizza was delivered?
```TSQL
select pizza_name , count( co.order_id)  as  pizza_delivered
from pizza_runner.#customer_orders_temp co
inner join pizza_runner.pizza_names pn on co.pizza_id = pn.pizza_id
inner join #runner_orders_temp ro on ro.order_id = co.order_id
where cancellation is null
group by pizza_name
```

| pizza_name | pizza_delivered|
|------------|----------------|
| Meatlovers | 9              |
| Vegetarian | 3              |

---
### 5. How many Vegetarian and Meatlovers were ordered by each customer?
```TSQL
select customer_id,
sum(case when pizza_name = 'Meatlovers' then 1 else 0 end) as Meatlovers_pizza,
sum(case when pizza_name = 'Vegetarian' then 1 else 0 end) as Vegetarian_pizza
from #customer_orders_temp co
inner join pizza_runner.pizza_names pn on co.pizza_id = pn.pizza_id
group by customer_id;
```
| customer_id | Meatlovers_pizza | Vegetarian_pizza  |
|-------------|------------|-------------|
| 101         | 2          | 1           |
| 102         | 2          | 1           |
| 103         | 3          | 1           |
| 104         | 3          | 0           |
| 105         | 0          | 1           |

---
### 6. What was the maximum number of pizzas delivered in a single order?
```TSQL
select TOP 1 co.order_id, count(pizza_id) as max_pizza_count
from #customer_orders_temp co
inner join #runner_orders_temp  ro on ro.order_id = co.order_id
where cancellation is null
group by co.order_id
order by pizza_count desc;
```
| order_id   | max_pizza_count  |
|------------|------------|
| 3          | 3          |

---
### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
```TSQL
select customer_id,
sum(case when (exclusions != '' or extras != '') then 1 else 0 end) as had_change,
sum(case when (exclusions = '' and extras = '') then 1 else 0 end) as no_change
from #customer_orders_temp co
inner join #runner_orders_temp ro on ro.order_id = co.order_id
where cancellation is null
group  by customer_id;
```
| customer_id | had_change | no_change  |
|-------------|------------|------------|
| 101         | 0          | 2          |
| 102         | 0          | 3          |
| 103         | 3          | 0          |
| 104         | 2          | 1          |
| 105         | 1          | 0          |

---
### 8. How many pizzas were delivered that had both exclusions and extras?
```TSQL
select count( pizza_id) as pizza_count_with_both_changes
from #customer_orders_temp co
inner join #runner_orders_temp ro on ro.order_id = co.order_id
where cancellation is null
and exclusions  != '' and extras != '';
```
| pizza_count_with_both_changes  |
|--------------|
| 1            |

---
### 9. What was the total volume of pizzas ordered for each hour of the day?
```TSQL
select DATEPART(hour, order_time) as hour_of_day, 
count(pizza_id) as pizzas_ordered
from #customer_orders_temp co
group by DATEPART(hour, order_time);
```
| hour_of_day | pizzas_ordered  |
|-------------|---------------|
| 11          | 1             |
| 13          | 3             |
| 18          | 3             |
| 19          | 1             |
| 21          | 3             |
| 23          | 3             |

---
### 10. What was the volume of orders for each day of the week?
```TSQL
select DATENAME(WEEKDAY, order_time) as week_day,
count(order_id) as pizzas_ordered
from #customer_orders_temp co
group by DATENAME(WEEKDAY, order_time),  DATEPART(WEEKDAY, order_time) --for weekdayorder
order by DATEPART(WEEKDAY, order_time);
```
| week_day  | order_volume  |
|-----------|---------------|
| Wednesday | 5             |
| Thursday  | 3             |
| Friday    | 1             |
| Saturday  | 5             |

---
My solution for **[B. Runner and Customer Experience](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/Solution/B.%20Runner%20and%20Customer%20Experience.md)**.
