---------------------------
--A. Data Cleansing Steps--
---------------------------

/*
Columns	Actions to take
week_date	Convert to DATE using CONVERT
week_number*	Extract number of week using DATEPART
month_number*	Extract month using DATEPART
calendar_year*	Extract year using DATEPART
region	No changes
platform	No changes
segment	No changes
customer_type	No changes
age_band*	Use CASE WHEN to categorize segment: '1' = Young Adults, '2' = Middle Aged, '3' or '4' = Retirees and null = unknown
demographic*	Use CASE WHEN to categorize segment: 'C' = Couples, 'F' = Families and null = unknown
transactions	No changes
sales	CAST to bigint for further aggregations
avg_transaction*	Divide sales by transactions and round up to 2 decimal places

*/


SELECT
  CONVERT(date, week_date, 3) AS week_date,
  DATEPART(week, CONVERT(date, week_date, 3)) as week_number,
  DATEPART(month, CONVERT(date, week_date, 3)) as month_number,
  DATEPART(year, CONVERT(date, week_date, 3))  as calendar_year,
  region, platform, segment, customer_type,
  case when RIGHT(segment,1) = '1' then 'Young Adults' 
	   when RIGHT(segment,1) = '2' then 'Middle Aged'
	   when RIGHT(segment,1) in ('3','4') then 'Retirees'a
	   else 'unknown' end as age_band,
  case when LEFT(segment,1) = 'C' then 'Couples' 
	   when LEFT(segment,1) = 'F' then 'Families'
	   else 'unknown' end as demographic,
  transactions,
  cast (sales as bigint) as sales,
  round(cast(sales as float)/ transactions, 2)  as avg_transaction
  into data_mart.clean_weekly_sales
  FROM data_mart.weekly_sales;

  select * from data_mart.clean_weekly_sales
