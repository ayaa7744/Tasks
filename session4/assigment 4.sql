--1. Count the total number of products in the database.
SELECT COUNT(product_id) AS TOTAL_PRODUCTS
FROM production.products;

--2. Find the average, minimum, and maximum price of all products.
select avg(list_price) as avg_price,min(list_price) as min_price,max(list_price) as max_price
from production.products

--3. Count how many products are in each category.
select count(product_id) as total_product, category_name 
from production.products p
join production.categories c  on p.category_id=c.category_id
group by category_name

--4. Find the total number of orders for each store.
select count(order_id) as total_order ,store_name
from sales.orders o
join sales.stores s on o.store_id=s.store_id
group by store_name

--5. Show customer first names in UPPERCASE and last names in lowercase for the first 10 customers.
select top 10 upper(first_name) +' ' + lower(last_name) as full_name
from sales.customers

--6. Get the length of each product name. Show product name and its length for the first 10 products.
select top 10 product_name ,len(product_name) as product_length
from production.products

--7. Format customer phone numbers to show only the area code (first 3 digits) for customers 1-15.
select top 15 phone, left(phone,3) as formated_number
from sales.customers

--8. Show the current date and extract the year and month from order dates for orders 1-10.
select top 10
getdate(),year(order_date) as years ,MONTH(order_date) as months
from sales.orders


--9. Join products with their categories. Show product name and category name for first 10 products.
select top 10 product_name,category_name
from production.products p
join production.categories c on p.category_id=c.category_id


--10. Join customers with their orders. Show customer name and order date for first 10 orders.
select top 10 first_name + ' '+last_name as customer_name,order_date
from sales.customers c
join sales.orders o on c.customer_id=o.customer_id

--11. Show all products with their brand names, even if some products don't have brands. Include product name, brand name (show 'No Brand' if null).
select product_name, COALESCE(brand_name,'No Brand') as brand_name
from production.products p
left join production.brands b on p.brand_id=b.brand_id


--12. Find products that cost more than the average product price. Show product name and price.
select product_name , list_price
from production.products
where  list_price > 
(select avg(list_price) from production.products)

--13. Find customers who have placed at least one order. Use a subquery with IN. Show customer_id and customer_name.
select customer_id,first_name + ' '+last_name as customer_name
from sales.customers
where customer_id in
(select customer_id from sales.orders )



--14. For each customer, show their name and total number of orders using a subquery in the SELECT clause.
select first_name + ' '+last_name as customer_name,
(select count(order_id) from sales.orders o where o.customer_id=c.customer_id)as total_orders
from sales.customers c


--15. Create a simple view called easy_product_list that shows product name, category name, and price. 
--Then write a query to select all products from this view where price > 100.

create view easy_product_list As select
product_name , category_name,list_price
from production.products p
join production.categories c on p.category_id=c.category_id

select * from easy_product_list where list_price >100


--16. Create a view called customer_info that shows customer ID, full name (first + last), email, and city and state combined. Then use this view to find all customers from California (CA).
create or alter view customer_info As select
customer_id,first_name + ' '+last_name as full_name,email, concat(city,' ',state) as customer_address
from sales.customers
select * from customer_info
where customer_address like '%CA'




--17. Find all products that cost between $50 and $200. Show product name and price, ordered by price from lowest to highest.
SELECT product_name, list_price
FROM production.products
WHERE list_price BETWEEN 50 AND 200
ORDER BY list_price ASC;


--18. Count how many customers live in each state. Show state and customer count, ordered by count from highest to lowest.
select count(customer_id) as customer_count ,state from sales.customers
group by state
order by customer_count desc


--19. Find the most expensive product in each category. Show category name, product name, and price.
select product_name,category_name,list_price from production.products p
join production.categories c on p.category_id=c.category_id
where list_price=(select max(list_price) from production.products p
where p.category_id=c.category_id)



--20. Show all stores and their cities, including the total number of orders from each store. Show store name, city, and order count.
select store_name,city,count(order_id)as total_order
from sales.stores s
join sales.orders o on s.store_id=o.store_id
group by store_name,city