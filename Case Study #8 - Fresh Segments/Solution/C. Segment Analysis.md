# 🍊 Case Study #8 - Fresh Segments
## C. Segment Analysis
### 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any `month_year`? Only use the maximum `composition` value for each interest but you must keep the corresponding `month_year`.

* Create a CTE `max_composition` to find the maximum `composition` value for each interest. To keep the corresponding `month_year`, use the window funtion `MAX() OVER()` instead of the aggregate function `MAX()` with `GROUP BY`. 
* Create a CTE `composition_rank` to rank all maximum compositions for each `interest_id` in any `month_year` from the CTE `max_composition`
* Filter top 10 or bottom 10 interests using `WHERE`, then JOIN `max_composition` with `interest_map` to take the `interest_name` for each corresponding `interest_id`

```TSQL
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
```
Top 10 interests which have the largest composition values in any `month_year`:

| interest_id | interest_name                       | max_composition | rank |
|-------------|-------------------------------------|-----------------|------|
| 21057       | Work Comes First Travelers          | 21.2            | 1    |
| 6284        | Gym Equipment Owners                | 18.82           | 2    |
| 39          | Furniture Shoppers                  | 17.44           | 3    |
| 77          | Luxury Retail Shoppers              | 17.19           | 4    |
| 12133       | Luxury Boutique Hotel Researchers   | 15.15           | 5    |
| 5969        | Luxury Bedding Shoppers             | 15.05           | 6    |
| 171         | Shoe Shoppers                       | 14.91           | 7    |
| 4898        | Cosmetics and Beauty Shoppers       | 14.23           | 8    |
| 6286        | Luxury Hotel Guests                 | 14.1            | 9    |
| 4           | Luxury Retail Researchers           | 13.97           | 10   |


Using the CTE above, replace the filter for top 10 interests by this:
```TSQL
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
```
Bottom 10 interests which have the largest composition values in any `month_year`:

| interest_id | interest_name                    | max_composition | rank |
|-------------|----------------------------------|-----------------|------|
| 33958       | Astrology Enthusiasts            | 1.88            | 555  |
| 37412       | Medieval History Enthusiasts     | 1.94            | 554  |
| 19599       | Dodge Vehicle Shoppers           | 1.97            | 553  |
| 19635       | Xbox Enthusiasts                 | 2.05            | 552  |
| 19591       | Camaro Enthusiasts               | 2.08            | 551  |
| 37421       | Budget Mobile Phone Researchers  | 2.09            | 550  |
| 42011       | League of Legends Video Game Fans| 2.09            | 550  |
| 22408       | Super Mario Bros Fans            | 2.12            | 549  |
| 34085       | Oakland Raiders Fans             | 2.14            | 548  |
| 36138       | Haunted House Researchers        | 2.18            | 547  |


---
### 2. Which 5 interests had the lowest average `ranking` value?
```TSQL
select top 5 im.id,interest_name,
cast (avg(1.0*ranking) as decimal(10,2)) as avg_ranking
from #updated_interest_metrics uim
JOIN fresh_segments.interest_map im ON uim.interest_id = im.id
group by  im.id,interest_name
order by avg_ranking asc;
```
| interest_id | interest_name                  | avg_ranking  |
|-------------|--------------------------------|--------------|
| 41548       | Winter Apparel Shoppers        | 1.00         |
| 42203       | Fitness Activity Tracker Users | 4.11         |
| 115         | Mens Shoe Shoppers             | 5.93         |
| 171         | Shoe Shoppers                  | 9.36         |
| 4           | Luxury Retail Researchers      | 11.86        |

---
### 3. Which 5 interests had the largest standard deviation in their `percentile_ranking` value?
```TSQL
select top 5 im.id,interest_name,
round(STDEV(percentile_ranking),2) as standard_dev_in_perc
from #updated_interest_metrics uim
JOIN fresh_segments.interest_map im ON uim.interest_id = im.id
group by  im.id,interest_name
order by standard_dev_in_perc desc;
```
| interest_id | interest_name                          | standard_dev_in_perc    |
|-------------|----------------------------------------|-------------------------|
| 23          | Techies                                | 30.18                   |
| 20764       | Entertainment Industry Decision Makers | 28.97                   |
| 38992       | Oregon Trip Planners                   | 28.32                   |
| 43546       | Personalized Gift Shoppers             | 26.24                   |
| 10839       | Tampa and St Petersburg Trip Planners  | 25.61                   |

---
### 4. For the 5 interests found in the previous question - what was minimum and maximum `percentile_ranking` values for each interest and its corresponding `year_month` value? Can you describe what is happening for these 5 interests?
```TSQL
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

```
| interest_id | interest_name                                 | max_month_year | max_percentile_ranking | min_month_year | min_percentile_ranking |
|-------------|-----------------------------------------------|----------------|------------------------|----------------|------------------------|
| 10839       | Tampa and St Petersburg Trip Planners        | 2018-07-01     | 75.03                  | 2019-03-01     | 4.84                   |
| 20764       | Entertainment Industry Decision Makers        | 2018-07-01     | 86.15                  | 2019-08-01     | 11.23                  |
| 23          | Techies                                      | 2018-07-01     | 86.69                  | 2019-08-01     | 7.92                   |
| 38992       | Oregon Trip Planners                         | 2018-11-01     | 82.44                  | 2019-07-01     | 2.2                    |
| 43546       | Personalized Gift Shoppers                   | 2019-03-01     | 73.15                  | 2019-06-01     | 5.7                    |


We can see that the the range between the maximum and minimum `percentile_ranking` of 5 interests in the table above is very large. 
Noticed that the month of the maximum and minumum values are different. This implies that these interests may have the seasonal demand or there are other underlying reasons related to products, services or prices that we should investigate further.

For example, customers prefer interest `10839`, which is `Tampa and St Petersburg Trip Planners` on July 2018, but not prefer that on March 2019. 
This might be because the trip on July was cheaper or the weather on those places was more suitable for travelling.

---
### 5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?

Customers in this segment love travelling and personalized gifts but they just want to spend once. That's why we can see that in one month of 2018, the `percentile_ranking` was very high; but in another month of 2019, that value was quite low. These customers are also interested in new trends in tech and entertainment industries. 

Therefore, we should only recommend only one-time accomodation services and personalized gift to them. We can ask them to sign-up to newsletters for tech products or new trends in entertainment industry as well.

---
My solution for **[D. Index Analysis](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution/D.%20Index%20Analysis.md)**.
