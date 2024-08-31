# 🍜 Case Study #1 - Danny's Diner
<p align="center">
<img src="https://github.com/arshirabbani/8-Weeks-SQL-Challenge/blob/main/IMG/1.png" align="center" width="400" height="400" >
  
## 📕 Table of Contents
* [Bussiness Task](https://github.com/arshirabbani/8-Weeks-SQL-Challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner#%EF%B8%8F-bussiness-task)
* [Entity Relationship Diagram](https://github.com/arshirabbani/8-Weeks-SQL-Challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner#-entity-relationship-diagram)
* [Case Study Questions](https://github.com/arshirabbani/8-Weeks-SQL-Challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner#-case-study-questions)
* [Bonus Questions](https://github.com/arshirabbani/8-Weeks-SQL-Challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner#%EF%B8%8F-bonus-questions)  
* [My Solution](https://github.com/arshirabbani/8-Weeks-SQL-Challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner#-my-solution)

---
## 🛠️ Bussiness Task
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

---
## 🔐 Entity Relationship Diagram
<p align="center">
<img src="https://github.com/arshirabbani/8-Weeks-SQL-Challenge/blob/main/IMG/e1.PNG" align="center" width="500" height="250" >

---
## ❓ Case Study Questions
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
  not just sushi - how many points do customer A and B have at the end of January?

---
## 🗒️ Bonus Questions
* Join All The Things - Create a table that has these columns: customer_id, order_date, product_name, price, member (Y/N).
* Rank All The Things - Based on the table above, add one column: ranking.  

---
## 🚀 My Solution
*View the complete syntax [HERE](https://github.com/arshirabbani/8-Weeks-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/query.sql).*
  
### Q1. What is the total amount each customer spent at the restaurant?
```TSQL
select 
  customer_id, 
  sum(price) as amount_paid 
from 
  dannys_diner.sales s 
  inner join dannys_diner.menu m on m.product_id = s.product_id 
group by 
  customer_id;
```
|  customer_id | amount_paid  |
|---|---|
|A	|76|
|B	|74|
|C	|36|

  
---
### Q2. How many days has each customer visited the restaurant?
```TSQL
select 
  customer_id, 
  count (distinct order_date) as days_count 
from  dannys_diner.sales 
group by  customer_id;
```
|  customer_id | days_count  |
|---|---|
|A	|4|
|B	|6|
|C	|2|

  
---
### Q3. What was the first item from the menu purchased by each customer?
```TSQL

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
```
| customer_id |product_name |
|---|-------|
| A |curry |
| A |sushi |
| B |curry |
| C |ramen |
  
  
---
### Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?
```SQL
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

```
| product_name | purchase_count |
|--------------|------------|
|ramen        | 8          |
  
  
---
### Q5. Which item was the most popular for each customer?
```TSQL
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
```
| customer_id | product_name | purchased_count |
|-------------|--------------|------------|
| A           | ramen        | 3          |
| B           | sushi        | 2          |
| B           | curry        | 2          |
| B           | ramen        | 2          |
| C           | ramen        | 3          |
  
  
---
### Q6. Which item was purchased first by the customer after they became a member?
```TSQL


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

```
| customer_id | product_name | order_date | join_date  |
|-------------|--------------|------------|------------|
| A           | curry        | 2021-01-07 | 2021-01-07 |
| B           | sushi        | 2021-01-11 | 2021-01-09 |


---
### Q7. Which item was purchased just before the customer became a member?
```TSQL

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
```  
| customer_id | product_name | order_date | join_date  |
|-------------|--------------|------------|------------|
| A           | sushi        | 2021-01-01 | 2021-01-07 |
| A           | curry        | 2021-01-01 | 2021-01-07 |
| B           | sushi        | 2021-01-04 | 2021-01-09 |

                                  
---
### Q8. What is the total items and amount spent for each member before they became a member?
```TSQL
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
```
| customer_id | item_count | total_spend |
|-------------|-------------|-------------|
| A           | 2           | 25          |
| B           | 3           | 40          |

  
---
### Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
Note: Only customers who are members receive points when purchasing items
```TSQL
select 
  s.customer_id, 
  sum(
    case when product_name = 'sushi' then 20 * price else 10 * price end) as total_points 
from 
    dannys_diner.sales s
    inner join dannys_diner.menu m on s.product_id = m.product_id
group by s.customer_id 
order by s.customer_id;
```
| customer_id | total_points |
|-------------|--------------|
| A           | 860          |
| B           | 940          |
| C           | 360            |
  
--- 
### Q10. In the first week after a customer joins the program (including their join date), they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```TSQL
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

```
| customer_id | total_points |
|-------------|--------------|
| A           | 1370         |
| B           | 820          |          
                              
---
### Join All The Things 
```TSQL
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
```
| customer_id | order_date | product_name | price | member |
|-------------|------------|--------------|-------|--------|
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

---
### Rank All The Things

```TSQL
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

```
| customer_id | order_date | product_name | price | member | ranking |
|-------------|------------|--------------|-------|--------|---------|
| A           | 2021-01-01 | sushi        | 10    | N      | NULL    |
| A           | 2021-01-01 | curry        | 15    | N      | NULL    |
| A           | 2021-01-07 | curry        | 15    | Y      | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01 | curry        | 15    | N      | NULL    |
| B           | 2021-01-02 | curry        | 15    | N      | NULL    |
| B           | 2021-01-04 | sushi        | 10    | N      | NULL    |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01 | ramen        | 12    | N      | NULL    |
| C           | 2021-01-01 | ramen        | 12    | N      | NULL    |
| C           | 2021-01-07 | ramen        | 12    | N      | NULL    |

## 🚀 My Solution

* View the complete syntax [HERE](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/query.sql).
