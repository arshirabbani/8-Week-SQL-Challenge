---------------------------------
--A. Customer Nodes Exploration--
---------------------------------

--1. How many unique nodes are there on the Data Bank system?

select count (distinct node_id) as nodes_cnt from data_bank.customer_nodes;


--2. What is the number of nodes per region?

select cn.region_id,region_name,  count ( node_id) as nodes
from data_bank.customer_nodes cn
inner join data_bank.regions r on cn.region_id = r.region_id
group by cn.region_id,region_name
order by cn.region_id;


--3. How many customers are allocated to each region?

select cn.region_id,region_name,  count (distinct customer_id) as no_of_cust
from data_bank.customer_nodes cn
inner join data_bank.regions r on cn.region_id = r.region_id
group by cn.region_id,region_name
order by cn.region_id;


--4. How many days on average are customers reallocated to a different node?

select  avg(DATEDIFF(day, start_date, end_date)) as avg_days
from data_bank.customer_nodes cn where  end_date != '9999-12-31';


--5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

with r_days as (
select c.region_id,r.region_name, datediff(day,start_date, end_date) AS reallocation_days
from data_bank.customer_nodes AS c
inner join data_bank.regions AS r on c.region_id = r.region_id 
where end_date != '9999-12-31')
select distinct region_id, region_name,
PERCENTILE_CONT(0.5) within group (order by reallocation_days) over (partition by region_name) as median,
PERCENTILE_CONT(0.8) within group (order by reallocation_days) over (partition by region_name) as perc_80,
PERCENTILE_CONT(0.95) within group (order by reallocation_days) over (partition by region_name) as perc_95
from r_days;