---------------------------
--B. Transaction Analysis--
---------------------------

--1. How many unique transactions were there?

select count(distinct(txn_id)) as unique_txn from balanced_tree.sales;


--2.What is the average unique products purchased in each transaction?

with unique_prod_cnt as (
select txn_id, count(distinct prod_id) as unique_prod_cnt 
from balanced_tree.sales
group by txn_id)
select avg(unique_prod_cnt) as avg_unique_prod_cnt from unique_prod_cnt;


--3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

with revenue as (
select txn_id, sum(qty*price) as revenue from balanced_tree.sales
group by txn_id)
select distinct 
PERCENTILE_CONT(0.25) within group (order by revenue) over() as revenue_25th,
PERCENTILE_CONT(0.50) within group (order by revenue) over() as revenue_50th,
PERCENTILE_CONT(0.75) within group (order by revenue) over() as revenue_75th
from revenue;


--4. What is the average discount value per transaction?

with discounted_txn as (
select txn_id, sum(qty*price*discount/100.0) as discounted_txn from balanced_tree.sales
group by txn_id)
select cast(avg(discounted_txn) as decimal(10,2)) as avg_discounted_txn
from discounted_txn;


--5. What is the percentage split of all transactions for members vs non-members?

select 
cast (100.0* count(distinct case when member = 1 then txn_id end)/ count(distinct txn_id) as float) as member_pct,
cast(100.0* count(distinct case when member = 0 then txn_id end)/ count(distinct txn_id) as float) as non_member_pct
from balanced_tree.sales;


--6. What is the average revenue for member transactions and non-member transactions?

with total_revenue as (
select (case when member = 1 then 'member' else 'non-member' end) as member,
txn_id, sum(qty*price) as total_revenue
from balanced_tree.sales 
group by member, txn_id)
select member , cast(avg(1.0*total_revenue) as decimal(10,2)) as avg_revenue
from total_revenue
group by member;
