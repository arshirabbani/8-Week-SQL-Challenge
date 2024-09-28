# 🐟 Case Study #6 - Clique Bait
## B. Product Funnel Analysis
Using a single SQL query - create a new output table which has the following details:
  * How many times was each product viewed?
  * How many times was each product added to cart?
  * How many times was each product added to a cart but not purchased (abandoned)?
  * How many times was each product purchased?

### Solution

The output table will look like:

| Columns          | Description                                                               |
|------------------|---------------------------------------------------------------------------|
| product_id       | Id of each product                                                        |
| product_name     | Name of each product                                                      |
| product_category | Category of each product                                                  |
| views            | Number of times each product viewed                                       |
| cart_adds        | Number of times each product added to cart                                |
| abondoned        | Number of times each product added to cart but not purchased (abandoned)  |
| purchases        | Number of times each product purchased                                    |

* Create a CTE `product_info`: calculate the number of `views` and number of `cart_adds` for each product using `CASE` and `SUM`
* Create a CTE `product_abandoned`: calculate the number of abandoned products (replace `IN` by `NOT IN` in the solution for Question 9 in part A). 
* Create a CTE `product_purchased`: calculate the number of purchased products (solution for Question 9 in part A)
* `JOIN` 3 CTEs using `product_id`, `product_name` and `product_category` of each product
* Store the result in a temporary table `product_summary` for further analysis

```TSQL
with product as (
select product_id, page_name as product_name, product_category,
sum(case when event_name = 'Page View' then 1 else 0 end) as viewed,
sum(case when event_name = 'Add to Cart' then 1 else 0 end) as cart_added
from clique_bait.event e
inner join clique_bait.event_identifier ei on e.event_type = ei.event_type
inner join clique_bait.page_hierarchy ph on  e.page_id = ph.page_id
where product_id is not null
group by product_id, page_name , product_category)
,purchased as (
select product_id, page_name as product_name, product_category,
count(1) as purchased
from clique_bait.event e
inner join clique_bait.event_identifier ei on e.event_type = ei.event_type
inner join clique_bait.page_hierarchy ph on  e.page_id = ph.page_id
where event_name = 'Add to Cart'
and visit_id  in (
select  visit_id from clique_bait.event e1 inner join clique_bait.event_identifier ei on e1.event_type = ei.event_type
where event_name = 'Purchase')
group by product_id, page_name , product_category)
,abandoned as (
select product_id, page_name as product_name, product_category,
count(1) as abandoned
from clique_bait.event e
inner join clique_bait.event_identifier ei on e.event_type = ei.event_type
inner join clique_bait.page_hierarchy ph on  e.page_id = ph.page_id
where event_name = 'Add to Cart'
and visit_id not in (
select  visit_id from clique_bait.event e1 inner join clique_bait.event_identifier ei on e1.event_type = ei.event_type
where event_name = 'Purchase')
group by product_id, page_name , product_category)

select p1.* , abandoned, purchased
into #product_summary
from product p1
inner join purchased p2 on p1.product_id = p2.product_id
inner join abandoned a on p1.product_id = a.product_id

select * from #product_summary;
```
| product_id | product_name   | product_category | views | cart_adds | abandoned | purchases  |
|------------|----------------|------------------|-------|-----------|-----------|------------|
| 1          | Salmon         | Fish             | 1559  | 938       | 227       | 711        |
| 2          | Kingfish       | Fish             | 1559  | 920       | 213       | 707        |
| 3          | Tuna           | Fish             | 1515  | 931       | 234       | 697        |
| 4          | Russian Caviar | Luxury           | 1563  | 946       | 249       | 697        |
| 5          | Black Truffle  | Luxury           | 1469  | 924       | 217       | 707        |
| 6          | Abalone        | Shellfish        | 1525  | 932       | 233       | 699        |
| 7          | Lobster        | Shellfish        | 1547  | 968       | 214       | 754        |
| 8          | Crab           | Shellfish        | 1564  | 949       | 230       | 719        |
| 9          | Oyster         | Shellfish        | 1568  | 943       | 217       | 726        |

---
Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

### Solution
Simply remove `product_id` and `product_name` in each CTE table above.

```TSQL
with product as (
select  product_category,
sum(case when event_name = 'Page View' then 1 else 0 end) as viewed,
sum(case when event_name = 'Add to Cart' then 1 else 0 end) as cart_added
from clique_bait.event e
inner join clique_bait.event_identifier ei on e.event_type = ei.event_type
inner join clique_bait.page_hierarchy ph on  e.page_id = ph.page_id
where product_id is not null
group by product_category)
,purchased as (
select  product_category,
count(1) as purchased
from clique_bait.event e
inner join clique_bait.event_identifier ei on e.event_type = ei.event_type
inner join clique_bait.page_hierarchy ph on  e.page_id = ph.page_id
where event_name = 'Add to Cart'
and visit_id  in (
select  visit_id from clique_bait.event e1 inner join clique_bait.event_identifier ei on e1.event_type = ei.event_type
where event_name = 'Purchase')
group by  product_category)
,abandoned as (
select  product_category,
count(1) as abandoned
from clique_bait.event e
inner join clique_bait.event_identifier ei on e.event_type = ei.event_type
inner join clique_bait.page_hierarchy ph on  e.page_id = ph.page_id
where event_name = 'Add to Cart'
and visit_id not in (
select  visit_id from clique_bait.event e1 inner join clique_bait.event_identifier ei on e1.event_type = ei.event_type
where event_name = 'Purchase')
group by  product_category)

select p1.* , abandoned, purchased
into #product_category_summary
from product p1
inner join purchased p2 on p1.product_category = p2.product_category
inner join abandoned a on p1.product_category = a.product_category


select * from #product_category_summary;
```
| product_category | views | cart_adds | abandoned | purchases  |
|------------------|-------|-----------|-----------|------------|
| Fish             | 4633  | 2789      | 674       | 2115       |
| Luxury           | 3032  | 1870      | 466       | 1404       |
| Shellfish        | 6204  | 3792      | 894       | 2898       |

---
Use 2 new output tables - answer the following questions:

#### 1. Which product had the most views, cart adds and purchases?
```TSQL
select top 1 product_name as most_viewed
from #product_summary
order by viewed desc;
```

| most_viewed  |
|--------------|
|Oyster        |

```TSQL
select top 1 product_name as most_cart_added
from #product_summary
order by cart_added desc;
```
| most_cart_added  |
|------------------|
|Lobster           |

```TSQL
select top 1 product_name as most_purchased
from #product_summary
order by purchased desc;
```
| most_purchased   |
|------------------|
|Lobster           |


#### 2. Which product was most likely to be abandoned?
```TSQL
select top 1 product_name as can_be_abandoned
from #product_summary
order by abandoned desc;
```
| can_be_abandoned |
|------------------|
|Russian Caviar    |

#### 3. Which product had the highest view to purchase percentage?
```TSQL
select top 1 product_name ,
cast (100.0 *  purchased / viewed as decimal(10,2)) as view_purchase_cnt
from #product_summary
order by view_purchase_cnt desc;
```
| product_name | view_purchase_cnt |
|--------------|-------------------|
| Lobster      | 48.74             |



#### 4. What is the average conversion rate from view to cart add?
```TSQL
select
cast (avg(100.0 *  cart_added / viewed) as decimal(10,2)) as view_cart_add
from #product_summary;
```
| view_cart_add     |
|-------------------|
| 60.95             |

#### 5. What is the average conversion rate from cart add to purchase?
```TSQL
select
cast (avg(100.0 *  purchased / cart_added) as decimal(10,2)) as avg_cart_to_purchase
from #product_summary;
```
| avg_cart_to_purchase  |
|-----------------------|
 75.93                  |

---
My solution for **[C. Campaigns Analysis](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution/C.%20Campaigns%20Analysis.md)**.
