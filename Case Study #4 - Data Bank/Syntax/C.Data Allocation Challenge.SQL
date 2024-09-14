-------------------------------
--C. Data Allocation Challenge--
-------------------------------

--running customer balance column that includes the impact each transaction

with cte as (
select customer_id,txn_date,
sum(case when txn_type = 'deposit' then txn_amount else - txn_amount end) as amount
from data_bank.customer_transactions
group by customer_id, txn_date)
select customer_id, txn_date, 
sum(amount) over(partition by customer_id  order by txn_date rows between unbounded preceding and current row) as closing_balance
from cte
group by customer_id, txn_date, amount
order by customer_id, txn_date ;

****

--customer balance at the end of each month

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

--minimum, average and maximum values of the running balance for each customer

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
group by customer_id

***

--Option 1: data is allocated based off the amount of money at the end of the previous month

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

****

--Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days

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

*****

--Option 3: data is updated real-time

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
