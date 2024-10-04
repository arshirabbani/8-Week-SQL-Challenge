# 👕 Case Study #7 - Balanced Tree Clothing Co.
## C. Product Analysis
### 1. What are the top 3 products by total revenue before discount?
```TSQL
select top 3 product_name, sum(qty*s.price) as total_revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by product_name order by total_revenue desc;
```
| product_name                 | revenue_before_discount  |
|------------------------------|--------------------------|
| Blue Polo Shirt - Mens       | 217683                   |
| Grey Fashion Jacket - Womens | 209304                   |
| White Tee Shirt - Mens       | 152000                   |

---
### 2. What is the total quantity, revenue and discount for each segment?
```TSQL
select segment_name, 
sum(qty) as total_qty,
sum(qty*s.price) as total_revenue,
cast (sum(qty*s.price*discount/100.0) as decimal(10,2)) as total_discount
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by segment_name; 
```
| Segment Name | Total Qty | Total Revenue | Total Discount |
|--------------|-----------|---------------|----------------|
| Jacket       | 11,385    | 366,983       | 44,277.46      |
| Jeans        | 11,349    | 208,350       | 25,343.97      |
| Shirt        | 11,265    | 406,143       | 49,594.27      |
| Socks        | 11,217    | 307,977       | 37,013.44      |


---
### 3. What is the top selling product for each segment?
```TSQL
with top_selling_prod as (
select segment_name, product_name, sum(qty) as total_qty,
dense_rank() over(partition by segment_name order by sum(qty) desc) as rn
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by  segment_name, product_name )
select segment_name, product_name,total_qty
from top_selling_prod where rn =1 ;
```
| segment_name | product_name                  | total_qty       |
|--------------|-------------------------------|-----------------|
| Jacket       | Grey Fashion Jacket - Womens  | 3876            |
| Jeans        | Navy Oversized Jeans - Womens | 3856            |
| Shirt        | Blue Polo Shirt - Mens        | 3819            |
| Socks        | Navy Solid Socks - Mens       | 3792            |

---
### 4. What is the total quantity, revenue and discount for each category?
```TSQL
select category_name, 
sum(qty) as total_qty,
sum(qty*s.price) as total_revenue,
cast (sum(s.qty*s.price*s.discount/100.0) as decimal(10,2)) as total_discount
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by category_name ;
```
| category_name | total_qty      | total_revenue | total_discount  |
|---------------|----------------|---------------|-----------------|
| Mens          | 22482          | 714120        | 86607.71        |
| Womens        | 22734          | 575333        | 69621.43        |

---
### 5. What is the top selling product for each category?
```TSQL
with top_selling_prod as (
select category_name, product_name, sum(qty) as total_qty,
dense_rank() over(partition by category_name order by sum(qty) desc) as rn
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by  category_name, product_name )
select category_name, product_name,total_qty
from top_selling_prod where rn =1 ;
```
| category_name | product_name                 | total_qty       |
|---------------|------------------------------|-----------------|
| Mens          | Blue Polo Shirt - Mens       | 3819            |
| Womens        | Grey Fashion Jacket - Womens | 3876            |

---
### 6. What is the percentage split of revenue by product for each segment?
```TSQL
with prod_revenue as (
select segment_name, product_name, sum(qty*s.price) as prod_revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by  segment_name, product_name )
select segment_name, product_name,
cast(100.0* prod_revenue/sum(prod_revenue)over(partition by segment_name) as decimal(10,2)) segment_prod_pct
from prod_revenue; 
```
| segment_name | product_name                     | segment_prod_pct     |
|--------------|----------------------------------|----------------------|
| Jacket       | Grey Fashion Jacket - Womens     | 57.03                |
| Jacket       | Indigo Rain Jacket - Womens      | 19.45                |
| Jacket       | Khaki Suit Jacket - Womens       | 23.51                |
| Jeans        | Black Straight Jeans - Womens    | 58.15                |
| Jeans        | Cream Relaxed Jeans - Womens     | 17.79                |
| Jeans        | Navy Oversized Jeans - Womens    | 24.06                |
| Shirt        | Blue Polo Shirt - Mens           | 53.60                |
| Shirt        | Teal Button Up Shirt - Mens      | 8.98                 |
| Shirt        | White Tee Shirt - Mens           | 37.43                |
| Socks        | Navy Solid Socks - Mens          | 44.33                |
| Socks        | Pink Fluro Polkadot Socks - Mens | 35.50                |
| Socks        | White Striped Socks - Mens       | 20.18                |

---
### 7. What is the percentage split of revenue by segment for each category?
```TSQL
with segment_revenue as (
select category_name, segment_name, sum(qty*s.price) as segment_revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by  category_name, segment_name )
select category_name, segment_name,
cast(100.0* segment_revenue/sum(segment_revenue)over(partition by category_name) as decimal(10,2)) category_segment_pct
from segment_revenue; 
```
| category_name | segment_name | category_segment_pct |
|---------------|--------------|----------------------|
| Mens          | Shirt        | 56.87                |
| Mens          | Socks        | 43.13                |
| Womens        | Jacket       | 63.79                |
| Womens        | Jeans        | 36.21                |


---
### 8. What is the percentage split of total revenue by category?
```TSQL
with total_revenue as (
select category_name,  sum(qty*s.price) as total_revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by  category_name )
select category_name,
cast(100.0* total_revenue/sum(total_revenue)over() as decimal(10,2)) category_revenue_pct
from total_revenue; 
```
| category_name | category_revenue_pct |
|---------------|----------------------|
| Mens          | 55.38                |
| Womens        | 44.62                |

---
### 9. What is the total transaction “penetration” for each product? 
(hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
```TSQL
with txn_details as (
select product_name, count(distinct txn_id) as product_txn,
(select count(distinct txn_id) from balanced_tree.sales) as total_txn
from balanced_tree.sales s
inner join balanced_tree.product_details pd on pd.product_id = s.prod_id
group by  product_name )
select *, 
cast(100.0* product_txn/total_txn as decimal(10,2)) total_txn_penetration
from txn_details; 
```
| product_name                        | product_txn | total_txn | total_txn_penetration |
|-------------------------------------|-------------|-----------|-----------------------|
| White Tee Shirt - Mens              | 1268        | 2500      | 50.72                 |
| Blue Polo Shirt - Mens              | 1268        | 2500      | 50.72                 |
| Black Straight Jeans - Womens       | 1246        | 2500      | 49.84                 |
| Pink Fluro Polkadot Socks - Mens    | 1258        | 2500      | 50.32                 |
| White Striped Socks - Mens          | 1243        | 2500      | 49.72                 |
| Teal Button Up Shirt - Mens         | 1242        | 2500      | 49.68                 |
| Grey Fashion Jacket - Womens        | 1275        | 2500      | 51.00                 |
| Khaki Suit Jacket - Womens          | 1247        | 2500      | 49.88                 |
| Navy Oversized Jeans - Womens       | 1274        | 2500      | 50.96                 |
| Navy Solid Socks - Mens             | 1281        | 2500      | 51.24                 |
| Indigo Rain Jacket - Womens         | 1250        | 2500      | 50.00                 |
| Cream Relaxed Jeans - Womens        | 1243        | 2500      | 49.72                 |


---
### 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
```TSQL

--count the number of products in each transaction
with products_per_transaction as (
  select  s.txn_id,  pd.product_id,  pd.product_name,  s.qty,  count(pd.product_id) over (partition by txn_id) as cnt
  from balanced_tree.sales s
  join balanced_tree.product_details pd  on s.prod_id = pd.product_id ),

--filter transactions that have the 3 products and group them to a cell
combinations as (
  select    string_agg(product_id, ', ') as products_id,
    string_agg(product_name, ', ') as products_name
  from products_per_transaction
  where cnt = 3  group by txn_id ),

--count the number of times each combination appears
combination_count as (
  select   products_id,   products_name,  count (*) as common_combinations
  from combinations
  group by products_id, products_name )

--filter the most common combinations
select    products_id,   products_name
from combination_count
where common_combinations = (select max(common_combinations)   from combination_count);

```
| products_id                       | products_name                                                   |
|-----------------------------------|----------------------------------------------------------------|
| c4a632, e83aa3, c8d436           | Navy Oversized Jeans - Womens, Black Straight Jeans - Womens, Teal Button Up Shirt - Mens |
| c4a632, e83aa3, 5d267b           | Navy Oversized Jeans - Womens, Black Straight Jeans - Womens, White Tee Shirt - Mens |
| c4a632, 2a2353, 2feb6b           | Navy Oversized Jeans - Womens, Blue Polo Shirt - Mens, Pink Fluro Polkadot Socks - Mens |
| c4a632, e31d39, 5d267b           | Navy Oversized Jeans - Womens, Cream Relaxed Jeans - Womens, White Tee Shirt - Mens |
| c4a632, d5e9a6, b9a74d           | Navy Oversized Jeans - Womens, Khaki Suit Jacket - Womens, White Striped Socks - Mens |

---
My solution for **[D. Bonus Question](https://github.com/arshirabbani/8-Week-SQL-Challenge/blob/main/Case%20Study%20%237%20-%20Balanced%20Tree%20Clothing%20Co/Solution/D.%20Bonus%20Question.md)**.
