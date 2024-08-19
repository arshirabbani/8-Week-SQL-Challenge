------------------------
--CASE STUDY QUESTIONS--
------------------------

--Author: Arshi Rabbani
--Date: 18/08/2024
--Tool used: SQL Server


-- 1. What is the total amount each customer spent at the restaurant?

select 
  customer_id, 
  sum(price) as amount_paid 
from 
  dannys_diner.sales s 
  inner join dannys_diner.menu m on m.product_id = s.product_id 
group by 
  customer_id;



-- 2. How many days has each customer visited the restaurant?

select 
  customer_id, 
  count (distinct order_date) as days_count 
from 
  dannys_diner.sales 
group by 
  customer_id;


-- 3. What was the first item from the menu purchased by each customer?

with ordered_sales as (
  select 
    customer_id, 
    order_date, 
    product_name, 
    dense_rank() over(
      partition by customer_id 
      order by 
        order_date asc
    ) as rn 
  from 
    dannys_diner.sales s 
    inner join dannys_diner.menu m on s.product_id = m.product_id
) 
select 
  customer_id, 
  product_name 
from ordered_sales 
where rn = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select 
  product_name, 
  count(1) as purchase_count 
from 
  dannys_diner.sales 
  inner join dannys_diner.menu using (product_id) 
group by 
  product_name 
order by 
  purchased_count desc 
limit 1;


-- 5. Which item was the most popular for each customer?

with fav_prod as(
  select 
    customer_id, 
    product_name, 
    count(1) as purchased_count, 
    dense_rank() over(
      partition by customer_id 
      order by 
        count(1) desc
    ) as rn 
  from 
    dannys_diner.sales 
    inner join dannys_diner.menu using (product_id) 
  group by 
    customer_id, 
    product_name 
  order by 
    customer_id, 
    purchased_count desc
) 
select 
  customer_id, 
  product_name, 
  purchased_count 
from  fav_prod 
where  rn = 1;


-- 6. Which item was purchased first by the customer after they became a member?

with member as (
  select 
    customer_id, 
    product_name, 
    order_date, 
    dense_rank() over(
      partition by customer_id 
      order by 
        order_date asc
    ) as rn 
  from 
    dannys_diner.sales 
    inner join dannys_diner.menu using (product_id) 
    inner join dannys_diner.members using (customer_id) 
  where 
    order_date >= join_date
) 
select 
  customer_id, 
  product_name 
from member 
where  rn = 1;


-- 7. Which item was purchased just before the customer became a member?

with before_member as (
  select 
    customer_id, 
    product_name, 
    order_date, 
    dense_rank() over(
      partition by customer_id 
      order by 
        order_date desc
    ) as rn 
  from 
    dannys_diner.sales 
    inner join dannys_diner.menu using (product_id) 
    inner join dannys_diner.members using (customer_id) 
  where 
    order_date < join_date
) 
select 
  customer_id, 
  product_name 
from  before_member 
where  rn = 1;



-- 8. What is the total items and amount spent for each member before they became a member?

select 
  customer_id, 
  count(product_id) as item_count, 
  sum(price) 
from 
  dannys_diner.sales 
  inner join dannys_diner.menu using (product_id) 
  inner join dannys_diner.members using (customer_id) 
where order_date < join_date 
group by  customer_id 
order by  customer_id;



-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- Note: Only customers who are members receive points when purchasing items

select 
  customer_id, 
  sum(
    case when product_name = 'sushi' then 20 * price else 10 * price end
  ) as total_points 
from 
  dannys_diner.sales 
  inner join dannys_diner.menu using (product_id) 
group by customer_id 
order by customer_id;



-- 10. In the first week after a customer joins the program (including their join date), they earn 2x points
-- on all items, not just sushi - how many points do customer A and B have at the end of January?

with cte as (
  select 
    customer_id, 
    (
      DATE_TRUNC('month', join_date) + INTERVAL '1 month - 1 day'
    ) as EOM, 
    order_date, 
    join_date, 
    join_date + 7, 
    product_name, 
    price, 
    (
      case when product_name = 'sushi' then 20 * price when order_date between join_date 
      and join_date + 6 then 20 * price else 10 * price end
    ) as points 
  from 
    dannys_diner.sales 
    inner join dannys_diner.menu using (product_id) 
    inner join dannys_diner.members using (customer_id)
) 
select 
  customer_id, sum(points) 
from cte 
where  order_date <= eom 
group by  customer_id 
order by  customer_id;



------------------------
--   BONUS QUESTIONS  --
------------------------

-- Join All The Things

select 
  customer_id, 
  order_date, 
  product_name, 
  price, 
  case when order_date >= join_date then 'Y' Else 'N' end as member 
from 
  dannys_diner.sales 
  left join dannys_diner.menu using (product_id) 
  left join dannys_diner.members using (customer_id) 
order by 
  customer_id, order_date;



-- Rank All The Things
-- Note: Create a CTE using the result in the previous question

with cte as (
  select 
    customer_id, 
    order_date, 
    product_name, 
    price, 
    case when order_date >= join_date then 'Y' Else 'N' end as member 
  from 
    dannys_diner.sales 
    left join dannys_diner.menu using (product_id) 
    left join dannys_diner.members using (customer_id)
) 
select 
  *, 
  case when member = 'Y' then rank() over(
    partition by customer_id, 
    member 
    order by 
      order_date
  ) else null end as ranking 
from cte;
