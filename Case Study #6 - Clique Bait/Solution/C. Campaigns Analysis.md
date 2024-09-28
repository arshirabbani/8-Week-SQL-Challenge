# 🐟 Case Study #6 - Clique Bait
## C. Campaigns Analysis
Generate a table that has 1 single row for every unique visit_id record and has the following columns:
  * `user_id`
  * `visit_id`
  * `visit_start_time`: the earliest event_time for each visit
  * `page_views`: count of page views for each visit
  * `art_adds`: count of product cart add events for each visit
  * `purchase`: 1/0 flag if a purchase event exists for each visit
  * `campaign_name`: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
  * `impression`: count of ad impressions for each visit
  * `click`: count of ad clicks for each visit
  * (Optional column) `cart_products`: a comma separated text value with 
  products added to the cart sorted by the order they were added to the cart (hint: use the `sequence_number`)
  
  ### Solution

* `INNER JOIN` from table `events` to `users`
* `INNER JOIN` from table `events` to `event_identifier`
* `LEFT JOIN` from table `events` to `campaign_identifier` to display`campaign_name` in all rows regardless of `start_time` and `end_time`.
* To generate earliest `visit_start_time` for each unique `visit_id`, use `MIN()` to find the 1st `visit_time`.
* Use `SUM()` and `CASE` to calculate `page_views`, `cart_adds`, `purchase`, ad `impression` and ad `click` for each `visit_id`.
* To get a comma separated list of products added to cart sorted by `sequence_number`:
  * Use a `CASE` to select `Add to cart` events.
  * Use `STRING_AGG()` to separate products by comma and ` WITHIN GROUP` to order `sequence_number`.
* Store the result in a temporary table `campaign_summary` for further analysis.
  
```TSQL
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

```
3,5644 rows in total. The first 5 rows:

| user_id | visit_id | campaign_name                     | card_added | page_viewed | purchased | impression | clicked | cart_product                                      |
|---------|----------|------------------------------------|------------|-------------|-----------|------------|---------|---------------------------------------------------|
| 1       | 0826dc   | Half Off - Treat Your Shellf(ish)  | 0          | 1           | 0         | 0          | 0       | NULL                                              |
| 1       | ccf365   | Half Off - Treat Your Shellf(ish)  | 3          | 7           | 1         | 0          | 0       | Lobster,Crab,Oyster                               |
| 1       | eaffde   | Half Off - Treat Your Shellf(ish)  | 8          | 10          | 1         | 1          | 1       | Salmon,Tuna,Russian Caviar,Black Truffle,Abalone,Lobster,Crab,Oyster |
| 2       | 1f1198   | Half Off - Treat Your Shellf(ish)  | 0          | 1           | 0         | 0          | 0       | NULL                                              |
| 2       | 910d9a   | Half Off - Treat Your Shellf(ish)  | 1          | 8           | 0         | 0          | 0       | Abalone                                           |


---
Some ideas to investigate further include:
- Identifying users who have received impressions during each campaign period 
and comparing each metric with other users who did not have an impression event
- Does clicking on an impression lead to higher purchase rates?
- What is the uplift in purchase rate when comparing users who click on a campaign impression versus 
users who do not receive an impression? What if we compare them with users who have just an impression but do not click?
- What metrics can you use to quantify the success or failure of each campaign compared to each other?

### Solution
Since the number of users who *received impressions* is higher than those who *did not receive impressions* and those who *received impressions but not clicked to ads*, the total views, total cart adds and total purchases of the prior group are definitely higher than the latter groups. 
Therefore, in this case, I compare *the rate per user* among these groups (instead of the total). The purpose is to check:
* performance of ads: *impression rate* and *click rate*.
* whether the average `page_views`, `cart_adds`, and `purchase` per user increase after running ads.

#### 1. Calculate the number of users in each group

```TSQL
--Number of users who received impressions during campaign periods
select count(distinct user_id) recieved_impressions
from  #campaign_summary
where impression >0
and campaign_name is not null;
```
| received_impressions  |
|-----------------------|
| 417                   |

```TSQL
--Number of users who received impressions but didn't click on the ad during campaign periods
select count(distinct user_id) recieved_but_not_click
from  #campaign_summary
where impression >0
and clicked = 0
and campaign_name is not null;
```
| received_impressions_not_clicked  |
|-----------------------------------|
| 127                               |

```TSQL
--Number of users who didn't receive impressions during campaign periods
select count(distinct user_id) not_recieved_impressions
from  #campaign_summary
where  campaign_name is not null
and user_id not in (
select  user_id recieved_impressions
from  #campaign_summary
where impression >0);
```
| received_impressions  |
|-----------------------|
| 56                    |

Now we know:
* The number of users who received impressions during campaign periods is 417.
* The number of users who received impressions but didn't click on the ad is 127.
* The number of users who didn't receive impressions during campaign periods is 56.

Using those numbers, we can calculate:
* Overall, impression rate = 100 * 417 / (417+56) = 88.2 %
* Overall, click rate = 100-(100 * 127 / 417) = 69.5 %

#### 2. Calculate the average clicks, average views, average cart adds, and average purchases of each group

```TSQL
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
```
| avg_viewed | avg_cart_added | avg_purchased  |
|------------|----------------|----------------|
|  15.3      | 9.0            | 1.52           |

```TSQL
--For users who received impressions but didn't click on the ad
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
```
| avg_viewed | avg_cart_added | avg_purchased  |
|------------|----------------|----------------|
| 7.53       | 2.73           | 0.8            | 

```TSQL
--For users didn't receive impressions 
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
```
| avg_viewed | avg_cart_added | avg_purchased  |
|----------- |----------------|----------------|
| 19.39      | 5.75           | 1.23           |

#### 3. Compare the average views, average cart adds and average purchases of users received impressions and not received impressions

Combine results in (2), we have the table below:

|                             | avg_viewed | avg_cart_added | avg_purchased |
|-----------------------------|------------|----------------|---------------|
| Received impressions        | 15.3       | 9.0            | 1.52          |
| Not received impressions    | 19.39      | 5.75           | 1.23          |
| *Increase by campaigns*     | *No*       | *Yes*          | *Yes*         |

Insights:
* During campaign periods, the average view per user decreases while the average of products added to cart per user and average of purchased products per user increase. Customers might not wander around many pages to select products, but click on ads or directly go to the relevant page having that products. 
* Customers received impressions were more likely to add products to cart then to purchase them: (9-5.8) > (1.5-1.2).

#### 4. Compare the average purchases of users received impressions and received impressions but not clicked to ads
Combine results in (2), we have the table below:

|                                      | avg_purchased |
|--------------------------------------|---------------|
| Received impressions                 | 1.53          |
| Received impressions but not clicked | 0.8           |
| *Increase by clicking to the ads*    | *Yes*         |

Insights:
* The average purchases for users who received impressions but didn't click on ads is lower than those who received impressions in overall. 
* Clicking on ads didn't lead to higher purchase rate.
