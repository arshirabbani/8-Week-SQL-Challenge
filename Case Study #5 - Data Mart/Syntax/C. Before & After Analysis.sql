------------------------------
--C. Before & After Analysis--
------------------------------

--1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

--Find the week_number of '2020-06-15' (@weekNum=25)

declare @weeknum int = (select distinct week_number from data_mart.clean_weekly_sales where week_date = '2020-06-15');

with saleschange as (
select 
sum(case when week_number between @weeknum-4 and @weeknum-1 then sales end) as before_sales,
sum(case when week_number between @weeknum and @weeknum+3 then sales end) as after_sales
from data_mart.clean_weekly_sales
where calendar_year = '2020')
select before_sales, after_sales,
round(cast (100* (after_sales - before_sales)as float)/before_sales,2) as sales_change_pct
from saleschange;


--2. What about the entire 12 weeks before and after?

declare @weeknum int = (select distinct week_number from data_mart.clean_weekly_sales where week_date = '2020-06-15');

with saleschange as (
select 
sum(case when week_number between @weeknum-12 and @weeknum-1 then sales end) as before_sales,
sum(case when week_number between @weeknum and @weeknum+11 then sales end) as after_sales
from data_mart.clean_weekly_sales
where calendar_year = '2020')
select before_sales, after_sales,
round(cast (100* (after_sales - before_sales)as float)/before_sales,2) as sales_change_pct
from saleschange;


--3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

--Part 1: How do the sales metrics for 4 weeks before and after compared with the previous years in 2018 and 2019
--Find the week_number of '2020-06-15' (@weekNum=25)
declare @weeknum int = (select distinct week_number from data_mart.clean_weekly_sales where week_date = '2020-06-15');

with saleschange as (
select calendar_year,
sum(case when week_number between @weeknum-4 and @weeknum-1 then sales end) as before_sales,
sum(case when week_number between @weeknum and @weeknum+3 then sales end) as after_sales
from data_mart.clean_weekly_sales
group by calendar_year)
select *,
round(cast (100* (after_sales - before_sales)as float)/before_sales,2) as sales_change_pct
from saleschange order by calendar_year;


--Part 2: How do the sales metrics for 12 weeks before and after compared with the previous years in 2018 and 2019
--Find the week_number of '2020-06-15' (@weekNum=25)
declare @weeknum int = (select distinct week_number from data_mart.clean_weekly_sales where week_date = '2020-06-15');

with saleschange as (
select calendar_year,
sum(case when week_number between @weeknum-12 and @weeknum-1 then sales end) as before_sales,
sum(case when week_number between @weeknum and @weeknum+11 then sales end) as after_sales
from data_mart.clean_weekly_sales
group by calendar_year)
select *,
round(cast (100* (after_sales - before_sales)as float)/before_sales,2) as sales_change_pct
from saleschange order by calendar_year;
