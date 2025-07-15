-- ===========================================================
-- 1. Classify all products into price categories
-- Economy (< $300), Standard ($300-$999), Premium ($1000-$2499), Luxury (>= $2500)
-- ===========================================================
select product_name, list_price,
 case 
 when list_price<300 then'Economy'
 when list_price between 300 and 999 then 'Standard'
 when list_price between 1000 and 2499 then 'Standard'
 when list_price>=2500 then'Economy'
 end as price_category
from production.products
-- ===========================================================
-- 2. Show order processing info with friendly status + priority levels
-- Status:
-- 1 = "Order Received"
-- 2 = "In Preparation"
-- 3 = "Order Cancelled"
-- 4 = "Order Delivered"
-- Priority:
-- Status 1 older than 5 days = "URGENT"
-- Status 2 older than 3 days = "HIGH"
-- Else = "NORMAL"
-- ===========================================================
select order_status,
case
  when order_status=1 then 'Order Received'
  when order_status=2 then 'In Preparation'
  when order_status=3 then 'Order Cancelled'
  when order_status=4 then 'Order Delivered'
end as order_status
from sales.orders

-- ===========================================================
-- 3. Categorize staff based on number of orders handled:
-- 0 = "New Staff"
-- 1-10 = "Junior Staff"
-- 11-25 = "Senior Staff"
-- 26+ = "Expert Staff"
-- ===========================================================
select s.first_name + ' '+s.last_name as staff_name,
case 
   when count(order_id)=0 then 'New Staff'
   when count(order_id) between 1 and 10 then 'Junior Staff'
   when count(order_id) between 11 and 25 then 'Senior Staff'
   when count(order_id)>26 then 'Expert Staff'
end as staff_category
from sales.staffs s
join sales.orders o on s.staff_id=o.staff_id
group by s.first_name,s.last_name
-- ===========================================================
-- 4. Handle missing customer contact info:
-- - ISNULL for phone ? "Phone Not Available"
-- - COALESCE(phone, email, "No Contact Method")
-- ===========================================================
select first_name + ' '+last_name as customer_name,
  isnull(phone,'Phone Not Available') as phone_number,
  coalesce(phone,email,'No Contact Method') as best_contact_method
from sales.customers    

-- ===========================================================
-- 5. Safely calculate price per unit in stock:
-- - Use NULLIF to avoid division by zero
-- - Use ISNULL to return 0 if NULL
-- - Add stock status using CASE
-- - Only for store_id = 1
-- ===========================================================
select p.product_name,s.quantity,p.list_price,s.store_id,

 isnull(p.list_price/nullif (s.quantity,0),0) as price_per_unit  ,

  case 
     WHEN s.quantity > 0 THEN 'In Stock'
     WHEN s.quantity = 0 THEN 'Out of Stock'
  end as stock_status
 from production.stocks s
 join production.products p on s.quantity=p.product_id
 where  store_id=1
 order by s.quantity

-- ===========================================================
-- 6. Format complete addresses safely:
-- - Use COALESCE for each component
-- - Create formatted_address field
-- - Handle missing ZIP codes
-- ===========================================================
SELECT 
    customer_id,
    first_name + ' ' + last_name AS full_name,
    
   
    COALESCE(city, 'No City') AS city,
    COALESCE(state, 'No State') AS state,

    
    COALESCE(city, '') + ', ' + COALESCE(state, '') AS formatted_address

FROM sales.customers;

-- ===========================================================
-- 7. CTE: Customers who spent > $1500 total
-- - Use CTE to calculate total spending per customer
-- - Join with customer info
-- - Order by spending DESC
-- ===========================================================
WITH customer_spending AS (
    SELECT 
        o.customer_id,
        SUM(oi.quantity * oi.list_price) AS total_spent
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT 
    c.customer_id,
    c.first_name + ' ' + c.last_name AS full_name,
    cs.total_spent
FROM customer_spending cs
JOIN sales.customers c ON cs.customer_id = c.customer_id
WHERE cs.total_spent > 1500
ORDER BY cs.total_spent DESC;

-- ===========================================================
-- 8. Multi-CTE category analysis:
-- - CTE 1: total revenue per category
-- - CTE 2: avg order value per category
-- - Main query: rate performance using CASE
-- "Excellent" > $50000, "Good" > $20000, else "Needs Improvement"
-- ===========================================================
WITH revenue_per_category AS (
    SELECT 
        c.category_name,
        SUM(oi.quantity * oi.list_price) AS total_revenue
    FROM sales.order_items oi
    JOIN production.products p ON oi.product_id = p.product_id
    JOIN production.categories c ON p.category_id = c.category_id
    GROUP BY c.category_name
),
avg_order_value_per_category AS (
    SELECT 
        c.category_name,
        AVG(oi.quantity * oi.list_price) AS avg_order_value
    FROM sales.order_items oi
    JOIN production.products p ON oi.product_id = p.product_id
    JOIN production.categories c ON p.category_id = c.category_id
    GROUP BY c.category_name
)
SELECT 
    r.category_name,
    r.total_revenue,
    a.avg_order_value,
    CASE 
        WHEN r.total_revenue > 50000 THEN 'Excellent'
        WHEN r.total_revenue > 20000 THEN 'Good'
        ELSE 'Needs Improvement'
    END AS performance_rating
FROM revenue_per_category r
JOIN avg_order_value_per_category a ON r.category_name = a.category_name;
-- ===========================================================
-- 9. CTE monthly sales trend analysis:
-- - CTE 1: monthly totals
-- - CTE 2: add previous month comparison
-- - Calculate growth %
-- ===========================================================
WITH monthly_sales AS (
    SELECT 
        FORMAT(o.order_date, 'yyyy-MM') AS order_month,
        SUM(oi.quantity * oi.list_price) AS total_revenue
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY FORMAT(o.order_date, 'yyyy-MM')
),
sales_with_lag AS (
    SELECT 
        order_month,
        total_revenue,
        LAG(total_revenue) OVER (ORDER BY order_month) AS prev_month_revenue
    FROM monthly_sales
)
SELECT 
    order_month,
    total_revenue,
    prev_month_revenue,
    ROUND(
        CASE 
            WHEN prev_month_revenue IS NULL THEN NULL
            ELSE 100.0 * (total_revenue - prev_month_revenue) / prev_month_revenue
        END, 2
    ) AS growth_percent
FROM sales_with_lag;
-- ===========================================================
-- 10. Rank products within category:
-- - Use ROW_NUMBER() by price DESC
-- - Use RANK() and DENSE_RANK()
-- - Show top 3 products per category
-- ===========================================================
WITH RankedProducts AS (
    SELECT 
        c.category_name,
        p.product_name,
        p.list_price,
        ROW_NUMBER() OVER (PARTITION BY c.category_name ORDER BY p.list_price DESC) AS row_num,
        RANK() OVER (PARTITION BY c.category_name ORDER BY p.list_price DESC) AS rank_num,
        DENSE_RANK() OVER (PARTITION BY c.category_name ORDER BY p.list_price DESC) AS dense_rank_num
    FROM production.products p
    JOIN production.categories c ON p.category_id = c.category_id
)
SELECT *
FROM RankedProducts
WHERE row_num <= 3;
-- ===========================================================
-- 11. Rank customers by total spending:
-- - Use RANK()
-- - Use NTILE(5) to group into 5 levels
-- - Add tier label with CASE (1=VIP, 2=Gold, ...)
-- ===========================================================
WITH customer_total AS (
    SELECT 
        o.customer_id,
        SUM(oi.quantity * oi.list_price) AS total_spent
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT 
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    ct.total_spent,
    RANK() OVER (ORDER BY ct.total_spent DESC) AS spending_rank,
    NTILE(5) OVER (ORDER BY ct.total_spent DESC) AS spending_group,
    CASE 
        WHEN NTILE(5) OVER (ORDER BY ct.total_spent DESC) = 1 THEN 'VIP'
        WHEN NTILE(5) OVER (ORDER BY ct.total_spent DESC) = 2 THEN 'Gold'
        WHEN NTILE(5) OVER (ORDER BY ct.total_spent DESC) = 3 THEN 'Silver'
        WHEN NTILE(5) OVER (ORDER BY ct.total_spent DESC) = 4 THEN 'Bronze'
        ELSE 'Standard'
    END AS tier
FROM customer_total ct
JOIN sales.customers c ON c.customer_id = ct.customer_id;


-- ===========================================================
-- 12. Store performance ranking:
-- - Rank by total revenue
-- - Rank by order count
-- - Use PERCENT_RANK()
-- ===========================================================
WITH store_perf AS (
    SELECT 
        s.store_id,
        s.store_name,
        COUNT(o.order_id) AS total_orders,
        SUM(oi.quantity * oi.list_price) AS total_revenue
    FROM sales.stores s
    JOIN sales.orders o ON s.store_id = o.store_id
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY s.store_id, s.store_name
)
SELECT *,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    RANK() OVER (ORDER BY total_orders DESC) AS order_count_rank,
    PERCENT_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_percentile
FROM store_perf;
-- ===========================================================
-- 13. PIVOT: product counts by category and brand
-- - Rows: categories
-- - Columns: Electra, Haro, Trek, Surly
-- - Values: COUNT of products
-- ===========================================================
SELECT * FROM (
    SELECT 
        c.category_name,
        b.brand_name
    FROM production.products p
    JOIN production.categories c ON p.category_id = c.category_id
    JOIN production.brands b ON p.brand_id = b.brand_id
    WHERE b.brand_name IN ('Electra', 'Haro', 'Trek', 'Surly')
) AS source_table
PIVOT (
    COUNT(brand_name)
    FOR brand_name IN ([Electra], [Haro], [Trek], [Surly])
) AS pivot_table;
-- ===========================================================
-- 14. PIVOT: monthly revenue by store
-- - Rows: store names
-- - Columns: Jan ? Dec
-- - Values: total revenue
-- - Add total column
-- ===========================================================
SELECT *, 
       ISNULL([Jan], 0) + ISNULL([Feb], 0) + ISNULL([Mar], 0) + 
       ISNULL([Apr], 0) + ISNULL([May], 0) + ISNULL([Jun], 0) + 
       ISNULL([Jul], 0) + ISNULL([Aug], 0) + ISNULL([Sep], 0) + 
       ISNULL([Oct], 0) + ISNULL([Nov], 0) + ISNULL([Dec], 0) AS Total_Revenue
FROM (
    SELECT 
        s.store_name,
        DATENAME(MONTH, o.order_date) AS month_name,
        oi.quantity * oi.list_price AS revenue
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    JOIN sales.stores s ON o.store_id = s.store_id
) AS source_table
PIVOT (
    SUM(revenue)
    FOR month_name IN ([Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec])
) AS pivot_table;
-- ===========================================================
-- 15. PIVOT: Order statuses across stores
-- - Rows: Store names
-- - Columns: Statuses
-- - Values: Count of orders
-- ===========================================================
SELECT *
FROM (
    SELECT 
        s.store_name,
        o.order_status
    FROM sales.orders o
    JOIN sales.stores s ON o.store_id = s.store_id
) AS source_table
PIVOT (
    COUNT(order_status)
    FOR order_status IN ([1], [2], [3], [4])
) AS pivot_table;
-- ===========================================================
-- 16. PIVOT: Compare yearly sales by brand
-- - Rows: brand names
-- - Columns: 2016, 2017, 2018
-- - Values: total revenue
-- - Include percentage growth
-- ===========================================================

WITH brand_year_sales AS (
    SELECT 
        b.brand_name,
        YEAR(o.order_date) AS order_year,
        oi.quantity * oi.list_price AS revenue
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    JOIN production.products p ON oi.product_id = p.product_id
    JOIN production.brands b ON p.brand_id = b.brand_id
    WHERE YEAR(o.order_date) IN (2016, 2017, 2018)
)
SELECT * FROM (
    SELECT 
        brand_name,
        order_year,
        revenue
    FROM brand_year_sales
) AS source_table
PIVOT (
    SUM(revenue)
    FOR order_year IN ([2016], [2017], [2018])
) AS pivot_table;


-- ===========================================================
-- 17. UNION: Product availability statuses
-- - In-stock: quantity > 0
-- - Out-of-stock: quantity = 0 or NULL
-- - Discontinued: not in stock table
-- ===========================================================


SELECT p.product_name, 'In Stock' AS status
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity > 0

UNION


SELECT p.product_name, 'Out of Stock' AS status
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity = 0 OR s.quantity IS NULL

UNION


SELECT p.product_name, 'Discontinued' AS status
FROM production.products p
WHERE NOT EXISTS (
    SELECT 1 FROM production.stocks s WHERE s.product_id = p.product_id
);


-- ===========================================================
-- 18. INTERSECT: Loyal customers
-- - Customers who ordered in 2017 AND 2018
-- ===========================================================

SELECT customer_id
FROM sales.orders
WHERE YEAR(order_date) = 2017

INTERSECT

SELECT customer_id
FROM sales.orders
WHERE YEAR(order_date) = 2018;


-- ===========================================================
-- 19. Set operations for product distribution:
-- - INTERSECT: products in all 3 stores
-- - EXCEPT: products in store 1 but not in 2
-- - UNION: combine all with labels
-- ===========================================================


SELECT product_id, 'In All Stores' AS label
FROM (
    SELECT product_id FROM production.stocks WHERE store_id = 1
    INTERSECT
    SELECT product_id FROM production.stocks WHERE store_id = 2
    INTERSECT
    SELECT product_id FROM production.stocks WHERE store_id = 3
) AS common_products

UNION


SELECT product_id, 'Only In Store 1' AS label
FROM (
    SELECT product_id FROM production.stocks WHERE store_id = 1
    EXCEPT
    SELECT product_id FROM production.stocks WHERE store_id = 2
) AS only_in_store1;


-- ===========================================================
-- 20. Customer retention analysis:
-- - 2016 but not 2017 ? "Lost"
-- - 2017 but not 2016 ? "New"
-- - Both ? "Retained"
-- - Use UNION ALL to merge groups
-- ===========================================================


SELECT customer_id, 'Lost' AS status
FROM sales.orders
WHERE YEAR(order_date) = 2016
EXCEPT
SELECT customer_id, 'Lost' 
FROM sales.orders
WHERE YEAR(order_date) = 2017

UNION ALL


SELECT customer_id, 'New' AS status
FROM sales.orders
WHERE YEAR(order_date) = 2017
EXCEPT
SELECT customer_id, 'New'
FROM sales.orders
WHERE YEAR(order_date) = 2016

UNION ALL


SELECT customer_id, 'Retained' AS status
FROM sales.orders
WHERE YEAR(order_date) = 2016
INTERSECT
SELECT customer_id, 'Retained'
FROM sales.orders
WHERE YEAR(order_date) = 2017;
