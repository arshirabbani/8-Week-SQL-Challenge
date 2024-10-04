# 👕 Case Study #7 - Balanced Tree Clothing Co.
## D. Bonus Question
Use a single SQL query to transform the `product_hierarchy` and `product_prices` datasets to the `product_details` table.

### Solution

```TSQL
select 
pp.product_id,pp.price,
concat(ph1.level_text,' ', ph2.level_text,' - ',ph3.level_text) as product_name,
ph3.id as category_id,
ph2.id as segment_id,
ph1.id as style_id,
ph3.level_text as category,
ph2.level_text as segment,
ph1.level_text as style
from balanced_tree.product_hierarchy ph1 --style
inner join balanced_tree.product_hierarchy ph2 on ph1.parent_id = ph2.id--segment
inner join balanced_tree.product_hierarchy ph3 on ph2.parent_id = ph3.id --category
inner join balanced_tree.product_prices pp on ph1.id = pp.id
```
| product_id | price | product_name                       | category_id | segment_id | style_id | category | segment | style                  |
|------------|-------|------------------------------------|-------------|------------|----------|----------|---------|------------------------|
| c4a632     | 13    | Navy Oversized Jeans - Womens      | 1           | 3          | 7        | Womens   | Jeans   | Navy Oversized         |
| e83aa3     | 32    | Black Straight Jeans - Womens      | 1           | 3          | 8        | Womens   | Jeans   | Black Straight         |
| e31d39     | 10    | Cream Relaxed Jeans - Womens       | 1           | 3          | 9        | Womens   | Jeans   | Cream Relaxed          |
| d5e9a6     | 23    | Khaki Suit Jacket - Womens         | 1           | 4          | 10       | Womens   | Jacket  | Khaki Suit             |
| 72f5d4     | 19    | Indigo Rain Jacket - Womens        | 1           | 4          | 11       | Womens   | Jacket  | Indigo Rain            |
| 9ec847     | 54    | Grey Fashion Jacket - Womens       | 1           | 4          | 12       | Womens   | Jacket  | Grey Fashion           |
| 5d267b     | 40    | White Tee Shirt - Mens             | 2           | 5          | 13       | Mens     | Shirt   | White Tee              |
| c8d436     | 10    | Teal Button Up Shirt - Mens        | 2           | 5          | 14       | Mens     | Shirt   | Teal Button Up         |
| 2a2353     | 57    | Blue Polo Shirt - Mens             | 2           | 5          | 15       | Mens     | Shirt   | Blue Polo              |
| f084eb     | 36    | Navy Solid Socks - Mens            | 2           | 6          | 16       | Mens     | Socks   | Navy Solid             |
| b9a74d     | 17    | White Striped Socks - Mens         | 2           | 6          | 17       | Mens     | Socks   | White Striped          |
| 2feb6b     | 29    | Pink Fluro Polkadot Socks - Mens   | 2           | 6          | 18       | Mens     | Socks   | Pink Fluro Polkadot    |

