-----------------------
--C. Product Analysis--
-----------------------

--1. What are the top 3 products by total revenue before discount?

select top 3 product_name, sum(qty*s.price) as total_revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by product_name order by total_revenue desc;


--2. What is the total quantity, revenue and discount for each segment?

select segment_name, 
sum(qty) as total_qty,
sum(qty*s.price) as total_revenue,
cast (sum(qty*s.price*discount/100.0) as decimal(10,2)) as total_discount
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by segment_name; 


--3. What is the top selling product for each segment?

with top_selling_prod as (
select segment_name, product_name, sum(qty) as total_qty,
dense_rank() over(partition by segment_name order by sum(qty) desc) as rn
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by  segment_name, product_name )
select segment_name, product_name,total_qty
from top_selling_prod where rn =1 ;


--4. What is the total quantity, revenue and discount for each category?

select category_name, 
sum(qty) as total_qty,
sum(qty*s.price) as total_revenue,
cast (sum(s.qty*s.price*s.discount/100.0) as decimal(10,2)) as total_discount
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by category_name ;

--5. What is the top selling product for each category?

with top_selling_prod as (
select category_name, product_name, sum(qty) as total_qty,
dense_rank() over(partition by category_name order by sum(qty) desc) as rn
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by  category_name, product_name )
select category_name, product_name,total_qty
from top_selling_prod where rn =1 ;


--6. What is the percentage split of revenue by product for each segment?

with prod_revenue as (
select segment_name, product_name, sum(qty*s.price) as prod_revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by  segment_name, product_name )
select segment_name, product_name,
cast(100.0* prod_revenue/sum(prod_revenue)over(partition by segment_name) as decimal(10,2)) segment_prod_pct
from prod_revenue; 

--7. What is the percentage split of revenue by segment for each category?

with segment_revenue as (
select category_name, segment_name, sum(qty*s.price) as segment_revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by  category_name, segment_name )
select category_name, segment_name,
cast(100.0* segment_revenue/sum(segment_revenue)over(partition by category_name) as decimal(10,2)) category_segment_pct
from segment_revenue; 


--8. What is the percentage split of total revenue by category?

with total_revenue as (
select category_name,  sum(qty*s.price) as total_revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by  category_name )
select category_name,
cast(100.0* total_revenue/sum(total_revenue)over() as decimal(10,2)) category_revenue_pct
from total_revenue; 


--9. What is the total transaction “penetration” for each product? 
--(hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

with txn_details as (
select product_name, count(distinct txn_id) as product_txn,
(select count(distinct txn_id) from balanced_tree.sales) as total_txn
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by  product_name )
select *, 
cast(100.0* product_txn/total_txn as decimal(10,2)) total_txn_penetration
from txn_details; 


--10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?


--count the number of products in each transaction
with products_per_transaction as (
  select  s.txn_id,  pd.product_id,  pd.product_name,  s.qty,  count(pd.product_id) over (partition by txn_id) as cnt
  from balanced_tree.sales s
  join balanced_tree.product_details pd  on s.prod_id = pd.product_id ),

--filter transactions that have the 3 products and group them to a cell
combinations as (
  select    string_agg(product_id, ', ') as products_id,
    string_agg(product_name, ', ') as products_name
  from products_per_transaction
  where cnt = 3  group by txn_id ),

--count the number of times each combination appears
combination_count as (
  select   products_id,   products_name,  count (*) as common_combinations
  from combinations
  group by products_id, products_name )

--filter the most common combinations
select    products_id,   products_name
from combination_count
where common_combinations = (select max(common_combinations)   from combination_count);
