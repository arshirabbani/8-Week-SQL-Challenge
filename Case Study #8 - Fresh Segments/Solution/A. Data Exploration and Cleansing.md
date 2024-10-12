# 🍊 Case Study #8 - Fresh Segments
## A. Data Exploration and Cleansing
### 1. Update the `fresh_segments.interest_metrics` table by modifying the `month_year` column to be a date data type with the start of the month
```TSQL
--Modify the length of column month_year so it can store 12 characters
alter table fresh_segments.interest_metrics
alter column month_year  varchar(12);

--update fresh_segments.interest_metrics 
set month_year = CONVERT(DATE, '01-' + month_year, 105);

--alter table fresh_segments.interest_metrics
alter column month_year  date;

select * from fresh_segments.interest_metrics;
```
The first 10 rows:
| _month | _year | month_year  | interest_id | composition | index_value | ranking | percentile_ranking |
|--------|--------|-------------|-------------|-------------|-------------|---------|--------------------|
| 11     | 2018   | 2018-11-01  | 6211        | 3.46        | 1.7         | 193     | 79.2               |
| 11     | 2018   | 2018-11-01  | 37          | 3.29        | 1.7         | 193     | 79.2               |
| 11     | 2018   | 2018-11-01  | 39657       | 2.84        | 1.7         | 193     | 79.2               |
| 11     | 2018   | 2018-11-01  | 6301        | 4.27        | 1.7         | 193     | 79.2               |
| 11     | 2018   | 2018-11-01  | 33191       | 2.93        | 1.7         | 193     | 79.2               |
| 11     | 2018   | 2018-11-01  | 6106        | 2.39        | 1.7         | 193     | 79.2               |
| 11     | 2018   | 2018-11-01  | 161         | 3.27        | 1.7         | 193     | 79.2               |
| 11     | 2018   | 2018-11-01  | 5913        | 3.79        | 1.69        | 201     | 78.34              |
| 11     | 2018   | 2018-11-01  | 6217        | 6.00        | 1.69        | 201     | 78.34              |
| 11     | 2018   | 2018-11-01 

---
### 2. What is count of records in the `fresh_segments.interest_metrics` for each `month_year` value sorted in chronological order (earliest to latest) with the null values appearing first?
```TSQL
select month_year, count(1) as cnt from fresh_segments.interest_metrics
group by month_year
order by month_year;
```
| month_year | cnt   |
|------------|-------|
| NULL       | 1194  |
| 2018-07-01 | 729   |
| 2018-08-01 | 767   |
| 2018-09-01 | 780   |
| 2018-10-01 | 857   |
| 2018-11-01 | 928   |
| 2018-12-01 | 995   |
| 2019-01-01 | 973   |
| 2019-02-01 | 1121  |
| 2019-03-01 | 1136  |
| 2019-04-01 | 1099  |
| 2019-05-01 | 857   |
| 2019-06-01 | 824   |
| 2019-07-01 | 864   |
| 2019-08-01 | 1149  |

### 3. What do you think we should do with these null values in the `fresh_segments.interest_metrics`?
The null values appear in `_month`, `_year`, `month_year`, and `interest_id`, with the exception of `interest_id` 21246.
```TSQL
select *  from fresh_segments.interest_metrics
where  month_year is null
order by interest_id desc;
```
| _month | _year | month_year | interest_id | composition | index_value | ranking | percentile_ranking |
|--------|--------|------------|-------------|-------------|-------------|---------|--------------------|
| NULL   | NULL   | NULL       | 21246       | 1.61        | 0.68        | 1191    | 0.25               |



### 4. How many `interest_id` values exist in the `fresh_segments.interest_metrics` table but not in the `fresh_segments.interest_map` table? What about the other way around?
```TSQL
select count(distinct map.id) as map_id_cnt,
count(distinct metrics.interest_id) as map_id_cnt,
sum(case when map.id is null then 1 end) as not_in_map,
sum(case when metrics.interest_id is null then 1 end) as not_in_metrics
from fresh_segments.interest_metrics metrics
full join fresh_segments.interest_map map
on map.id = metrics.interest_id;
```
| map_id_cnt   | map_id_cnt       | not_in_map  | not_in_metric |
|--------------|------------------|-------------|---------------|
| 1209         | 1202             | 7           | NULL          |

* There are 1209 `id` in table `interest_map`.
* There are 1202 `interest_id` in table `interest_metrics`.
* No `id` values appear in table `interest_map` but don't appear in `interest_id` of table `interest_metrics`.
* There are 7 `interest_id` appearing in table `interest_metrics` but not appearing in `id` of table `interest_map`.

---
### 5. Summarise the `id` values in the `fresh_segments.interest_map` by its total record count in this table
Recall the query from the previous question.
```TSQL
select count(*) as map_id_cnt
from fresh_segments.interest_map;
```
| map_id_cnt  |
|---------------|
| 1209          |


---
### 6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where `interest_id` = 21246 in your joined output and include all columns from `fresh_segments.interest_metrics` and all columns from `fresh_segments.interest_map` except from the `id` column.
We should perform JOIN between table `interest_metrics` and table `interest_map` in our analysis because only available `interest_id` in table `interest_metrics` are meaningful.
```TSQL
select 
  metrics.*,
  map.interest_name,
  map.interest_summary,
  map.created_at,
  map.last_modified
from fresh_segments.interest_metrics metrics
join fresh_segments.interest_map map ON metrics.interest_id = map.id
where metrics.interest_id = 21246;
````
| _month | _year | month_year | interest_id | composition | index_value | ranking | percentile_ranking | interest_name                 | interest_summary                                          | created_at                | last_modified             |
|--------|--------|------------|-------------|-------------|-------------|---------|--------------------|-------------------------------|----------------------------------------------------------|---------------------------|---------------------------|
| 11     | 2018   | 2018-11-01 | 21246       | 2.25        | 0.78        | 908     | 2.16               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources.     | 2018-06-11 17:50:04.0000000 | 2018-06-11 17:50:04.0000000 |
| 7      | 2018   | 2018-07-01 | 21246       | 2.26        | 0.65        | 722     | 0.96               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources.     | 2018-06-11 17:50:04.0000000 | 2018-06-11 17:50:04.0000000 |
| 8      | 2018   | 2018-08-01 | 21246       | 2.13        | 0.59        | 765     | 0.26               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources.     | 2018-06-11 17:50:04.0000000 | 2018-06-11 17:50:04.0000000 |
| 9      | 2018   | 2018-09-01 | 21246       | 2.06        | 0.61        | 774     | 0.77               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources.     | 2018-06-11 17:50:04.0000000 | 2018-06-11 17:50:04.0000000 |
| 10     | 2018   | 2018-10-01 | 21246       | 1.74        | 0.58        | 855     | 0.23               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources.     | 2018-06-11 17:50:04.0000000 | 2018-06-11 17:50:04.0000000 |
| 12     | 2018   | 2018-12-01 | 21246       | 1.97        | 0.7         | 983     | 1.21               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources.     | 2018-06-11 17:50:04.0000000 | 2018-06-11 17:50:04.0000000 |
| 1      | 2019   | 2019-01-01 | 21246       | 2.05        | 0.76        | 954     | 1.95               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources.     | 2018-06-11 17:50:04.0000000 | 2018-06-11 17:50:04.0000000 |
| 2      | 2019   | 2019-02-01 | 21246       | 1.84        | 0.68        | 1109    | 1.07               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources.     | 2018-06-11 17:50:04.0000000 | 2018-06-11 17:50:04.0000000 |
| 3      | 2019   | 2019-03-01 | 21246       | 1.75        | 0.67        | 1123    | 1.14               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources.     | 2018-06-11 17:50:04.0000000 | 2018-06-11 17:50:04.0000000 |
| 4      | 2019   | 2019-04-01 | 21246       | 1.58        | 0.63        | 1092    | 0.64               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources.     | 2018-06-11 17:50:04.0000000 | 2018-06-11 17:50:04.0000000 |
| NULL   | NULL   | NULL       | 21246       | 1.61        | 0.68        | 1191    | 0.25               | Readers of El Salvadoran Content | People reading news from El Salvadoran media sources.     | 2018-06-11 17:50:04.0000000 | 2018-06-11 17:50:04.0000000 |


Noticed that `interest_id` 21246 has null values in `_month`, `_year`, and `month_year`. 
Therefore, when performing any analysis related to dates, we should exclude that value, otherwise, keep it there.

---
### 7. Are there any records in your joined table where the `month_year` value is before the `created_at` value from the `fresh_segments.interest_map` table? Do you think these values are valid and why?
We first check if `metrics.month_year` values were before the `map.created_at` values.
```TSQL
select count(*) as record_cnt
from fresh_segments.interest_metrics metrics
join fresh_segments.interest_map map ON metrics.interest_id = map.id
where month_year <  CAST(map.created_at AS DATE);
```
| record_cnt  |
|-------------|
| 188         |

There are 188 `month_year` values that are before `created_at` values.
However, it may be the case that those 188 `created_at` values were created at the same month as `month_year` values. 
The reason is because `month_year` values were set on the first date of the month by default in Question 1.


To check that, we turn the `create_at` to the first date of the month:
```TSQL
select count(1) as record_cnt
from fresh_segments.interest_metrics metrics
join fresh_segments.interest_map map ON metrics.interest_id = map.id
where month_year <  CAST(DATEADD(DAY, -DAY(map.created_at)+1, map.created_at) AS DATE);
```
| cnt  |
|------|
| 0    |

Yes, all `month_year` and `created_at` were at the same month. Therefore, these values are valid.

---
My solution for **[B. Interest Analysis](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution/B.%20Interest%20Analysis.md)**.
