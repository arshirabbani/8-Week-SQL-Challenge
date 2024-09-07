# 🍕 Case Study #2 - Pizza Runner
## C. Ingredient Optimisation
### Data cleaning

**1. Create a new temporary table ```#pizza_topping_names``` to separate ```topping_id``` into multiple rows**
```TSQL
DROP TABLE IF EXISTS #pizza_topping_names;

select pr.pizza_id, 
pizza_name, 
trim (value) as topping_id, 
topping_name
INTO #pizza_topping_names
from  pizza_runner.pizza_recipes pr
cross apply string_split(toppings, ',') 
inner join pizza_runner.pizza_toppings pt  
on pt.topping_id = trim(value)
inner join pizza_runner.pizza_names pn 
on pr.pizza_id = pn.pizza_id;

select * from #pizza_topping_names;
```
  
| pizza_id | pizza_name   | topping_id | topping_name  |
|----------|--------------|------------|---------------|
| 1        | Meatlovers   | 1          | Bacon         |
| 1        | Meatlovers   | 2          | BBQ Sauce     |
| 1        | Meatlovers   | 3          | Beef          |
| 1        | Meatlovers   | 4          | Cheese        |
| 1        | Meatlovers   | 5          | Chicken       |
| 1        | Meatlovers   | 6          | Mushrooms     |
| 1        | Meatlovers   | 8          | Pepperoni     |
| 1        | Meatlovers   | 10         | Salami        |
| 2        | Vegetarian   | 4          | Cheese        |
| 2        | Vegetarian   | 6          | Mushrooms     |
| 2        | Vegetarian   | 7          | Onions        |
| 2        | Vegetarian   | 9          | Peppers       |
| 2        | Vegetarian   | 11         | Tomatoes      |
| 2        | Vegetarian   | 12         | Tomato Sauce  |



**2. Add an identity column ```row_id, ``` to ```#customer_orders_temp``` to select each ordered pizza more easily**
```TSQL
ALTER TABLE #customer_orders_temp
ADD row_id,  INT IDENTITY(1,1);

SELECT * FROM #customer_orders_temp;
```
  
| order_id | customer_id | pizza_id | exclusions | extras | order_time              | record_id  |
|----------|-------------|----------|------------|--------|-------------------------|------------|
| 1        | 101         | 1        |            |        | 2020-01-01 18:05:02.000 | 1          |
| 2        | 101         | 1        |            |        | 2020-01-01 19:00:52.000 | 2          |
| 3        | 102         | 1        |            |        | 2020-01-02 23:51:23.000 | 3          |
| 3        | 102         | 2        |            |        | 2020-01-02 23:51:23.000 | 4          |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46.000 | 5          |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46.000 | 6          |
| 4        | 103         | 2        | 4          |        | 2020-01-04 13:23:46.000 | 7          |
| 5        | 104         | 1        |            | 1      | 2020-01-08 21:00:29.000 | 8          |
| 6        | 101         | 2        |            |        | 2020-01-08 21:03:13.000 | 9          |
| 7        | 105         | 2        |            | 1      | 2020-01-08 21:20:29.000 | 10         |
| 8        | 102         | 1        |            |        | 2020-01-09 23:54:33.000 | 11         |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10 11:22:59.000 | 12         |
| 10       | 104         | 1        |            |        | 2020-01-11 18:34:49.000 | 13         |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-01-11 18:34:49.000 | 14         |
  

**3. Create a new temporary table ```#extras_temp``` to separate ```#extra_id;``` into multiple rows**
```TSQL
DROP TABLE IF EXISTS #extras_temp;

SELECT 
  row_id, 
  TRIM(value) AS extra_id
INTO #extras_temp
FROM #customer_orders_temp co
  CROSS APPLY STRING_SPLIT(extras, ',');

SELECT * FROM #extras_temp;
```
  
| row_id    | extra_id  |
|-----------|-----------|
| 1         |           |
| 2         |           |
| 3         |           |
| 4         |           |
| 5         |           |
| 6         |           |
| 7         |           |
| 8         | 1         |
| 9         |           |
| 10        | 1         |
| 11        |           |
| 12        | 1         |
| 12        | 5         |
| 13        |           |
| 14        | 1         |
| 14        | 4         |

**4. Create a new temporary table ```#exclusions_temp;``` to separate into ```exclusion_id``` into multiple rows**
```TSQL
SELECT 
  row_id,
  TRIM(value) AS exclusion_id
INTO #exclusions_temp
FROM #customer_orders_temp co
  CROSS APPLY STRING_SPLIT(exclusions, ',');
  
SELECT * FROM #exclusions_temp;
```
  
| row_id    | exclusion_id  |
|-----------|---------------|
| 1         |               |
| 2         |               |
| 3         |               |
| 4         |               |
| 5         | 4             |
| 6         | 4             |
| 7         | 4             |
| 8         |               |
| 9         |               |
| 10        |               |
| 11        |               |
| 12        | 4             |
| 13        |               |
| 14        | 2             |
| 14        | 6             |

---
### 1. What are the standard ingredients for each pizza?
```TSQL
select pizza_name, S
TRING_AGG(topping_name, ' , ') as ingredients_name
from #pizza_topping_names
group by pizza_name;
```
  
| pizza_name | ingredients                                                            |
|------------|------------------------------------------------------------------------|
| Meatlovers | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami  |
| Vegetarian | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce             |

---
### 2. What was the most commonly added extra?
```TSQL
select topping_name , 
count(1) as extra_added
from #extras_temp
inner join pizza_runner.pizza_toppings on extra_id = topping_id
group by topping_name;
```
  
| topping_name | extra_added  |
|--------------|--------------|
| Bacon        | 4            |
| Cheese       | 1            |
| Chicken      | 1            |

The most commonly added extra was Bacon.

---
### 3. What was the most common exclusion?
```TSQL
select topping_name , 
count(1) as excluded
from #exclusions_temp
inner join pizza_runner.pizza_toppings on exclusion_id = topping_id
group by topping_name
order by times_excluded desc;
```
  
| topping_name | excluded         |
|--------------|------------------|
| Cheese       | 4                |
| Mushrooms    | 1                |
| BBQ Sauce    | 1                |

The most common exclusion was Cheese.

---
### 4.Generate an order item for each record in the ```customers_orders``` table in the format of one of the following
* ```Meat Lovers```
* ```Meat Lovers - Exclude Beef```
* ```Meat Lovers - Extra Bacon```
* ```Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers```

To solve this question:
* Create CTE: create comments_cte by doing a union between extras and exclusions.
* Use the ```comments_cte``` to LEFT JOIN with the ```customer_orders_temp``` and JOIN with the ```pizza_name```
* Use the ```CONCAT_WS``` with ```STRING_AGG``` to get the result

```TSQL
with comments_cte as 
(
select row_id,
'Extra ' + STRING_AGG(topping_name, ', ') comments
from #extras_temp
inner join  pizza_runner.pizza_toppings on topping_id = extra_id
group by row_id
union
select row_id,
'Exclude ' + STRING_AGG(topping_name, ', ') comments
from #exclusions_temp
inner join  pizza_runner.pizza_toppings on topping_id = exclusion_id
group by row_id
)
select co.row_id,order_id,customer_id, co.pizza_id, order_time, 
CONCAT_WS(' - ', pizza_name, STRING_AGG(comments, ' - ')) as pizza_details
from #customer_orders_temp co
inner join pizza_runner.pizza_names pn on co.pizza_id = pn.pizza_id
left join comments_cte cc on cc.row_id = co.row_id
group by co.row_id,order_id,customer_id, co.pizza_id, order_time,pizza_name;
```

**Result**
  
| record_id | order_id | customer_id | pizza_id | order_time              | pizza_details                                                      |
|-----------|----------|-------------|----------|-------------------------|-------------------------------------------------------------------|
| 1         | 1        | 101         | 1        | 2020-01-01 18:05:02.000 | Meatlovers                                                        |
| 2         | 2        | 101         | 1        | 2020-01-01 19:00:52.000 | Meatlovers                                                        |
| 3         | 3        | 102         | 1        | 2020-01-02 23:51:23.000 | Meatlovers                                                        |
| 4         | 3        | 102         | 2        | 2020-01-02 23:51:23.000 | Vegetarian                                                        |
| 5         | 4        | 103         | 1        | 2020-01-04 13:23:46.000 | Meatlovers - Exclusion Cheese                                     |
| 6         | 4        | 103         | 1        | 2020-01-04 13:23:46.000 | Meatlovers - Exclusion Cheese                                     |
| 7         | 4        | 103         | 2        | 2020-01-04 13:23:46.000 | Vegetarian - Exclusion Cheese                                     |
| 8         | 5        | 104         | 1        | 2020-01-08 21:00:29.000 | Meatlovers - Extra Bacon                                          |
| 9         | 6        | 101         | 2        | 2020-01-08 21:03:13.000 | Vegetarian                                                        |
| 10        | 7        | 105         | 2        | 2020-01-08 21:20:29.000 | Vegetarian - Extra Bacon                                          |
| 11        | 8        | 102         | 1        | 2020-01-09 23:54:33.000 | Meatlovers                                                        |
| 12        | 9        | 103         | 1        | 2020-01-10 11:22:59.000 | Meatlovers - Exclusion Cheese - Extra Bacon, Chicken              |
| 13        | 10       | 104         | 1        | 2020-01-11 18:34:49.000 | Meatlovers                                                        |
| 14        | 10       | 104         | 1        | 2020-01-11 18:34:49.000 | Meatlovers - Exclusion BBQ Sauce, Mushrooms - Extra Bacon, Cheese |

---
### 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the ```customer_orders``` table and add a 2x in front of any relevant ingredients.
* For example: ```"Meat Lovers: 2xBacon, Beef, ... , Salami"```

To solve this question:
* Create a CTE in which each line displays an ingredient for an ordered pizza (add '2x' for extras and remove exclusions as well)
* Use ```CONCAT``` and ```STRING_AGG``` to get the result

```TSQL
with ingredients as (
select co.*, pt.pizza_name,
case when pt.topping_id in (select extra_id from #extras_temp et where et.row_id = co.row_id)
	then '2x ' + pt.topping_name
	else pt.topping_name end as toppings
from #customer_orders_temp co
inner join #pizza_topping_names pt on pt.pizza_id = co.pizza_id
where  pt.topping_id not in (select exclusion_id from #exclusions_temp e where e.row_id = co.row_id)
)
select row_id, order_id, customer_id, pizza_id, order_time,
CONCAT(pizza_name + ': ' , STRING_AGG(toppings, ', ')) as ingredients_list
from ingredients
group by row_id, order_id, customer_id, pizza_id, order_time, pizza_name;
```
  
| row_id    | order_id | customer_id | pizza_id | order_time              | ingredients_list                                                                     |
|-----------|----------|-------------|----------|-------------------------|--------------------------------------------------------------------------------------|
| 1         | 1        | 101         | 1        | 2020-01-01 18:05:02.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami, Cheese    |
| 2         | 2        | 101         | 1        | 2020-01-01 19:00:52.000 | Meatlovers: Cheese, Salami, Pepperoni, Mushrooms, Chicken, Beef, BBQ Sauce, Bacon    |
| 3         | 3        | 102         | 1        | 2020-01-02 23:51:23.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami, Cheese    |
| 4         | 3        | 102         | 2        | 2020-01-02 23:51:23.000 | Vegetarian: Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce, Cheese               |
| 5         | 4        | 103         | 1        | 2020-01-04 13:23:46.000 | Meatlovers: Salami, Pepperoni, Mushrooms, Chicken, Beef, BBQ Sauce, Bacon            |
| 6         | 4        | 103         | 1        | 2020-01-04 13:23:46.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami            |
| 7         | 4        | 103         | 2        | 2020-01-04 13:23:46.000 | Vegetarian: Mushrooms, Tomato Sauce, Tomatoes, Peppers, Onions                       |
| 8         | 5        | 104         | 1        | 2020-01-08 21:00:29.000 | Meatlovers: Cheese, Salami, Pepperoni, Mushrooms, Chicken, Beef, BBQ Sauce, 2xBacon  |
| 9         | 6        | 101         | 2        | 2020-01-08 21:03:13.000 | Vegetarian: Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce, Cheese               |
| 10        | 7        | 105         | 2        | 2020-01-08 21:20:29.000 | Vegetarian: Cheese, Tomato Sauce, Tomatoes, Peppers, Onions, Mushrooms               |
| 11        | 8        | 102         | 1        | 2020-01-09 23:54:33.000 | Meatlovers: Cheese, Salami, Mushrooms, Pepperoni, Bacon, BBQ Sauce, Beef, Chicken    |
| 12        | 9        | 103         | 1        | 2020-01-10 11:22:59.000 | Meatlovers: 2xChicken, Beef, BBQ Sauce, 2xBacon, Pepperoni, Mushrooms, Salami        |
| 13        | 10       | 104         | 1        | 2020-01-11 18:34:49.000 | Meatlovers: Salami, Cheese, Mushrooms, Pepperoni, Bacon, BBQ Sauce, Beef, Chicken    |
| 14        | 10       | 104         | 1        | 2020-01-11 18:34:49.000 | Meatlovers: Chicken, Beef, 2xBacon, Pepperoni, 2xCheese, Salami                      |

---
### 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
To solve this question:
* Create a CTE to record the number of times each ingredient was used
  * if extra ingredient, add 2 
  * if excluded ingredient, add 0
  * no extras or no exclusions, add 1
  * add a filter cancellation is NULL to filter delivered pizzas
```TSQL
with mostusedingredients as (
select co.row_id, pt.topping_name,
case 
when pt.topping_id in (select extra_id from #extras_temp et where et.row_id = co.row_id) then 2
when pt.topping_id in (select exclusion_id from #exclusions_temp e where e.row_id = co.row_id) then 0
else 1 end as times_used
from #customer_orders_temp co
inner join #pizza_topping_names pt on co.pizza_id = pt.pizza_id
inner join pizza_runner.runner_orders ro on co.order_id = ro.order_id
where cancellation is NULL)
select topping_name, sum(times_used) as times_used
from mostusedingredients 
group by topping_name
order by times_used desc;
```
  
| topping_name | times_used  |
|--------------|-------------|
| Mushrooms    | 6           |
| Bacon        | 5           |
| BBQ Sauce    | 4           |
| Beef         | 4           |
| Pepperoni    | 4           |
| Salami       | 4           |
| Chicken      | 4           |
| Peppers      | 4           |
| Cheese       | 3           |
| Peppers      | 2           |
| Onions       | 2           |
| Tomato Sauce | 2           |
| Tomatoes     | 2           |
  
---
My solution for **[D. Pricing and Ratings](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/Solution/D.%20Pricing%20and%20Ratings.md)**.
