------------------------
--B. Interest Analysis--
------------------------

--1. Which interests have been present in all month_year dates in our dataset?

-- Find how many unique month_year dates in our dataset
declare @total_month_year int = (select count(distinct month_year) from fresh_segments.interest_metrics)

SELECT interest_id, count(month_year) as month_year_cnt
FROM fresh_segments.interest_metrics metrics
group by interest_id
having count(month_year)  = @total_month_year


--2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months 
-- which total_months value passes the 90% cumulative percentage value?

with total_months as (
SELECT interest_id, count(distinct month_year) as total_months
FROM fresh_segments.interest_metrics metrics
group by interest_id)
,interests as ( select total_months, count(interest_id) as interests
from total_months
group by total_months)
select *, cast (100.0* sum(interests) over (order by total_months desc) / sum(interests) over() as decimal(10,2)) as cumulative_perc
from interests;


--3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question 
--- how many total data points would we be removing?


with total_months as (
SELECT interest_id, count(distinct month_year) as total_months
FROM fresh_segments.interest_metrics metrics
group by interest_id)
select count(im.interest_id) as total_interests,
count(distinct im.interest_id) as distinct_interest_id
from fresh_segments.interest_metrics im
inner join total_months tm on im.interest_id = tm.interest_id
where total_months < 6;


--4. Does this decision make sense to remove these data points from a business perspective? 
--Use an example where there are all 14 months present to a removed interest example for your arguments 
-- think about what it means to have less months present from a segment perspective.

with cte as (
SELECT interest_id, count(distinct month_year) as total_months
FROM fresh_segments.interest_metrics metrics
group by interest_id)
select min(total_months) as min_month, max(total_months) as max_month
from cte

As we see the max(month_year) count is 14 months and min is 1 month.
lets query for both 14 and 1 to find teh data diff.

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


--5. After removing these interests - how many unique interests are there for each month?

--Create a temporary table [interest_metrics_edited] that removes all interest_id that have total_months lower than 6
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


--Find the number of unique interests for each month after removing step above
select month_year,count(distinct interest_id) as distinct_interest_id
from #updated_interest_metrics
where month_year is not null
group by month_year
order by month_year;