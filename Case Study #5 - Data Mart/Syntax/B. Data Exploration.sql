-----------------------
--B. Data Exploration--
-----------------------

--1. What day of the week is used for each week_date value?

select distinct (datename(dw,week_date)) as week_day
from data_mart.clean_weekly_sales;


--2. What range of week numbers are missing from the dataset?

with allweeks as (
select 1 as current_value
union all
select current_value +1  from allweeks 
WHERE current_value+1 <= 52)
select current_value as week_number from allweeks
where current_value not in 
(select distinct week_number from data_mart.clean_weekly_sales);


--3. How many total transactions were there for each year in the dataset?

select calendar_year, sum(transactions) as no_of_transactions
from data_mart.clean_weekly_sales
group by calendar_year
order by calendar_year;


--4. What is the total sales for each region for each month?

select region, DATENAME(month, week_date) as month_name, sum(sales) as total_sales
from data_mart.clean_weekly_sales
group by region, month_number, DATENAME(month, week_date)
order by region, month_number;


--5. What is the total count of transactions for each platform

select platform, sum(transactions) as total_trxn_cnt
from data_mart.clean_weekly_sales
group by platform;


--6. What is the percentage of sales for Retail vs Shopify for each month?

with sales as (select calendar_year,month_number,  datename(month, week_date) as month_name,
sum(case when platform = 'Shopify' then sales end ) as shopify_sales,
sum(case when platform = 'Retail' then sales end ) as retail_sales,
sum(sales) as total_sales
from data_mart.clean_weekly_sales
group by  calendar_year, month_number, datename(month, week_date))
select calendar_year, month_name,
round(cast (100.0* retail_sales / total_sales as float),2) as retail_perc,
round(cast (100.0* shopify_sales / total_sales as float),2) as shopify_perc
from sales
order by calendar_year, month_number;


--7. What is the percentage of sales by demographic for each year in the dataset?

with sales as (select calendar_year,  
sum(case when demographic = 'Couples' then sales end ) as couples_sales,
sum(case when demographic = 'Families' then sales end ) as families_sales,
sum(case when demographic = 'unknown' then sales end ) as unknown_sales,
sum(sales) as total_sales
from data_mart.clean_weekly_sales
group by  calendar_year)
select calendar_year,
round(cast (100.0* couples_sales / total_sales as float),2) as couples_perc,
round(cast (100.0* families_sales / total_sales as float),2) as families_perc,
round(cast (100.0* unknown_sales / total_sales as float),2) as unknown_perc
from sales
order by calendar_year;


--8. Which age_band and demographic values contribute the most to Retail sales?

declare @retailsales bigint = (select sum(sales) from data_mart.clean_weekly_sales where platform = 'Retail')

select age_band, demographic,sum(sales) as sales,--@retailsales,
round(cast (100.0* sum(sales)/ @retailsales as float),2) as contributions
from data_mart.clean_weekly_sales
where platform = 'Retail'
group by age_band, demographic
order by contributions desc;


--9.Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

select calendar_year, platform,
round(avg(avg_transaction),0) as avg_transactions_row,
sum(sales)/sum(transactions) as avg_transactions_group
from data_mart.clean_weekly_sales
group by calendar_year, platform
order by calendar_year;
