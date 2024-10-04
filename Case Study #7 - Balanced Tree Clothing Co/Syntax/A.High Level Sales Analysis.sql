--------------------------------
--A. High Level Sales Analysis--
--------------------------------

--1. What was the total quantity sold for all products?

select sum(qty) as quantity_sold from balanced_tree.sales;


--2. What is the total generated revenue for all products before discounts?

select sum(qty*price) as total_revenue from balanced_tree.sales;


--3. What was the total discount amount for all products?

select cast(sum(qty*price*discount/100.0) as float) as discounted_amount from balanced_tree.sales;
