# 📊 Case Study #4 - Data Bank
## C.Data Allocation Challenge
### running customer balance column that includes the impact each transaction
```TSQL
with cte as (
select customer_id,txn_date,
sum(case when txn_type = 'deposit' then txn_amount else - txn_amount end) as amount
from data_bank.customer_transactions
group by customer_id, txn_date)
select customer_id, txn_date, 
sum(amount) over(partition by customer_id  order by txn_date rows between unbounded preceding and current row) as closing_balance
from cte
group by customer_id, txn_date, amount
order by customer_id, txn_date;
```
| customer_id | txn_date   | closing_balance |
|-------------|------------|-----------------|
| 1           | 2020-01-02 | 312             |
| 1           | 2020-03-05 | -300            |
| 1           | 2020-03-17 | 24              |
| 1           | 2020-03-19 | -640            |
| 2           | 2020-01-03 | 549             |
| 2           | 2020-03-24 | 610             |
| 3           | 2020-01-27 | 144             |
| 3           | 2020-02-22 | -821            |
| 3           | 2020-03-05 | -1034           |
| 3           | 2020-03-19 | -1222           |


---
### customer balance at the end of each month
```TSQL
with cte as (
select customer_id,DATENAME(MONTH, txn_date) as month_name,
DATEPART(month, txn_date) as month_no,
sum(case when txn_type = 'deposit' then txn_amount else - txn_amount end) as amount
from data_bank.customer_transactions
group by customer_id, DATENAME(MONTH, txn_date), DATEPART(month, txn_date))
select customer_id, month_name, 
sum(amount) over(partition by customer_id, month_no  order by month_no rows between unbounded preceding and current row) as closing_balance
from cte
group by customer_id, month_name, month_no, amount
order by customer_id, month_name ;
```
| customer_id | month_name | closing_balance |
|-------------|------------|-----------------|
| 1           | January    | 312             |
| 1           | March      | -952            |
| 2           | January    | 549             |
| 2           | March      | 61              |
| 3           | April      | 493             |
| 3           | February   | -965            |
| 3           | January    | 144             |
| 3           | March      | -401            |
| 4           | January    | 848             |
| 4           | March      | -193            |



---
### minimum, average and maximum values of the running balance for each customer
```TSQL
with cte as (
select customer_id,txn_date,
sum(case when txn_type = 'deposit' then txn_amount else - txn_amount end) 
over(partition by customer_id  order by txn_date rows between unbounded preceding and current row) as running_blnc
from data_bank.customer_transactions)
select customer_id,  
   MIN(running_blnc) AS min_running_total,
   AVG(cast(running_blnc as float)) AS avg_running_total,
   MAX(running_blnc) AS max_running_total
from cte
group by customer_id;

```
| customer_id | min_running_total | avg_running_total | max_running_total |
|-------------|--------------------|--------------------|--------------------|
| 1           | -640               | -151               | 312                |
| 2           | 549                | 579.5              | 610                |
| 3           | -1222              | -732.4             | 144                |
| 4           | 458                | 653.67             | 848                |
| 5           | -2413              | -172.91            | 1780               |
| 6           | -552               | 619                | 2197               |
| 7           | 887                | 2268.69            | 3539               |
| 8           | -1029              | 173.7              | 1363               |
| 9           | -91                | 1021.7             | 2030               |
| 10          | -5090              | -2141.61           | 556                |



---
### Option 1: data is allocated based off the amount of money at the end of the previous month
Closing balance of at the end of this month = closing balance in the previous month + total transaction in this month. 


```TSQL
with amountcte as (
select customer_id, datepart(month,txn_date) as month_no,
(case when txn_type = 'deposit' then txn_amount else -txn_amount end) as amount
from data_bank.customer_transactions),
running_sum as (
select *, sum(amount) over (partition by customer_id, month_no 
order by customer_id, month_no rows between unbounded preceding and current row) as running_sum
from amountcte)
, allocat as (select *, lag(running_sum,1) over(partition by customer_id order by customer_id, month_no) as allocat
from running_sum)
select month_no, 
 sum(case when allocat  < 0 then 0 else allocat end) as total_allocation
from allocat group by month_no order by month_no;
```

| month_no | total_allocation |
|----------|------------------|
| 1        | 387409           |
| 2        | 532481           |
| 3        | 510380           |
| 4        | 218140           |

---
### Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
  
```TSQL
with amountcte as (
select customer_id, datepart(month,txn_date) as month_no,
sum(CASE WHEN txn_type = 'deposit' then txn_amount else  -txn_amount END) as amount
from data_bank.customer_transactions group by customer_id, datepart(month,txn_date)),
running_sum as (
select *, sum(amount) over (partition by customer_id 
order by  month_no rows between unbounded preceding and current row) as running_sum
from amountcte)
, avg_blnc as 
(select customer_id, month_no, avg(running_sum) over(partition by customer_id ) as avg_blnc
from running_sum group by customer_id, month_no, running_sum)
select month_no, 
 sum(case when avg_blnc  < 0 then 0 else avg_blnc end) as data_needed_per_month
from avg_blnc group by month_no order by month_no;

```
| month_no | data_needed_per_month |
|----------|------------------------|
| 1        | 218111                 |
| 2        | 196340                 |
| 3        | 201303                 |
| 4        | 124920                 |

### Option 3: data is updated real-time
  
```TSQL
with amountcte as (
select customer_id, datepart(month,txn_date) as month_no,
sum(CASE WHEN txn_type = 'deposit' then txn_amount else  -txn_amount END) as amount
from data_bank.customer_transactions group by customer_id, datepart(month,txn_date)),
running_sum as (
select *, sum(amount) over (partition by customer_id 
order by  month_no rows between unbounded preceding and current row) as running_sum
from amountcte)
select  month_no, sum(case when running_sum < 0 then 0 else  running_sum end) as data_required
from running_sum 
group by  month_no order by month_no;

```
| month_no | data_required |
|----------|---------------|
| 1        | 235595        |
| 2        | 238492        |
| 3        | 240065        |
| 4        | 157033        |



