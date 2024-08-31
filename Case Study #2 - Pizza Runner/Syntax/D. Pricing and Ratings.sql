-------------------------------
--Author: Arshi Rabbani
--Date: 25/08/2024
--Tool used: SQL Server

---1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

select sum(case when pizza_id = 1 then 12 when pizza_id = 2 then 10 end ) as money_earned
from #customer_orders_temp co
inner join #runner_orders_temp ro on co.order_id = ro.order_id
where cancellation is  null;

---2. What if there was an additional $1 charge for any pizza extras?

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


---3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

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

---4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?

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


---5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

DECLARE @money_earned INT
SET @money_earned = 138 -- (result of first query)

select @money_earned as revenue,
sum(distance * 0.3) as paid_to_runner,
 @money_earned - sum(distance * 0.3) as money_left
from #runner_orders_temp;