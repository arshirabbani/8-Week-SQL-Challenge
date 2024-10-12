# 🍊 Case Study #8 - Fresh Segments
## B. Interest Analysis
### 1. Which interests have been present in all `month_year` dates in our dataset?
```TSQL
-- Find how many unique month_year dates in our dataset
declare @total_month_year int = (select count(distinct month_year) from fresh_segments.interest_metrics)

SELECT interest_id, count(month_year) as month_year_cnt
FROM fresh_segments.interest_metrics metrics
group by interest_id
having count(month_year)  = @total_month_year
```
480 rows in total. The first 10 rows:

| interest_id | month_year_cnt |
|-------------|----------------|
| 5970        | 14             |
| 33191       | 14             |
| 10978       | 14             |
| 10838       | 14             |
| 111         | 14             |
| 17540       | 14             |
| 10988       | 14             |
| 6391        | 14             |
| 18202       | 14             |
| 6367        | 14             |


480 interests out of 1202 interests are present in all `month_year`.

---
### 2. Using this same `total_months` measure - calculate the cumulative percentage of all records starting at 14 months - which `total_months` value passes the 90% cumulative percentage value?
```TSQL
with total_months as (
SELECT interest_id, count(distinct month_year) as total_months
FROM fresh_segments.interest_metrics metrics
group by interest_id)
,interests as ( select total_months, count(interest_id) as interests
from total_months
group by total_months)
select *, cast (100.0* sum(interests) over (order by total_months desc) / sum(interests) over() as decimal(10,2)) as cumulative_perc
from interests;
```
| total_months | interests | cumulative_perc |
|--------------|-----------|-----------------|
| 14           | 480       | 39.93           |
| 13           | 82        | 46.76           |
| 12           | 65        | 52.16           |
| 11           | 94        | 59.98           |
| 10           | 86        | 67.14           |
| 9            | 95        | 75.04           |
| 8            | 67        | 80.62           |
| 7            | 90        | 88.10           |
| 6            | 33        | 90.85           |
| 5            | 38        | 94.01           |
| 4            | 32        | 96.67           |
| 3            | 15        | 97.92           |
| 2            | 12        | 98.92           |
| 1            | 13        | 100.00          |


Interests with total months of 6 and above received a 90% and above cumulative percentage. 
Interests below 6 months should be investigated to improve their clicks and customer interactions.

---
### 3. If we were to remove all `interest_id` values which are lower than the `total_months` value we found in the previous question - how many total data points would we be removing?
```TSQL

with total_months as (
SELECT interest_id, count(distinct month_year) as total_months
FROM fresh_segments.interest_metrics metrics
group by interest_id)
select count(im.interest_id) as total_interests,
count(distinct im.interest_id) as distinct_interest_id
from fresh_segments.interest_metrics im
inner join total_months tm on im.interest_id = tm.interest_id
where total_months < 6;
```
| total_interests | distinct_interest_id  |
|-----------------|-----------------------|
| 400             | 110                   |

If we removed all 110 `interest_id` values that are below 6 months in the table `interest_metrics`, 400 data points would be removing.

---
### 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.
From the business perspective, we shouldn't remove these data points even if those customers didn't contribute much to the business outcome.
When checking the timeline of our data set, I realized that this business had just started 1 year and 1 month. 
The timeline was too short to decide whether those customers will go back or not.
```TSQL
with cte as (
SELECT interest_id, count(distinct month_year) as total_months
FROM fresh_segments.interest_metrics metrics
group by interest_id)
select min(total_months) as min_month, max(total_months) as max_month
from cte
```
| min_month | max_month |
|-----------|-----------|
| 1         | 14        |

As we see the max(month_year) count is 14 months and min is 1 month.
let's query for both 14 and 1 to find teh data diff.

```TSQL
--When total_months = 14
SELECT 
  month_year,
  COUNT(DISTINCT interest_id) interest_count,
  MIN(ranking) AS highest_rank,
  MAX(composition) AS composition_max,
  MAX(index_value) AS index_max
FROM fresh_segments.interest_metrics metrics
WHERE interest_id IN (
  SELECT interest_id
  FROM fresh_segments.interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
  HAVING COUNT(DISTINCT month_year) = 14)
GROUP BY month_year
ORDER BY month_year, highest_rank;
```
| month_year | interest_count | highest_rank | composition_max | index_max  |
|------------|----------------|--------------|-----------------|------------|
| 2018-07-01 | 480            | 1            | 18.82           | 6.19       |
| 2018-08-01 | 480            | 1            | 13.9            | 2.84       |
| 2018-09-01 | 480            | 1            | 14.29           | 2.84       |
| 2018-10-01 | 480            | 1            | 15.15           | 3.37       |
| 2018-11-01 | 480            | 1            | 14.92           | 3.48       |
| 2018-12-01 | 480            | 3            | 15.05           | 3.13       |
| 2019-01-01 | 480            | 2            | 14.92           | 2.95       |
| 2019-02-01 | 480            | 2            | 14.39           | 3          |
| 2019-03-01 | 480            | 2            | 12.64           | 2.81       |
| 2019-04-01 | 480            | 2            | 11.01           | 2.85       |
| 2019-05-01 | 480            | 2            | 7.53            | 3.13       |
| 2019-06-01 | 480            | 2            | 6.94            | 4.01       |
| 2019-07-01 | 480            | 2            | 7.19            | 3.95       |
| 2019-08-01 | 480            | 2            | 7.1             | 3.99       |

```TSQL
--When total_months = 1
SELECT 
  month_year,
  COUNT(DISTINCT interest_id) interest_count,
  MIN(ranking) AS highest_rank,
  MAX(composition) AS composition_max,
  MAX(index_value) AS index_max
FROM fresh_segments.interest_metrics metrics
WHERE interest_id IN (
  SELECT interest_id
  FROM fresh_segments.interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
  HAVING COUNT(DISTINCT month_year) = 1)
GROUP BY month_year
ORDER BY month_year, highest_rank;
```
| month_year | interest_count | highest_rank | composition_max | index_max  |
|------------|----------------|--------------|-----------------|------------|
| 2018-07-01 | 6              | 283          | 5.21            | 2.11       |
| 2018-08-01 | 1              | 657          | 1.81            | 0.95       |
| 2018-09-01 | 1              | 771          | 1.59            | 0.63       |
| 2019-02-01 | 2              | 1001         | 2.11            | 0.93       |
| 2019-03-01 | 1              | 1135         | 1.57            | 0.51       |
| 2019-08-01 | 2              | 437          | 2.6             | 1.83       |

Let's say we want to take the average, maximum or minimum of `ranking`, `composition` or `index_values` for each interest in every month, interests that don't have 14 months would create uneven distribution of observations since there are months we don't have data. Therefore, we should archive these data points in the segment analysis to have an accurate view on the overall interest of customers.

---
### 5. After removing these interests - how many unique interests are there for each month?
As mentioned before, instead of deleting interests below 6 months, I create a temporary table `interest_metrics_edited` excluded them for the segment analysis.

```TSQL
--Create a temporary table [interest_metrics_edited]
SELECT *
INTO #updated_interest_metrics
FROM fresh_segments.interest_metrics
WHERE interest_id NOT IN (
  SELECT interest_id
  FROM fresh_segments.interest_metrics
  GROUP BY interest_id
  HAVING COUNT(DISTINCT month_year) < 6);

select count (interest_id) as total_interest_id,
count(distinct interest_id) as distinct_interest_id
from #updated_interest_metrics;

```
| total_interest_id | distinct_interest_id  |
|-------------------|-----------------------|
| 12680             | 1092                  |

Noticed that the number of unique interests has dropped from 1202 (*[Question 4 part A](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution/A.%20Data%20Exploration%20and%20Cleansing.md)*) to 1092, which is 110 interests corresponding to 400 data points (Question 3 this part).

To find the number of unique interests for each month after removing step above:
```TSQL
select month_year,count(distinct interest_id) as distinct_interest_id
from #updated_interest_metrics
where month_year is not null
group by month_year
order by month_year;
```
| month_year | distinct_interest_id  |
|------------|-----------------------|
| 2018-07-01 | 709                   |
| 2018-08-01 | 752                   |
| 2018-09-01 | 774                   |
| 2018-10-01 | 853                   |
| 2018-11-01 | 925                   |
| 2018-12-01 | 986                   |
| 2019-01-01 | 966                   |
| 2019-02-01 | 1072                  |
| 2019-03-01 | 1078                  |
| 2019-04-01 | 1035                  |
| 2019-05-01 | 827                   |
| 2019-06-01 | 804                   |
| 2019-07-01 | 836                   |
| 2019-08-01 | 1062                  |

---
My solution for **[C. Segment Analysis](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution/C.%20Segment%20Analysis.md)**.
