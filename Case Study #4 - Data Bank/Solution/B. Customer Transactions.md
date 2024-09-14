# 📊 Case Study #4 - Data Bank
## B. Customer Transactions
### 1. What is the unique count and total amount for each transaction type?
```TSQL
select txn_type, count(*) as no_trxn, sum(txn_amount) as total_amnt 
from data_bank.customer_transactions
group by txn_type;
```
| txn_type   | unique_count | total_amount  |
|------------|--------------|---------------|
| withdrawal | 1580         | 793003        |
| deposit    | 2671         | 1359168       |
| purchase   | 1617         | 806537        |

---
### 2. What is the average total historical deposit counts and amounts for all customers?
```TSQL
with cte as (select customer_id, txn_type,
count(case when txn_type = 'deposit' then 1 else 0 end) as deposite_cnt,
sum(case when txn_type = 'deposit' then txn_amount else 0 end) as deposite_amount
from data_bank.customer_transactions group by customer_id, txn_type)
select txn_type, avg(deposite_cnt) as avg_dep_count, avg(deposite_amount) as avg_dep_amount
from cte where txn_type = 'deposit' 
group by txn_type;
```
| txn_type | avg_dep_count | avg_dep_amount |
|----------|---------------|----------------|
| deposit  | 5             | 2718           |


---
### 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
```TSQL
with cte as (
select customer_id,DATENAME(MONTH, txn_date) as month_name,
sum(case when txn_type = 'deposit' then 1 else 0 end) as deposit_cnt,
sum(case when txn_type = 'purchase' then 1 else 0 end) as purchase_cnt,
sum(case when txn_type = 'withdrawal' then 1 else 0 end) as withdrawal_cnt
from data_bank.customer_transactions 
group by customer_id, DATENAME(MONTH, txn_date))
select month_name, count(distinct customer_id) as cust_cnt from cte
where deposit_cnt > 1
and (purchase_cnt > 0 or withdrawal_cnt > 0)
group by month_name ;

```
| month_name | cust_cnt |
|------------|----------|
| April      | 70       |
| February   | 181      |
| January    | 168      |
| March      | 192      |


---
### 4. What is the closing balance for each customer at the end of the month?
Closing balance of at the end of this month = closing balance in the previous month + total transaction in this month. 


```TSQL
with cte as (
select customer_id,DATENAME(MONTH, txn_date) as month_name,
DATEPART(month, txn_date) as month_no,
sum(case when txn_type = 'deposit' then txn_amount else - txn_amount end) as amount
from data_bank.customer_transactions
group by customer_id, DATENAME(MONTH, txn_date), DATEPART(month, txn_date))
select customer_id, month_name, 
sum(amount) over(partition by customer_id order by month_no rows between unbounded preceding and current row) as closing_balance
from cte
group by customer_id, month_name, month_no, amount
order by customer_id, month_name;

```
A part of the result (2000 rows):

| customer_id | month_name | closing_balance |
|-------------|------------|-----------------|
| 1           | January    | 312             |
| 1           | March      | -640            |
| 2           | January    | 549             |
| 2           | March      | 610             |
| 3           | April      | -729            |
| 3           | February   | -821            |
| 3           | January    | 144             |
| 3           | March      | -1222           |
| 4           | January    | 848             |
| 4           | March      | 655             |
| 5           | April      | -2413           |


---
### 5. What is the percentage of customers who increase their closing balance by more than 5%?
  
```TSQL
with cte as (
select customer_id,DATENAME(MONTH, txn_date) as month_name,
DATEPART(month, txn_date) as month_no,
sum(case when txn_type = 'deposit' then txn_amount else - txn_amount end) as amount
from data_bank.customer_transactions
group by customer_id, DATENAME(MONTH, txn_date), DATEPART(month, txn_date))
, ClosingBalance  as 
(select customer_id,month_no, month_name,
sum(amount) over(partition by customer_id order by month_no rows between unbounded preceding and current row) as closing_balance
from cte
group by customer_id, month_name, month_no, amount ) 
, prev_bal as (
 select  customer_id,	month_name,	closing_balance,
   LAG(closing_balance) OVER(PARTITION BY customer_id ORDER BY	month_no) as prev_bal
   FROM ClosingBalance)
, perc_inc as 
(select customer_id,	month_name,	closing_balance, prev_bal
,100 *(closing_balance -prev_bal )/ NULLIF(prev_bal,0) as perc_inc
from prev_bal where prev_bal is not null)
select 100 * cast (count(distinct customer_id) as float) / (select count(distinct customer_id )  as pct_customers
from data_bank.customer_transactions) 
from perc_inc
where perc_inc > 5;

```
| pct_customers  |
|----------------|
| 75.6           |


My solution for **[C.Data Allocation Challenge](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234%20-%20Data%20Bank/Solution/C.%20Customer%20Transactions.md)**.
