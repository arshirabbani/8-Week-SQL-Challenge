----------------------------
--B. Customer Transactions--
----------------------------

--1. What is the unique count and total amount for each transaction type?

select txn_type, count(*) as no_trxn, sum(txn_amount) as total_amnt 
from data_bank.customer_transactions
group by txn_type;


--2. What is the average total historical deposit counts and amounts for all customers?

with cte as (select customer_id, txn_type,
count(case when txn_type = 'deposit' then 1 else 0 end) as deposite_cnt,
sum(case when txn_type = 'deposit' then txn_amount else 0 end) as deposite_amount
from data_bank.customer_transactions group by customer_id, txn_type)
select txn_type, avg(deposite_cnt) as avg_dep_count, avg(deposite_amount) as avg_dep_amount
from cte where txn_type = 'deposit' 
group by txn_type;


--3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

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


--4. What is the closing balance for each customer at the end of the month?

--End date in the month of the max date of our dataset
DECLARE @maxDate DATE = (SELECT EOMONTH(MAX(txn_date)) FROM customer_transactions)

--CTE 1: Monthly transactions of each customer
WITH monthly_transactions AS (
  SELECT
    customer_id,
    EOMONTH(txn_date) AS end_date,
    SUM(CASE WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
             ELSE txn_amount END) AS transactions
  FROM customer_transactions
  GROUP BY customer_id, EOMONTH(txn_date)
),

--CTE 2: Increment last days of each month till they are equal to @maxDate 
recursive_dates AS (
  SELECT
    DISTINCT customer_id,
    CAST('2020-01-31' AS DATE) AS end_date
  FROM customer_transactions
  UNION ALL
  SELECT 
    customer_id,
    EOMONTH(DATEADD(MONTH, 1, end_date)) AS end_date
  FROM recursive_dates
  WHERE EOMONTH(DATEADD(MONTH, 1, end_date)) <= @maxDate
)

SELECT 
  r.customer_id,
  r.end_date,
  COALESCE(m.transactions, 0) AS transactions,
  SUM(m.transactions) OVER (PARTITION BY r.customer_id ORDER BY r.end_date 
      ROWS UNBOUNDED PRECEDING) AS closing_balance
FROM recursive_dates r
LEFT JOIN  monthly_transactions m
  ON r.customer_id = m.customer_id
  AND r.end_date = m.end_date;


--5. What is the percentage of customers who increase their closing balance by more than 5%?

--End date in the month of the max date of our dataset (Q4)
DECLARE @maxDate DATE = (SELECT EOMONTH(MAX(txn_date)) FROM customer_transactions)

--CTE 1: Monthly transactions of each customer (Q4)
WITH monthly_transactions AS (
  SELECT
    customer_id,
    EOMONTH(txn_date) AS end_date,
    SUM(CASE WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
             ELSE txn_amount END) AS transactions
  FROM customer_transactions
  GROUP BY customer_id, EOMONTH(txn_date)
),

--CTE 2: Increment last days of each month till they are equal to @maxDate (Q4)
recursive_dates AS (
  SELECT
    DISTINCT customer_id,
    CAST('2020-01-31' AS DATE) AS end_date
  FROM customer_transactions
  UNION ALL
  SELECT 
    customer_id,
    EOMONTH(DATEADD(MONTH, 1, end_date)) AS end_date
  FROM recursive_dates
  WHERE EOMONTH(DATEADD(MONTH, 1, end_date)) <= @maxDate
),

-- CTE 3: Closing balance of each customer by monthly (Q4)
customers_balance AS (
  SELECT 
    r.customer_id,
    r.end_date,
    COALESCE(m.transactions, 0) AS transactions,
    SUM(m.transactions) OVER (PARTITION BY r.customer_id ORDER BY r.end_date 
        ROWS UNBOUNDED PRECEDING) AS closing_balance
    FROM recursive_dates r
    LEFT JOIN  monthly_transactions m
      ON r.customer_id = m.customer_id
      AND r.end_date = m.end_date
),

--CTE 4: CTE 3 & next_balance
customers_next_balance AS (
  SELECT *,
    LEAD(closing_balance) OVER(PARTITION BY customer_id ORDER BY end_date) AS next_balance
  FROM customers_balance
),

--CTE 5: Calculate the increase percentage of closing balance for each customer
pct_increase AS (
  SELECT *,
    100.0*(next_balance-closing_balance)/closing_balance AS pct
  FROM customers_next_balance
  WHERE closing_balance ! = 0 AND next_balance IS NOT NULL
)

--Create a temporary table because of the error: Null value is eliminated by an aggregate or other SET operation
SELECT *
INTO #temp
FROM pct_increase;

--Calculate the percentage of customers whose closing balance increasing 5% compared to the previous month
SELECT CAST(100.0*COUNT(DISTINCT customer_id) AS FLOAT)
      / (SELECT COUNT(DISTINCT customer_id) FROM customer_transactions) AS pct_customers
FROM #temp
WHERE pct > 5;
