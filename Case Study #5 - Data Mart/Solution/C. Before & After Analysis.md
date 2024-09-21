# 🛒 Case Study #5 - Data Mart
## C. Before & After Analysis

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time. 
Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect. 
We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before.

Using this analysis approach - answer the following questions:

### 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
```TSQL

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
```
| before_sales   | after_sales   | sales_change_pct|
|----------------|---------------|-----------------|
| 2345878357     | 2318994169    | -1.15           |

---
### 2. What about the entire 12 weeks before and after?
```TSQL
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
```
| before_sales   | after_sales | sales_change_pct |
|----------------|-------------|------------------|
| 7126273147     | 6973947753  | -2.14            |

---
### 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
Part 1: How do the sales metrics for 4 weeks before and after compared with the previous years in 2018 and 2019?
```TSQL
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
```
| calendar_year | before_sales | after_sales | sales_change_pct |
|---------------|--------------|-------------|------------------|
| 2018          | 2125140809   | 2129242914  | 0.19             |
| 2019          | 2249989796   | 2252326390  | 0.1              |
| 2020          | 2345878357   | 2318994169  | -1.15            |


Part 2: How do the sales metrics for 12 weeks before and after compared with the previous years in 2018 and 2019?
```TSQL
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
```
| calendar_year | before_sales | after_sales | sales_change_pct |
|---------------|--------------|-------------|------------------|
| 2018          | 6396562317   | 6500818510  | 1.63             |
| 2019          | 6883386397   | 6862646103  | -0.3             |
| 2020          | 7126273147   | 6973947753  | -2.14            |


---
My solution for **[D. Bonus Question](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution/D.%20Bonus%20Question.md)**.
