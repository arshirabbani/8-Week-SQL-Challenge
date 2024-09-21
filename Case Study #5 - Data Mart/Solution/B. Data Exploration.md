# 🛒 Case Study #5 - Data Mart
## B. Data Exploration

### 1. What day of the week is used for each week_date value?
```TSQL
select distinct (datename(dw,week_date)) as week_day
from data_mart.clean_weekly_sales;
```
| week_day         |
|------------------|
| Monday           |

---
### 2. What range of week numbers are missing from the dataset?

```TSQL
with allweeks as (
select 1 as current_value
union all
select current_value +1  from allweeks 
WHERE current_value+1 <= 52)
select current_value as week_number from allweeks
where current_value not in 
(select distinct week_number from data_mart.clean_weekly_sales);
```
28 rows in total. 
| week_number |
|-------------|
| 1           |
| 2           |
| 3           |
| 4           |
| 5           |
| 6           |
| 7           |
| 8           |
| 9           |
| 10          |
| 11          |
| 12          |
| 37          |
| 38          |
| 39          |
| 40          |
| 41          |
| 42          |
| 43          |
| 44          |
| 45          |
| 46          |
| 47          |
| 48          |
| 49          |
| 50          |
| 51          |
| 52          |


Week 1-12 and week 37-52 are missing from the dataset.

---
### 3. How many total transactions were there for each year in the dataset?
```TSQL
select calendar_year, sum(transactions) as no_of_transactions
from data_mart.clean_weekly_sales
group by calendar_year
order by calendar_year;
```
| calendar_year | no_of_transactions  |
|---------------|---------------------|
| 2018          | 346406460           |
| 2019          | 365639285           |
| 2020          | 375813651           |

---
### 4. What is the total sales for each region for each month?
```TSQL
select region, DATENAME(month, week_date) as month_name, sum(sales) as total_sales
from data_mart.clean_weekly_sales
group by region, month_number, DATENAME(month, week_date)
order by region, month_number;
```
49 rows in total. The first 10 rows:
| region | month_name | total_sales  |
|--------|------------|--------------|
| AFRICA | March      | 567767480    |
| AFRICA | April      | 1911783504   |
| AFRICA | May        | 1647244738   |
| AFRICA | June       | 1767559760   |
| AFRICA | July       | 1960219710   |
| AFRICA | August     | 1809596890   |
| AFRICA | September  | 276320987    |
| ASIA   | March      | 529770793    |
| ASIA   | April      | 1804628707   |
| ASIA   | May        | 1526285399   |


---
### 5. What is the total count of transactions for each platform?
```TSQL
select platform, sum(transactions) as total_trxn_cnt
from data_mart.clean_weekly_sales
group by platform;
```
| platform | total_trxn_cnt |
|----------|----------------|
| Retail   | 1081934227     |
| Shopify  | 5925169        |


---
### 6. What is the percentage of sales for Retail vs Shopify for each month?
```TSQL
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
```
| calendar_year | month_name | retail_perc | shopify_perc |
|---------------|------------|-------------|--------------|
| 2018          | March      | 97.92       | 2.08         |
| 2018          | April      | 97.93       | 2.07         |
| 2018          | May        | 97.73       | 2.27         |
| 2018          | June       | 97.76       | 2.24         |
| 2018          | July       | 97.75       | 2.25         |
| 2018          | August     | 97.71       | 2.29         |
| 2018          | September  | 97.68       | 2.32         |
| 2019          | March      | 97.71       | 2.29         |
| 2019          | April      | 97.80       | 2.20         |
| 2019          | May        | 97.52       | 2.48         |
| 2019          | June       | 97.42       | 2.58         |
| 2019          | July       | 97.35       | 2.65         |
| 2019          | August     | 97.21       | 2.79         |
| 2019          | September  | 97.09       | 2.91         |
| 2020          | March      | 97.30       | 2.70         |
| 2020          | April      | 96.96       | 3.04         |
| 2020          | May        | 96.71       | 3.29         |
| 2020          | June       | 96.80       | 3.20         |
| 2020          | July       | 96.67       | 3.33         |
| 2020          | August     | 96.51       | 3.49         |


---
### 7. What is the percentage of sales by demographic for each year in the dataset?
```TSQL
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
```
| calendar_year | pct_families | pct_couples | pct_unknown  |
|---------------|--------------|-------------|--------------|
| 2018          | 31.99        | 26.38       | 41.63        |
| 2019          | 32.47        | 27.28       | 40.25        |
| 2020          | 32.73        | 28.72       | 38.55        |

---
### 8. Which age_band and demographic values contribute the most to Retail sales?
```TSQL
declare @retailsales bigint = (select sum(sales) from data_mart.clean_weekly_sales where platform = 'Retail')

select age_band, demographic,sum(sales) as sales,--@retailsales,
round(cast (100.0* sum(sales)/ @retailsales as float),2) as contributions
from data_mart.clean_weekly_sales
where platform = 'Retail'
group by age_band, demographic
order by contributions desc;
```
| age_band      | demographic | sales         | contributions |
|---------------|-------------|---------------|---------------|
| unknown       | unknown     | 16067285533   | 40.52         |
| Retirees      | Families    | 6634686916    | 16.73         |
| Retirees      | Couples     | 6370580014    | 16.07         |
| Middle Aged   | Families    | 4354091554    | 10.98         |
| Young Adults  | Couples     | 2602922797    | 6.56          |
| Middle Aged   | Couples     | 1854160330    | 4.68          |
| Young Adults  | Families    | 1770889293    | 4.47          |


The highest retail sales are contributed by *unknown* ```age_band``` and ```demographic``` at 40.52% followed by *retired families* at 16.73% and *retired couples* at 16.07%.

---
### 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
```TSQL
select calendar_year, platform,
round(avg(avg_transaction),0) as avg_transactions_row,
sum(sales)/sum(transactions) as avg_transactions_group
from data_mart.clean_weekly_sales
group by calendar_year, platform
order by calendar_year;
```
| calendar_year | platform | avg_transactions_row | avg_transactions_group |
|---------------|----------|----------------------|------------------------|
| 2018          | Retail   | 43                   | 36                     |
| 2018          | Shopify  | 188                  | 192                    |
| 2019          | Retail   | 42                   | 36                     |
| 2019          | Shopify  | 178                  | 183                    |
| 2020          | Shopify  | 175                  | 179                    |
| 2020          | Retail   | 41                   | 36                     |


What's the difference between ```avg_transaction_row``` and ```avg_transaction_group```?
* ```avg_transaction_row``` is the average transaction of each individual row in the dataset 
* ```avg_transaction_group``` is the average transaction of each ```platform``` in each ```calendar_year```

The average transaction size for each year by platform is actually ```avg_transaction_group```.

---
My solution for **[C. Before & After Analysis](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution/C.%20Before%20%26%20After%20Analysis.md)**.
