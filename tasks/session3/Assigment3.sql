--1_List all products with list price greater than 1000
select * from production.products
where list_price >1000

--2_Get customers from "CA" or "NY" states
SELECT * FROM sales.customers
WHERE state in ('CA','NY')

--3_Retrieve all orders placed in 2023
select * from sales.orders
where year(order_date)=2023
--OR
select * from sales.orders
where order_date>='1-1-2023'
and
order_date<'1-1-2024'

--4_Show customers whose emails end with @gmail.com
SELECT * FROM sales.customers
WHERE email like '%@gmail.com'

--5_Show all inactive staff
SELECT * FROM sales.staffs
WHERE active!=1
--6_List top 5 most expensive products
SELECT TOP 6 * FROM production.products
ORDER BY list_price DESC

--7_Show latest 10 orders sorted by date
SELECT TOP 10 * FROM sales.orders
ORDER BY order_date DESC

--8_Retrieve the first 3 customers alphabetically by last name

SELECT TOP 3 CONCAT(FIRST_NAME,' ',LAST_NAME) AS FULL_NAME , last_name FROM SALES.customers
ORDER BY last_name

--9_Find customers who did not provide a phone number

SELECT CONCAT(FIRST_NAME,' ',LAST_NAME) AS FULL_NAME ,phone  FROM sales.customers
WHERE PHONE IS NULL


--10_Show all staff who have a manager assigned
SELECT * FROM sales.staffs
WHERE manager_id IS NOT NULL

--11_Count number of products in each category
SELECT category_id, COUNT(*) AS product_count
FROM production.products
GROUP BY category_id;

--12_Count number of customers in each state
SELECT state,count(*) as customer_number
from sales.customers
group by state


--13_Get average list price of products per brand
select brand_id,avg(list_price) as average_price from production.products
group by brand_id

--14_Show number of orders per staff
select staff_id , count(*) as order_count from sales.orders
group by staff_id

--15_Find customers who made more than 2 orders
select customer_id,count(*) as order_count from sales.orders
group by customer_id
having count(*)>2

--16_Products priced between 500 and 1500
select product_name ,list_price from production.products
where list_price between 500 and 1500

--17_Customers in cities starting with "S"
select customer_id ,city from sales.customers
where city like 's%'


--18_Orders with order_status either 2 or 4
select order_id , order_status from sales.orders
where order_status in (2,4)

--19_Products from category_id IN (1, 2, 3)
select product_name,category_id from production.products
where category_id in(1,2,3)


--20_Staff working in store_id = 1 OR without phone number
select staff_id ,store_id,phone from sales.staffs
where store_id = 1 or phone is null

