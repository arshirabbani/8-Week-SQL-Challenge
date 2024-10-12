-------------------------------------
--A. Data Exploration and Cleansing--
-------------------------------------

--1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month

--Modify the length of column month_year so it can store 12 characters
alter table fresh_segments.interest_metrics
alter column month_year  varchar(12);

--update fresh_segments.interest_metrics 
set month_year = CONVERT(DATE, '01-' + month_year, 105);

--alter table fresh_segments.interest_metrics
alter column month_year  date;

select * from fresh_segments.interest_metrics;


--2. What is count of records in the fresh_segments.interest_metrics for each month_year value 
--sorted in chronological order (earliest to latest) with the null values appearing first?

select month_year, count(1) as cnt from fresh_segments.interest_metrics
group by month_year
order by month_year;


--3. What do you think we should do with these null values in the fresh_segments.interest_metrics?

--interest_id = 21246 have NULL _month, _year, and month_year
select *  from fresh_segments.interest_metrics
where  month_year is null
order by interest_id desc;


--4. How many interest_id values exist in the fresh_segments.interest_metrics table 
--but not in the fresh_segments.interest_map table? What about the other way around?

select count(distinct map.id) as map_id_cnt,
count(distinct metrics.interest_id) as map_id_cnt,
sum(case when map.id is null then 1 end) as not_in_map,
sum(case when metrics.interest_id is null then 1 end) as not_in_metrics
from fresh_segments.interest_metrics metrics
full join fresh_segments.interest_map map
on map.id = metrics.interest_id;
  

--5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table

select count(*) as map_id_cnt
from fresh_segments.interest_map;


--6. What sort of table join should we perform for our analysis and why? 
--Check your logic by checking the rows where interest_id = 21246 in your joined output and 
--include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.

select 
  metrics.*,
  map.interest_name,
  map.interest_summary,
  map.created_at,
  map.last_modified
from fresh_segments.interest_metrics metrics
join fresh_segments.interest_map map ON metrics.interest_id = map.id
where metrics.interest_id = 21246;
  
  
--7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? 
--Do you think these values are valid and why?

--Check if metrics.month_year < map.created_at
select count(*) as record_cnt
from fresh_segments.interest_metrics metrics
join fresh_segments.interest_map map ON metrics.interest_id = map.id
where month_year <  CAST(map.created_at AS DATE);

--Check if metrics.month_year and map.created_at are in the same month
select count(1) as record_cnt
from fresh_segments.interest_metrics metrics
join fresh_segments.interest_map map ON metrics.interest_id = map.id
where month_year <  CAST(DATEADD(DAY, -DAY(map.created_at)+1, map.created_at) AS DATE);
