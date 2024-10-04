# 👕 Case Study #7 - Balanced Tree Clothing Co.
## A. High Level Sales Analysis
### 1. What was the total quantity sold for all products?
```TSQL
select sum(qty) as quantity_sold from balanced_tree.sales;
```
| quantity_sold   |
|-----------------|
| 45216           |

---
### 2. What is the total generated revenue for all products before discounts?
```TSQL
select sum(qty*price) as total_revenue from balanced_tree.sales;
```
| total_revenue  |
|------------ ---|
| 1289453        |

---
### 3. What was the total discount amount for all products?
```TSQL
select cast(sum(qty*price*discount/100.0) as float) as discounted_amount from balanced_tree.sales;
```
| total_discount  |
|-----------------|
| 156229.14       |

---
My solution for **[B. Transaction Analysis](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%237%20-%20Balanced%20Tree%20Clothing%20Co./Solution/B.%20Transaction%20Analysis.md)**.
