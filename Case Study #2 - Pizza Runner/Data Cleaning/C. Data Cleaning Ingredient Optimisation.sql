---------------------------------------------
--C. Data Cleaning: Ingredient Optimisation--
---------------------------------------------

-- 1. split toppings and created a new table including pizza and toppings name.

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


-- 2. Add a new column row_id, to select each ordered pizza more easily

ALTER TABLE #customer_orders_temp
ADD row_id INT IDENTITY(1,1);

SELECT * FROM #customer_orders_temp;


-- 3. Create a new temporary table to separate [extras] into multiple rows: #extras_temp

DROP TABLE IF EXISTS #extras_temp;

SELECT 
  row_id, 
  TRIM(value) AS extra_id
INTO #extras_temp
FROM #customer_orders_temp co
  CROSS APPLY STRING_SPLIT(extras, ',');

SELECT * FROM #extras_temp;

-- 4. Create a new temporary table to separate [exclusions] into multiple rows: #exclusions_temp

DROP TABLE IF EXISTS #exclusions_temp;
 
SELECT 
  row_id,
  TRIM(value) AS exclusion_id
INTO #exclusions_temp
FROM #customer_orders_temp co
  CROSS APPLY STRING_SPLIT(exclusions, ',');
  
SELECT * FROM #exclusions_temp;
