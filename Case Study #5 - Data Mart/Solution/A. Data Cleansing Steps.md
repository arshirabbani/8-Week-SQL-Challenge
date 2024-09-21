# 🛒 Case Study #5 - Data Mart
## A. Data Cleansing Steps


Columns	Actions to take
week_date             	Convert to DATE using CONVERT
week_number*	          Extract number of week using DATEPART
month_number*	          Extract month using DATEPART
calendar_year*	        Extract year using DATEPART
region	                No changes
platform	              No changes
segment	                No changes
customer_type	          No changes
age_band*	              Use CASE WHEN to categorize segment: '1' = Young Adults, '2' = Middle                  Aged, '3' or '4' = Retirees and null = unknown
demographic*	          Use CASE WHEN to categorize segment: 'C' = Couples, 'F' = Families and null                    unknown
transactions	          No changes
sales	                  CAST to bigint for further aggregations
avg_transaction*	      Divide sales by transactions and round up to 2 decimal places
                   

```TSQL
SELECT
  CONVERT(date, week_date, 3) AS week_date,
  DATEPART(week, CONVERT(date, week_date, 3)) as week_number,
  DATEPART(month, CONVERT(date, week_date, 3)) as month_number,
  DATEPART(year, CONVERT(date, week_date, 3))  as calendar_year,
  region, platform, segment, customer_type,
  case when RIGHT(segment,1) = '1' then 'Young Adults' 
	   when RIGHT(segment,1) = '2' then 'Middle Aged'
	   when RIGHT(segment,1) in ('3','4') then 'Retirees'
	   else 'unknown' end as age_band,
  case when LEFT(segment,1) = 'C' then 'Couples' 
	   when LEFT(segment,1) = 'F' then 'Families'
	   else 'unknown' end as demographic,
  transactions,
  cast (sales as bigint) as sales,
  round(cast(sales as float)/ transactions, 2)  as avg_transaction
  into data_mart.clean_weekly_sales
  FROM data_mart.weekly_sales;

  select * from data_mart.clean_weekly_sales;
```
The first 10 rows:
| week_date   | week_number | month_number | calendar_year | region   | platform | segment | customer_type | age_band     | demographic | transactions | sales   | avg_transaction |
|-------------|-------------|--------------|---------------|----------|----------|---------|---------------|--------------|-------------|--------------|---------|-----------------|
| 2020-08-31  | 36          | 8            | 2020          | ASIA     | Shopify  | F2      | New           | Middle Aged  | Families    | 245          | 35519   | 144.98          |
| 2020-08-31  | 36          | 8            | 2020          | OCEANIA  | Retail   | C3      | Existing      | Retirees     | Couples     | 339633       | 16520774| 48.64           |
| 2020-08-31  | 36          | 8            | 2020          | EUROPE   | Shopify  | C3      | Existing      | Retirees     | Couples     | 182          | 45036   | 247.45          |
| 2020-08-31  | 36          | 8            | 2020          | CANADA   | Shopify  | F3      | Existing      | Retirees     | Families    | 659          | 126801  | 192.41          |
| 2020-08-31  | 36          | 8            | 2020          | AFRICA   | Shopify  | C3      | New           | Retirees     | Couples     | 340          | 56734   | 166.86          |
| 2020-08-31  | 36          | 8            | 2020          | ASIA     | Retail   | C1      | Existing      | Young Adults | Couples     | 187781       | 6218547 | 33.12           |
| 2020-08-31  | 36          | 8            | 2020          | OCEANIA  | Shopify  | F2      | Existing      | Middle Aged  | Families    | 6870         | 1373529 | 199.93          |
| 2020-08-31  | 36          | 8            | 2020          | OCEANIA  | Retail   | C1      | New           | Young Adults | Couples     | 172521       | 3964262 | 22.98           |
| 2020-08-31  | 36          | 8            | 2020          | CANADA   | Shopify  | C2      | New           | Middle Aged  | Couples     | 105          | 14694   | 139.94          |
| 2020-08-31  | 36          | 8            | 2020          | CANADA   | Retail   | F3      | New           | Retirees     | Families    | 19524        | 690966  | 35.39           |


---
My solution for **[B. Data Exploration](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution/B.%20Data%20Exploration.md)**.
