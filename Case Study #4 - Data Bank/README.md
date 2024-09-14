# 📊 Case Study #4 - Data Bank
<p align="center">
<img src="https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/IMG/4.png" align="center" width="400" height="400" >

## 📕 Table of Contents
* [Bussiness Task](https://github.com/arshirabbani/8-Week-SQL-Challenge/tree/main/Case%20Study%20%234%20-%20Data%20Bank#%EF%B8%8F-bussiness-task)
* [Entity Relationship Diagram](https://github.com/arshirabbani/8-Week-SQL-Challenge/tree/main/Case%20Study%20%234%20-%20Data%20Bank#-entity-relationship-diagram)
* [Case Study Questions](https://github.com/arshirabbani/8-Week-SQL-Challenge/tree/main/Case%20Study%20%234%20-%20Data%20Bank#-case-study-questions)
* [My Solution](https://github.com/arshirabbani/8-Week-SQL-Challenge/tree/main/Case%20Study%20%234%20-%20Data%20Bank#-my-solution)

---
## 🛠️ Bussiness Task
Danny launched a new initiative, Data Bank which runs banking activities and also acts as the world’s most secure distributed data storage platform!
Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts.

The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.
This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!

---
## 🔐 Entity Relationship Diagram
<p align="center">
<img src="https://raw.githubusercontent.com/arshirabbani/8-Week-SQL-Challenge/main/IMG/e4.png" align="center">

---
## ❓ Case Study Questions
### A. Customer Nodes Exploration
View my solution [HERE](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234%20-%20Data%20Bank/Solution/A.%20Customer%20Nodes%20Exploration.md).

1. How many unique nodes are there on the Data Bank system?
2. What is the number of nodes per region?
3. How many customers are allocated to each region?
4. How many days on average are customers reallocated to a different node?
5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

---
### B. Customer Transactions
View my solution [HERE](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234%20-%20Data%20Bank/Solution/B.%20Customer%20Transactions.md).

1. What is the unique count and total amount for each transaction type?
2. What is the average total historical deposit counts and amounts for all customers?
3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
4. What is the closing balance for each customer at the end of the month?
5. What is the percentage of customers who increase their closing balance by more than 5%?

---

### C. Data Allocation Challenge
View my solution [HERE](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234%20-%20Data%20Bank/Solution/A.%20Customer%20Nodes%20Exploration.md).

To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:

Option 1: data is allocated based off the amount of money at the end of the previous month
Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
Option 3: data is updated real-time
For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:

running customer balance column that includes the impact each transaction
customer balance at the end of each month
minimum, average and maximum values of the running balance for each customer
Using all of the data available - how much data would have been required for each option on a monthly basis?

---
## 🚀 My Solution
  * View the complete syntax [HERE](https://github.com/arshirabbani/8-Week-SQL-Challenge/tree/main/Case%20Study%20%234%20-%20Data%20Bank/Syntax).
  * View the result and explanation [HERE](https://github.com/arshirabbani/8-Week-SQL-Challenge/tree/main/Case%20Study%20%234%20-%20Data%20Bank/Solution).
