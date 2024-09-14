# 📊 Case Study #4 - Data Bank
## A. Customer Nodes Exploration
### 1. How many unique nodes are there on the Data Bank system?
```TSQL
select count (distinct node_id) as nodes_cnt from data_bank.customer_nodes;
```
| nodes_cnt     |
|---------------|
| 5             |

---
### 2. What is the number of nodes per region?
```TSQL
select cn.region_id,region_name,  count ( node_id) as nodes
from data_bank.customer_nodes cn
inner join data_bank.regions r on cn.region_id = r.region_id
group by cn.region_id,region_name
order by cn.region_id;
```
| region_id | region_name | nodes  |
|-----------|-------------|--------|
| 1         | Australia   | 770    |
| 2         | America     | 735    |
| 3         | Africa      | 714    |
| 4         | Asia        | 665    |
| 5         | Europe      | 616    |

---
### 3. How many customers are allocated to each region?
```TSQL
select cn.region_id,region_name,  count (distinct customer_id) as no_of_cust
from data_bank.customer_nodes cn
inner join data_bank.regions r on cn.region_id = r.region_id
group by cn.region_id,region_name
order by cn.region_id;
```
| region_id | region_name | customers  |
|-----------|-------------|------------|
| 1         | Australia   | 110        |
| 2         | America     | 105        |
| 3         | Africa      | 102        |
| 4         | Asia        | 95         |
| 5         | Europe      | 88         |

---
### 4. How many days on average are customers reallocated to a different node?
  * Create a CTE ```customerDates``` containing the first date of every customer in each node
  * Create a CTE ```reallocation``` to calculate the difference in days between the first date in this node and the first date in next node
  * Take the average of those day differences
```TSQL
select  avg(DATEDIFF(day, start_date, end_date)) as avg_days
from data_bank.customer_nodes cn where  end_date != '9999-12-31';
```
| avg_days  |
|-----------|
| 14        |

On average, it takes 14 days for a customer to reallocate to a different node.

---
### 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
Using 2 CTEs in the previous questions ```customerDates``` and ```reallocation``` to calculate the median, 80th and 95th percentile for reallocation days in each region.
```TSQL
with r_days as (
select c.region_id,r.region_name, datediff(day,start_date, end_date) AS reallocation_days
from data_bank.customer_nodes AS c
inner join data_bank.regions AS r on c.region_id = r.region_id 
where end_date != '9999-12-31')
select distinct region_id, region_name,
PERCENTILE_CONT(0.5) within group (order by reallocation_days) over (partition by region_name) as median,
PERCENTILE_CONT(0.8) within group (order by reallocation_days) over (partition by region_name) as perc_80,
PERCENTILE_CONT(0.95) within group (order by reallocation_days) over (partition by region_name) as perc_95
from r_days;
```
| region_id | region_name | median | perc_80 | perc_95 |
|-----------|-------------|--------|---------|---------|
| 1         | Australia   | 15     | 23      | 28      |
| 2         | America     | 15     | 23      | 28      |
| 3         | Africa      | 15     | 24      | 28      |
| 4         | Asia        | 15     | 23      | 28      |
| 5         | Europe      | 15     | 24      | 28      |


---
My solution for **[B. Customer Transactions](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234%20-%20Data%20Bank/Solution/B.%20Customer%20Transactions.md)**.
