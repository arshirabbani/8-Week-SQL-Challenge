-----------------------
--C. Segment Analysis--
-----------------------

--1. Using our filtered dataset by removing the interests with less than 6 months worth of data, 
--which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? 
--Only use the maximum composition value for each interest but you must keep the corresponding month_year.

WITH max_composition AS (
    SELECT 
        month_year, 
        interest_id,
        MAX(composition) OVER (PARTITION BY interest_id) AS max_composition
    FROM #updated_interest_metrics
),
rank_composition AS (
    SELECT 
        *, 
        DENSE_RANK() OVER (ORDER BY max_composition DESC) AS rn
    FROM max_composition
)

--Top 10 interests that have the largest composition values
SELECT DISTINCT TOP 10 
    rc.interest_id,
    im.interest_name, 
    rc.max_composition, 
    rc.rn AS rank
FROM rank_composition rc
JOIN fresh_segments.interest_map im 
    ON rc.interest_id = im.id
ORDER BY rank ASC;

--Bottom 10 interests that have the largest composition values
SELECT DISTINCT TOP 10 
    rc.interest_id,
    im.interest_name, 
    rc.max_composition, 
    rc.rn AS rank
FROM rank_composition rc
JOIN fresh_segments.interest_map im 
    ON rc.interest_id = im.id
ORDER BY rank DESC;


--2. Which 5 interests had the lowest average ranking value?

select top 5 im.id,interest_name,
cast (avg(1.0*ranking) as decimal(10,2)) as avg_ranking
from #updated_interest_metrics uim
JOIN fresh_segments.interest_map im ON uim.interest_id = im.id
group by  im.id,interest_name
order by avg_ranking asc;

--3. Which 5 interests had the largest standard deviation in their percentile_ranking value?

select top 5 im.id,interest_name,
round(STDEV(percentile_ranking),2) as standard_dev_in_perc
from #updated_interest_metrics uim
JOIN fresh_segments.interest_map im ON uim.interest_id = im.id
group by  im.id,interest_name
order by standard_dev_in_perc desc;


--4. For the 5 interests found in the previous question - what were minimum and maximum percentile_ranking values for each interest 
--and its corresponding year_month value? Can you describe what is happening for these 5 interests?

--Based on the query for the previous question
WITH largest_dev_pct AS (
    SELECT TOP 5 
        im.id AS interest_id, 
        interest_name,
        ROUND(STDEV(percentile_ranking), 2) AS standard_dev_in_perc
    FROM #updated_interest_metrics uim
    JOIN fresh_segments.interest_map im ON uim.interest_id = im.id
    GROUP BY im.id, interest_name
    ORDER BY standard_dev_in_perc DESC
),
max_min_perc AS (
    SELECT 
        uim.interest_id, 
        interest_name, 
        uim.month_year,
        uim.percentile_ranking,
        MAX(percentile_ranking) OVER(PARTITION BY uim.interest_id) AS max_ranking,
        MIN(percentile_ranking) OVER(PARTITION BY uim.interest_id) AS min_ranking
    FROM largest_dev_pct ldp
    INNER JOIN #updated_interest_metrics uim ON ldp.interest_id = uim.interest_id
)
SELECT 
    interest_id, 
    interest_name,
    MAX(CASE WHEN percentile_ranking = max_ranking THEN month_year END) AS max_month_year,
    MAX(CASE WHEN percentile_ranking = max_ranking THEN percentile_ranking END) AS max_percentile_ranking,
    MIN(CASE WHEN percentile_ranking = min_ranking THEN month_year END) AS min_month_year,
    MIN(CASE WHEN percentile_ranking = min_ranking THEN percentile_ranking END);

