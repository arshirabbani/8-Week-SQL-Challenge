-----------------------
--A. Digital Analysis--
-----------------------

--1. How many users are there?

select count(distinct user_id) as user_cnt from clique_bait.users;


--2. How many cookies does each user have on average?

with avg_cnt as (
select user_id, 1.0* count(cookie_id) as cookie_cnt 
from clique_bait.users 
group by user_id)
select cast (avg(cookie_cnt)as float) as avg_cookie_cnt
from avg_cnt;


--3. What is the unique number of visits by all users per month?

select datepart(month, event_time) as month_no,
datename(month, event_time) as month_name,
count(distinct visit_id) as no_of_visit
from clique_bait.events
group by datepart(month, event_time),datename(month, event_time)
order by month_no;


--4. What is the number of events for each event type?

select e.event_type, event_name, count(1) as evnt_cnt
from clique_bait.events e
inner join clique_bait.event_identifier ei
on ei.event_type = e.event_type
group by e.event_type, event_name
order by e.event_type;


--5. What is the percentage of visits which have a purchase event?

declare @total_visit as integer  = (select count(distinct visit_id) from clique_bait.event)

select  round(100.0 * cast (count(distinct visit_id) as float)/ @total_visit,2) as purchase_pct
from clique_bait.events e
inner join clique_bait.event_identifier ei
on ei.event_type = e.event_type
where event_name= 'Purchase';


--6. What is the percentage of visits which view the checkout page but do not have a purchase event?

with checkout_view as (
select  distinct visit_id,
sum(case when event_name= 'Purchase' then 1 else 0 end ) as Purchase,
sum(case when event_name!= 'Purchase' and page_id = 12 then 1 else 0 end ) as checkout_buy
from clique_bait.events e
inner join clique_bait.event_identifier ei
on ei.event_type = e.event_type
group by visit_id)
select  100 - round(cast (100.0*sum(Purchase) as float) / sum(checkout_buy),2) as perc_visit_without_purchase
from checkout_view;


--7. What are the top 3 pages by number of views?

select top 3 page_name, count(e.visit_id) as page_visit
from clique_bait.events e
inner join clique_bait.page_hierarchy p on  e.page_id=p.page_id
group by page_name
order by page_visit desc;


--8. What is the number of views and cart adds for each product category?

select  product_category,
sum(case when event_name = 'Page View' then 1 else 0 end) as page_views,
sum(case when event_name = 'Add to Cart' then 1 else 0 end) as cart_adds
from clique_bait.event e
inner join clique_bait.event_identifier ei on e.event_type = ei.event_type
inner join clique_bait.page_hierarchy ph on  e.page_id = ph.page_id
where product_category is not null
group by product_category;


--9. What are the top 3 products by purchases?

select top 3 product_id, page_name , count(1) as purchase_cnt
from clique_bait.event e
inner join clique_bait.event_identifier ei on e.event_type = ei.event_type
inner join clique_bait.page_hierarchy ph on  e.page_id = ph.page_id
where event_name = 'Add to Cart'
and visit_id  in (
select  visit_id from clique_bait.event e1 inner join clique_bait.event_identifier ei on e1.event_type = ei.event_type
where event_name = 'Purchase')
group by product_id, page_name
order by purchase_cnt desc;
