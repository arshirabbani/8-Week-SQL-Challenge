-------------------------
--C. Campaigns Analysis--
-------------------------
/*Generate a table that has 1 single row for every unique visit_id record and has the following columns:
- user_id
- visit_id
- visit_start_time: the earliest event_time for each visit
- page_views: count of page views for each visit
- cart_adds: count of product cart add events for each visit
- purchase: 1/0 flag if a purchase event exists for each visit
- campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
- impression: count of ad impressions for each visit
- click: count of ad clicks for each visit
- (Optional column) cart_products: a comma separated text value with products added to the cart 
sorted by the order they were added to the cart (hint: use the sequence_number)
*/

select u.user_id, e.visit_id,
campaign_name,
sum(case when event_name = 'Add to Cart' then 1 else 0 end ) as card_added,
sum(case when event_name = 'Page View' then 1 else 0 end ) as page_viewed,
sum(case when event_name = 'Purchase' then 1 else 0 end ) as purchased,
sum(case when event_name = 'Ad Impression' then 1 else 0 end ) as impression,
sum(case when event_name = 'Ad Click' then 1 else 0 end ) as clicked,
STRING_AGG(case when event_name = 'Add to Cart' then page_name end , ',') 
within group (order by sequence_number)as cart_product
into #campaign_summary
from clique_bait.event e
inner join clique_bait.users u on e.cookie_id = u.cookie_id
inner join clique_bait.event_identifier ei on e.event_type = ei.event_type
inner join clique_bait.page_hierarchy ph on  e.page_id = ph.page_id
left join clique_bait.campaign_identifier ci on  e.event_time between ci.start_date and ci.end_date
group by u.user_id, e.visit_id,campaign_name;

select * from  #campaign_summary



/*
- Identifying users who have received impressions during each campaign period 
and comparing each metric with other users who did not have an impression event
- Does clicking on an impression lead to higher purchase rates?
- What is the uplift in purchase rate when comparing users who click on a campaign impression versus 
users who do not receive an impression? What if we compare them with users who have just an impression but do not click?
- What metrics can you use to quantify the success or failure of each campaign compared to each other?
*/


--1. Calculate the number of users in each group

--Number of users who received impressions during campaign periods = 417
select count(distinct user_id) recieved_impressions
from  #campaign_summary
where impression >0
and campaign_name is not null;


--Number of users who received impressions but didn't click on ads = 127
select count(distinct user_id) recieved_but_not_click
from  #campaign_summary
where impression >0
and clicked = 0
and campaign_name is not null;


--Number of users who didn't receive impressions during campaign periods = 56
select count(distinct user_id) not_recieved_impressions
from  #campaign_summary
where  campaign_name is not null
and user_id not in (
select  user_id recieved_impressions
from  #campaign_summary
where impression >0);


--2. Calculate the average clicks, average views, average cart adds, and average purchases of each group

--For users who received impressions
declare @recieved int 
set @recieved = 417

select  
cast (1.0*sum(page_viewed) / @recieved as decimal (10,2)) as avg_viewed,
cast (1.0*sum(card_added) / @recieved as decimal (10,2)) as avg_cart_added,
cast (1.0*sum(purchased) / @recieved as decimal (10,2)) as avg_purchased
from #campaign_summary
where impression>0
and campaign_name is not null;


--For users who received impressions but didn't click on ads
declare @recieved_but_not_click int 
set @recieved_but_not_click = 127

select  
cast (1.0*sum(page_viewed) / @recieved_but_not_click as decimal (10,2)) as avg_viewed,
cast (1.0*sum(card_added) / @recieved_but_not_click as decimal (10,2)) as avg_cart_added,
cast (1.0*sum(purchased) / @recieved_but_not_click as decimal (10,2)) as avg_purchased
from #campaign_summary
where impression>0
and clicked = 0
and campaign_name is not null;


--For users who didn't receive impressions 
declare @recieved_but_not_click int 
set @recieved_but_not_click = 56

select  
cast (1.0*sum(page_viewed) / @recieved_but_not_click as decimal (10,2)) as avg_viewed,
cast (1.0*sum(card_added) / @recieved_but_not_click as decimal (10,2)) as avg_cart_added,
cast (1.0*sum(purchased) / @recieved_but_not_click as decimal (10,2)) as avg_purchased
from #campaign_summary
where campaign_name is not null
and user_id not in (
select  user_id recieved_impressions
from  #campaign_summary
where impression >0);
  
  
--3. Compare the average views, average cart adds and average purchases of users received impressions and not received impressions

/* Combine table
|                             | avg_viewed | avg_cart_added | avg_purchased |
|-----------------------------|------------|----------------|---------------|
| Received impressions        | 15.3       | 9.0            | 1.52          |
| Not received impressions    | 19.39      | 5.75           | 1.23          |
| *Increase by campaigns*     | *No*       | *Yes*          | *Yes*         |
*/


--4. Compare the average purchases of users received impressions and received impressions but not clicked to ads
/* Combine table
|                                      | avg_purchased |
|--------------------------------------|---------------|
| Received impressions                 | 1.53          |
| Received impressions but not clicked | 0.8           |
| *Increase by clicking to the ads*    | *Yes*         |
*/
