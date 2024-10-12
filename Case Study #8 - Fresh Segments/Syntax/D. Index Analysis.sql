---------------------
--D. Index Analysis--
---------------------

--1. What is the top 10 interests by the average composition for each month?

with avg_composition as (select  map.id as interest_id, interest_name, month_year,
round(composition / index_value,2) as avg_composition,
dense_rank() over(partition by month_year order by composition / index_value desc) as rn
FROM fresh_segments.interest_metrics metrics
JOIN fresh_segments.interest_map map 
ON metrics.interest_id = map.id
WHERE metrics.month_year IS NOT NULL)
select * from avg_composition
where rn <=10;


--2. For all of these top 10 interests - which interest appears the most often?

WITH avg_composition AS (
    SELECT  
        map.id AS interest_id, 
        interest_name, 
        month_year,
        ROUND(composition / index_value, 2) AS avg_composition,
        DENSE_RANK() OVER (PARTITION BY month_year ORDER BY composition / index_value DESC) AS rn
    FROM 
        fresh_segments.interest_metrics metrics
    JOIN 
        fresh_segments.interest_map map ON metrics.interest_id = map.id
    WHERE 
        metrics.month_year IS NOT NULL
),
occu_freq AS (
    SELECT  
        interest_id, 
        interest_name,
        COUNT(1) AS occu_freq
    FROM 
        avg_composition
    WHERE 
        rn <= 10
    GROUP BY 
        interest_id, interest_name
)
SELECT *
FROM occu_freq 
WHERE occu_freq IN (SELECT MAX(occu_freq) FROM occu_freq);



--3. What is the average of the average composition for the top 10 interests for each month?

with avg_composition as (select  map.id as interest_id, interest_name, month_year,
round(composition / index_value,2) as avg_composition,
dense_rank() over(partition by month_year order by composition / index_value desc) as rn
 FROM fresh_segments.interest_metrics metrics
  JOIN fresh_segments.interest_map map 
    ON metrics.interest_id = map.id
  WHERE metrics.month_year IS NOT NULL)
select month_year, avg(avg_composition) as avg_composition_by_month_year
from avg_composition
where rn <=10
group by month_year;


--4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 
--and include the previous top ranking interests in the same output shown below.

WITH avg_composition AS (
    SELECT  
        map.id AS interest_id, 
        interest_name, 
        month_year,
        ROUND(composition / index_value, 2) AS avg_composition,
        ROUND(MAX(composition / index_value) OVER (PARTITION BY month_year), 2) AS max_avg_composition
    FROM 
        fresh_segments.interest_metrics metrics
    JOIN 
        fresh_segments.interest_map map ON metrics.interest_id = map.id
    WHERE 
        metrics.month_year IS NOT NULL
),
max_avg_composition AS (
    SELECT * 
    FROM avg_composition
    WHERE avg_composition = max_avg_composition
),
moving_avg_compositions AS (
    SELECT 
        month_year, 
        interest_name, 
        max_avg_composition,
        ROUND(AVG(max_avg_composition) OVER (ORDER BY month_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS '3_month_rolling_avg',
        LAG(interest_name, 2, 2) OVER (ORDER BY month_year) + ':' + CAST(LAG(max_avg_composition) OVER (ORDER BY month_year) AS VARCHAR(5)) AS '2_month_ago',
        LAG(interest_name) OVER (ORDER BY month_year) + ':' + CAST(LAG(max_avg_composition) OVER (ORDER BY month_year) AS VARCHAR(5)) AS '1_month_ago'
    FROM 
        max_avg_composition mac
)
SELECT *
FROM moving_avg_compositions
WHERE month_year BETWEEN '2018-09-01' AND '2019-08-01';

--5.Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?

The max average composition decreased overtime because top interests were mostly travel-related services, which were in high seasonal demands for some months throughout a year. Customers wanted to go on a trip during the last and first 3 months of a year. You can see max_index_composition were high from September 2018 to March 2019.

This also means that Fresh Segments's business heavily relied on travel-related services. Other products and services didn't receive much interest from customers.