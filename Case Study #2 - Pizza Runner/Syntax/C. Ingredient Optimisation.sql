-------------------------------
--Author: Arshi Rabbani
--Date: 25/08/2024
--Tool used: SQL Server

---1. What are the standard ingredients for each pizza?

select pizza_name, S
TRING_AGG(topping_name, ' , ') as ingredients_name
from #pizza_topping_names
group by pizza_name;

---2. What was the most commonly added extra?

select topping_name , 
count(1) as extra_added
from #extras_temp
inner join pizza_runner.pizza_toppings on extra_id = topping_id
group by topping_name;

---3. --What was the most common exclusion?

select topping_name , 
count(1) as excluded
from #exclusions_temp
inner join pizza_runner.pizza_toppings on exclusion_id = topping_id
group by topping_name
order by times_excluded desc;

----4. /* Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
*/


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


---5. /*
Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami" */

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

---6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first? 

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