---------------------
--D.Bonus Challenge--
---------------------

--Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.

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
