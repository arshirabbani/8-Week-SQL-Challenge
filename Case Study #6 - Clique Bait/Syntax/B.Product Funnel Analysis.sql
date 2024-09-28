------------------------------
--B. Product Funnel Analysis--
------------------------------

/*
Using a single SQL query - create a new output table which has the following details:
- How many times was each product viewed?
- How many times was each product added to cart?
- How many times was each product added to a cart but not purchased (abandoned)?
- How many times was each product purchased?
*/

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


/*
Additionally, create another table which further aggregates the data for the above points 
but this time for each product category instead of individual products.
*/

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


--Use your 2 new output tables - answer the following questions:
--1. Which product had the most views, cart adds and purchases?

select top 1 product_name as most_viewed
from #product_summary
order by viewed desc;
--> Oyster has the most views.

select top 1 product_name as most_cart_added
from #product_summary
order by cart_added desc;
--> Lobster had the most cart adds.

select top 1 product_name as most_purchased
from #product_summary
order by purchased desc;
--> Lobster had the most purchases.


--2. Which product was most likely to be abandoned?
select top 1 product_name as can_be_abandoned
from #product_summary
order by abandoned desc;
--> Russian Caviar was most likely to be abandoned.


--3. Which product had the highest view to purchase percentage?
select top 1 product_name ,
cast (100.0 *  purchased / viewed as decimal(10,2)) as view_purchase_cnt
from #product_summary
order by view_purchase_cnt desc;
--> Lobster had the highest view to purchase percentage?


--4. What is the average conversion rate from view to cart add?
select
cast (avg(100.0 *  cart_added / viewed) as decimal(10,2)) as view_cart_add
from #product_summary;


--5. What is the average conversion rate from cart add to purchase?
select
cast (avg(100.0 *  purchased / cart_added) as decimal(10,2)) as avg_cart_to_purchase
from #product_summary;
