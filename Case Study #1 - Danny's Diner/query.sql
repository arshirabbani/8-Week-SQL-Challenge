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
where rn = 1
group by customer_id, product_name;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select top 1
  product_name, 
  count(1) as purchase_count 
from 
  dannys_diner.sales s
  inner join dannys_diner.menu m 
  on s.product_id = m.product_id
group by 
  product_name 
order by 
  purchase_count desc ;

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
    dannys_diner.sales s
    inner join dannys_diner.menu m 
	on s.product_id = m.product_id
  group by 
    customer_id, 
    product_name 
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
    s.customer_id, 
    product_name, 
    order_date, 
	join_date,
    dense_rank() over( partition by s.customer_id order by order_date asc) as rn 
  from 
    dannys_diner.sales s
    inner join dannys_diner.menu m on s.product_id = m.product_id
    inner join dannys_diner.members u on s.customer_id = u.customer_id
  where 
    order_date >= join_date
) 
select 
  customer_id, 
  product_name ,
  order_date, 
  join_date
from member 
where  rn = 1;


-- 7. Which item was purchased just before the customer became a member?

with member as (
  select 
    s.customer_id, 
    product_name, 
    order_date, 
	join_date,
    dense_rank() over(partition by s.customer_id order by order_date desc) as rn 
  from 
    dannys_diner.sales s
    inner join dannys_diner.menu m on s.product_id = m.product_id
    inner join dannys_diner.members u on s.customer_id = u.customer_id
  where 
    order_date < join_date
) 
select 
  customer_id, 
  product_name ,
  order_date, 
  join_date
from member 
where  rn = 1;


-- 8. What is the total items and amount spent for each member before they became a member?

select 
  s.customer_id, 
  count(s.product_id) as item_count, 
  sum(price) as total_spend
from 
    dannys_diner.sales s
    inner join dannys_diner.menu m on s.product_id = m.product_id
    inner join dannys_diner.members u on s.customer_id = u.customer_id
where order_date < join_date 
group by  s.customer_id 
order by  s.customer_id;



-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- Note: Only customers who are members receive points when purchasing items

select 
  s.customer_id, 
  sum(
    case when product_name = 'sushi' then 20 * price else 10 * price end) as total_points 
from 
    dannys_diner.sales s
    inner join dannys_diner.menu m on s.product_id = m.product_id
group by s.customer_id 
order by s.customer_id;



-- 10. In the first week after a customer joins the program (including their join date), they earn 2x points
-- on all items, not just sushi - how many points do customer A and B have at the end of January?

with cte as (
  select 
   customer_id, 
   join_date,
    EOMONTH('2021-01-01') AS last_date,     
    DATEADD(d, 6, join_date) AS valid_date
   from  dannys_diner.members
   ) 
select 
  c.customer_id,
  SUM(CASE 	WHEN s.order_date BETWEEN c.join_date AND c.valid_date THEN m.price*20
			WHEN m.product_name = 'sushi' THEN m.price*20
			ELSE m.price*10 END) AS total_points
FROM dannys_diner.sales s
JOIN cte c
  ON s.customer_id = c.customer_id
JOIN dannys_diner.menu m 
  ON s.product_id = m.product_id
WHERE s.order_date <= last_date
GROUP BY c.customer_id;




------------------------
--   BONUS QUESTIONS  --
------------------------

-- Join All The Things

select 
  s.customer_id, 
  order_date, 
  product_name, 
  price, 
  case when order_date >= join_date then 'Y' Else 'N' end as member 
from 
    dannys_diner.sales s
    inner join dannys_diner.menu m on s.product_id = m.product_id
    left join dannys_diner.members u on s.customer_id = u.customer_id
order by 
  s.customer_id, order_date;



-- Rank All The Things
-- Note: Create a CTE using the result in the previous question


with cte as (
  select 
    s.customer_id, 
    order_date, 
    product_name, 
    price, 
    case when order_date >= join_date then 'Y' Else 'N' end as member 
  from 
    dannys_diner.sales s
    inner join dannys_diner.menu m on s.product_id = m.product_id
    left join dannys_diner.members u on s.customer_id = u.customer_id
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
