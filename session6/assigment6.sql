-- 1. Customer Spending Analysis
-- Write a query that uses variables to find the total amount spent by customer ID 1.
-- Display a message showing whether they are a VIP customer (spent > $5000) or regular customer.
declare @customer_id int = 1;
declare @total_spent decimal(10,2)
select  @total_spent=sum(oi.list_price *oi.quantity *(1-discount)) 
from sales.orders o
join sales.order_items oi on o.order_id=oi.order_id
where o.customer_id=@customer_id



if @total_spent is null
 
         print'No orders found for this customer.'
		   
else if @total_spent>5000
   print' customer ' + cast(@customer_id as varchar)+' is a vip customer.total spent:$ '+cast(@total_spent as varchar)

else 
    print'customer ' + cast(@customer_id as varchar)+' is a regular customer .total spent:$ '+cast(@total_spent as varchar)




-- 2. Product Price Threshold Report
-- Create a query using variables to count how many products cost more than $1500.
-- Store the threshold price in a variable and display both the threshold and count in a formatted message.
declare @threshold_price decimal(10,2)=1500
declare @product_count int
select @product_count=count(*)
from production.products
where list_price>@threshold_price
print 'threshold price is '+cast(@threshold_price as varchar(10))+'number of product that cost more than threshold price is '+cast(@product_count as varchar)


-- 3. Staff Performance Calculator
-- Write a query that calculates the total sales for staff member ID 2 in the year 2017.
-- Use variables to store the staff ID, year, and calculated total. Display the results with appropriate labels.
declare @staff_id int=2
declare @sales_year int=2017
declare @total_sales int

select @total_sales=sum(oi.list_price*oi.quantity*(1-discount))
from sales.order_items oi
join sales.orders o on oi.order_id=o.order_id
where o.staff_id=@staff_id and year(o.order_date)=@sales_year


PRINT 'Total sales for staff ID ' + CAST(@staff_id AS VARCHAR) +
      ' in year ' + CAST(@sales_year AS VARCHAR) + ' is $' + CAST(@total_sales AS VARCHAR);




-- 4. Global Variables Information
-- Create a query that displays the current server name, SQL Server version, and the number of rows affected by the last statement.


select
@@SERVERNAME as server_name,
@@VERSION as servre_version,
@@ROWCOUNT 

-- 5. Inventory Level Check
-- Write a query that checks the inventory level for product ID 1 in store ID 1.
-- Use IF statements to display different messages based on stock levels:
-- If quantity > 20: Well stocked
-- If quantity 10-20: Moderate stock
-- If quantity < 10: Low stock - reorder needed
declare @product_stock int 
declare @product_id int=1
declare @store_id int =1
select @product_stock=quantity
from production.stocks
where product_id=@product_id and store_id=@store_id
if @product_stock>20
  print (' Well stocked')
else if @product_stock between 10 and 20
  print ('Moderate stock')
else if @product_stock < 10
  print ('Low stock - reorder needed')



-- 6. WHILE Loop Restock
-- Create a WHILE loop that updates low-stock items (quantity < 5) in batches of 3 products at a time.
-- Add 10 units to each product and display progress messages after each batch.


-- Update inventory in batches
declare @batch_size int =3
declare @row_updated int =1

while @row_updated >  0

  begin
     update top (@batch_size) production.stocks
     set quantity=quantity+10
     where quantity<5
     set @row_updated=@@ROWCOUNT
     PRINT 'Updated ' + CAST(@row_updated AS VARCHAR(10)) + ' records';
  end



 
 

-- 7. Product Price Categorization
-- Write a query that categorizes all products using CASE WHEN based on their list price:
-- Under $300: Budget
-- $300-$800: Mid-Range
-- $801-$2000: Premium
-- Over $2000: Luxury


select product_id,list_price,
case
 when list_price<300 then 'Budget'
 when list_price between 300 and 800 then 'Mid-Range'
 when list_price between 801 and 2000 then 'Premium'
 when list_price>20000 then 'Luxury'
 end as product_Categorization
from production.products






 
-- 8. Customer Order Validation
-- Create a query that checks if customer ID 5 exists in the database.
-- If they exist, show their order count. If not, display an appropriate message.
 declare @customer_id int =5
 declare @order_count int
 
 if exists(select 1 from sales.customers where customer_id=@customer_id)
 begin
  select @order_count=count(*) from sales.orders
  where customer_id=@customer_id
  PRINT 'Customer with ID ' + CAST(@customer_id AS VARCHAR) + 
          ' has placed ' + CAST(@order_count AS VARCHAR) + ' orders.'
 end
 else
 begin
   print'customer with id= ' +cast(@customer_id as varchar)+'not found'
 end

-- 9. Shipping Cost Calculator Function
-- Create a scalar function named CalculateShipping that takes an order total as input and 
   --returns shipping cost:
-- Orders over $100: Free shipping ($0)
-- Orders $50-$99: Reduced shipping ($5.99)
-- Orders under $50: Standard shipping ($12.99)


create function CalculateShipping(@order_total decimal(10,2))
returns decimal(10,2)
as 
begin

 declare @shipping_cost decimal(10,2)
if  @order_total>1500
 set @shipping_cost= 0.00
else if @order_total between 50 and 99 
 set @shipping_cost= 5.99
else if  @order_total<50 
 set @shipping_cost= 12.99
 return  @shipping_cost
end

select dbo.CalculateShipping(70) as shipping_cost









-- 10. Product Category Function
-- Create an inline table-valued function named GetProductsByPriceRange that accepts min and max price
-- and returns all products within that price range with brand and category info.
create function GetProductsByPriceRange(@min_price decimal(10,2),@max_price decimal(10,2))
returns table
as 
return(
select p.product_id,p.list_price ,c.category_name,b.brand_name
from production.products p
join production.categories c on p.category_id=c.category_id
join production.brands b on p.brand_id=b.brand_id
where p.list_price between @min_price and @max_price
)

select * from dbo.GetProductsByPriceRange(27.4,50) 


-- 11. Customer Sales Summary Function
-- Create a multi-statement function named GetCustomerYearlySummary that takes a customer ID
-- and returns yearly sales data: total orders, total spent, and average order value.

create function GetCustomerYearlySummary(@customer_id int)
returns @yearly_sales_data table
(
order_year int,
total_order int,
total_spent decimal(10,2),
 AvgOrderValue DECIMAL(10,2)
 )
 as 
 begin
 insert into @yearly_sales_data
 select
 year(o.order_date ) as  order_year   ,
 count(*) as total_order,
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) as total_spent,
  AVG(oi.quantity * oi.list_price * (1 - oi.discount)) as AvgOrderValue

  from sales.order_items oi
  join sales.orders o on oi.order_id=o.order_id
  where customer_id=@customer_id
  group by year(o.order_date )
  return
  end




  select * from dbo.GetCustomerYearlySummary(20)



-- 12. Discount Calculation Function
-- Write a scalar function named CalculateBulkDiscount that determines discount percentage based on quantity:
-- 1-2 items: 0% discount
-- 3-5 items: 5% discount
-- 6-9 items: 10% discount
-- 10+ items: 15% discount
create function CalculateBulkDiscount(@quantity int)
returns decimal(10,2)
as  
begin
 declare @discount_percentage decimal(10,2)
 if @quantity in (1 , 2)
 set @discount_percentage=00.00
 else if @quantity between 3 and 5
 set @discount_percentage=5.00
 else if @quantity between 6 and 9
 set @discount_percentage=10.00
 else
  set @discount_percentage=15.00

  return @discount_percentage
end


select dbo.CalculateBulkDiscount(20) as discount_percentage


-- 13. Customer Order History Procedure
-- Create a stored procedure named sp_GetCustomerOrderHistory that accepts a customer ID and optional start/end dates.
-- Return the customer's order history with order totals calculated.



 CREATE PROCEDURE sp_GetCustomerOrders
    @customer_id INT,
    @start_date DATE = NULL,
    @end_date DATE = NULL
AS
BEGIN
select o.order_id,order_status,o.order_date,sum(oi.list_price*oi.quantity*(1-discount)) as total_order
from sales.orders o
join sales.order_items oi on o.order_id=oi.order_id
where customer_id=@customer_id and (@start_date is null or o.order_date>=@start_date)
                               and (@end_date is null or o.order_date<=@end_date)
group by o.order_id,order_status,o.order_date

end

drop procedure sp_GetCustomerOrders


exec sp_GetCustomerOrders @customer_id=77,@start_date='01-01-2016',@end_date='2017-01-01'












-- 14. Inventory Restock Procedure
-- Write a stored procedure named sp_RestockProduct with input parameters for store ID, product ID, and restock quantity.
-- Include output parameters for old quantity, new quantity, and success status.
create procedure sp_RestockProduct
     @store_id int ,
	 @product_id int,
	 @restock_quantity int
	 
as
begin
declare @old_quantity int
declare @new_quantity int
select  @old_quantity=quantity from  production.stocks 
where @store_id=store_id and @product_id=product_id
update production.stocks


set quantity=quantity+@restock_quantity 
where @store_id=store_id and @product_id=product_id

set @new_quantity=  @old_quantity +@restock_quantity 
 
select @old_quantity  as OldQuantit,
@new_quantity as NewQuantity ,'sucsess' as stutas
end




-------------------------------or----------------------------------

drop procedure sp_RestockProduct

create procedure sp_RestockProduct
     @store_id int ,
	 @product_id int,
	 @restock_quantity int,
	 @old_qty int output,
	 @new_qty int output,
	 @sucess bit output

as
begin
if exists(select 1 from production.stocks where store_id=@store_id and product_id=@product_id)
begin
select @old_qty=quantity from production.stocks where store_id=@store_id and product_id=@product_id
update production.stocks
set quantity=quantity+@restock_quantity
where store_id=@store_id and product_id=@product_id

set @new_qty=@old_qty+@restock_quantity
set @sucess=1
end
else 
begin
 set @old_qty =null
 set @new_qty=null
 set @sucess=0

end

end

declare @old int, @new int , @status bit

exec sp_RestockProduct

     @store_id =15,
	 @product_id =70,
	 @restock_quantity =30,
	 @old_qty =@old output,
	 @new_qty =@new output,
	 @sucess =@status output


SELECT 
    @old AS OldQuantity,
    @new AS NewQuantity,
    @status AS OperationSuccess;












-- 15. Order Processing Procedure
-- Create a stored procedure named sp_ProcessNewOrder that handles complete order creation
-- with proper transaction control and error handling.
-- Include parameters for customer ID, product ID, quantity, and store ID.

drop  procedure sp_ProcessNewOrder

create procedure sp_ProcessNewOrder
        @customer_id int,
		@product_id int,
		@quantity int,
		@store_id int ,
		@staff_id int



as
begin
   begin try
     begin transaction 
	 if exists(select 1 from production.stocks where product_id=@product_id and store_id=@store_id and quantity>=@quantity)
	 begin
	 update production.stocks
	 set quantity=quantity-@quantity
	 where product_id=@product_id and store_id=@store_id

	 insert into sales.orders(customer_id,order_status,order_date,required_date,store_id,staff_id) values
	 (@customer_id,4,getdate(),getdate(),@store_id,@staff_id )


	 declare @order_id int =scope_identity()
	 insert into sales.order_items(order_id,item_id,product_id,quantity,list_price,discount)values
	 (@order_id,1,@product_id,@quantity,(select list_price from production.products where product_id=@product_id),0)
	  
	  commit transaction 

	 end
	 else
	 begin 
	 raiserror('not enough quantity in stocks',16,1)
	 rollback transaction 
	 end
   end try
   begin catch
   rollback transaction 
   declare @error Nvarchar(1000)=error_message()
   raiserror(@error,16,1)
   end catch

end


exec sp_ProcessNewOrder
        @customer_id =44,
		@product_id= 32,
		@quantity =5,
		@store_id =7,
		@staff_id=4

SELECT * FROM sales.order_items
ORDER BY order_id DESC;


SELECT * FROM production.stocks
WHERE product_id = 32 AND store_id = 7;




-- 16. Dynamic Product Search Procedure
-- Write a stored procedure named sp_SearchProducts that builds dynamic SQL based on optional parameters:
-- product name search term, category ID, min price, max price, and sort column.


create procedure  sp_SearchProducts
             @product_name varchar(50)=null,
			 @category_id int =null,
			 @min_price decimal(10,2)=null,
			 @max_price decimal(10,2)=null,
			 @sort_column varchar(50)=null

as
  begin
   declare @sql Nvarchar(max) 
   set @sql ='select * from production.products where 1=1'

   if @product_name  is not null
   set @sql=@sql+' and product_name like ''%'+@product_name+'%'''
 
   if @category_id is not null
   set @sql += ' AND category_id = ' + cast(@category_id as nvarchar)

  
  if @min_price is not null
  set @sql+=' and list_price >= '+cast(@min_price as nvarchar)


   if @max_price is not null
  set @sql+=' and list_price <= '+cast(@max_price as nvarchar)


   if @sort_column is not null
  set @sql+=' order by '+quotename(@sort_column)

  exec sp_executesql @sql

  end

  
  exec   sp_SearchProducts
     @product_name = 'shirt',
	 @category_id=3,
     @min_price =70, 
     @max_price = 400, 
     @sort_column = 'list_price'





-- 17. Staff Bonus Calculation System
-- Create a complete solution that calculates quarterly bonuses for all staff members.
-- Use variables to store date ranges and bonus rates.
-- Apply different bonus percentages based on sales performance tiers.
-- 1. Declare variables for date range and bonus tiers
DECLARE @StartDate DATE = '2024-01-01';
DECLARE @EndDate DATE = '2024-03-31';  -- Q1 example

DECLARE @LowTierBonus DECIMAL(5,2) = 0.05;   -- 5%
DECLARE @MidTierBonus DECIMAL(5,2) = 0.10;   -- 10%
DECLARE @HighTierBonus DECIMAL(5,2) = 0.15;  -- 15%

SELECT 
    s.staff_id,
    s.first_name + ' ' + s.last_name AS staff_name,
    SUM(sa.list_price) AS total_sales,

    CASE 
        WHEN SUM(sa.list_price) >= 50000 THEN 'High'
        WHEN SUM(sa.list_price) >= 20000 THEN 'Medium'
        ELSE 'Low'
    END AS performance_tier,

    CASE 
        WHEN SUM(sa.list_price) >= 50000 THEN SUM(sa.list_price) * @HighTierBonus
        WHEN SUM(sa.list_price) >= 20000 THEN SUM(sa.list_price) * @MidTierBonus
        ELSE SUM(sa.list_price) * @LowTierBonus
    END AS bonus_amount

FROM 
    sales.staffs s
JOIN 
    sales.orders o ON s.staff_id = o.staff_id
JOIN 
    sales.order_items sa ON o.order_id = sa.order_id
WHERE 
    o.order_date BETWEEN @StartDate AND @EndDate
GROUP BY 
    s.staff_id, s.first_name, s.last_name;


-- 18. Smart Inventory Management
-- Write a complex query with nested IF statements that manages inventory restocking.
-- Check current stock levels and apply different reorder quantities based on product categories and stock levels.

SELECT 
    p.product_id,
    product_name,
    category_id,
    quantity,

    CASE 
       
        WHEN category_id = 1 THEN 
            CASE 
                WHEN quantity < 10 THEN 100
                WHEN quantity BETWEEN 10 AND 20 THEN 50
                ELSE 0
            END

     
        WHEN category_id = 2 THEN 
            CASE 
                WHEN quantity < 20 THEN 200
                WHEN quantity BETWEEN 20 AND 50 THEN 100
                ELSE 0
            END

       
        WHEN category_id = 3 THEN 
            CASE 
                WHEN quantity < 50 THEN 500
                WHEN quantity BETWEEN 50 AND 100 THEN 200
                ELSE 0
            END

       
        ELSE 
            CASE 
                WHEN quantity < 15 THEN 50
                ELSE 0
            END
    END AS reorder_quantity

FROM 
    production.products p
	join sales.order_items oi on p.product_id=oi.product_id



-- 19. Customer Loyalty Tier Assignment
-- Create a solution that assigns loyalty tiers to customers based on their total spending.
-- Handle customers with no orders appropriately and use proper NULL checking.

SELECT 
    c.customer_id,
     c.first_name+' '+c.last_name as customer_name,
    COALESCE(SUM(list_price), 0) AS total_spent,
    
    CASE 
        WHEN SUM(list_price) IS NULL THEN 'No Orders'
        WHEN SUM(list_price) >= 10000 THEN 'Platinum'
        WHEN SUM(list_price) >= 5000 THEN 'Gold'
        WHEN SUM(list_price) >= 1000 THEN 'Silver'
        ELSE 'Bronze'
    END AS loyalty_tier

FROM 
    sales.customers c
LEFT JOIN 
    sales.orders o ON c.customer_id = o.customer_id
LEFT JOIN 
    sales.order_items oi on o.order_id=oi.order_id
GROUP BY 
    c.customer_id,  c.first_name,c.last_name

-- 20. Product Lifecycle Management
-- Write a stored procedure that handles product discontinuation including:
-- checking for pending orders, optional product replacement, clearing inventory, and providing detailed status messages.
CREATE OR ALTER PROCEDURE sp_DiscontinueProduct
    @product_id INT
AS
BEGIN
    SET NOCOUNT ON;

   
    IF NOT EXISTS (
        SELECT 1 FROM production.products WHERE product_id = @product_id
    )
    BEGIN
        PRINT ' Product does not exist.';
        RETURN;
    END

   
    IF EXISTS (
        SELECT 1
        FROM sales.order_items oi
        JOIN sales.orders o ON oi.order_id = o.order_id
        WHERE oi.product_id = @product_id AND o.order_status != 2
    )
    BEGIN
        PRINT ' Cannot discontinue product with pending orders.';
        RETURN;
    END

    
    DELETE FROM production.products
    WHERE product_id = @product_id;

    
    DELETE FROM sales.order_items
    WHERE product_id = @product_id;

    PRINT ' Product discontinued successfully and inventory cleared.';
END;



-- Bonus Challenges

-- 21. Advanced Analytics Query
-- Create a query that combines multiple advanced concepts to generate a comprehensive sales report
-- showing monthly trends, staff performance, and product category analysis.
-- Monthly Sales, Staff Performance, and Category Analysis
SELECT 
    FORMAT(o.order_date, 'yyyy-MM') AS Month,
    CONCAT(cu.first_name, ' ', cu.last_name) AS StaffName,
    c.category_name,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    SUM(oi.quantity) AS TotalItemsSold,
    SUM(oi.quantity * oi.list_price) AS TotalSales
FROM 
    sales.orders o
JOIN 
    sales.order_items oi ON o.order_id = oi.order_id
JOIN 
    production.products p ON oi.product_id = p.product_id
JOIN 
    production.categories c ON p.category_id = c.category_id
JOIN 
    sales.staffs s ON o.staff_id = s.staff_id
JOIN 
    sales.customers cu ON s.staff_id = cu.customer_id
GROUP BY 
    FORMAT(o.order_date, 'yyyy-MM'),
    CONCAT(cu.first_name, ' ', cu.last_name),
    c.category_name
ORDER BY 
    Month, StaffName, category_name;

-- 22. Data Validation System
-- Build a data validation system using functions and procedures that ensures data integrity when inserting new orders.
-- Include customer validation, inventory checking, and business rule enforcement.
CREATE OR ALTER FUNCTION dbo.fn_CustomerExists (@customer_id INT)
RETURNS BIT
AS
BEGIN
    RETURN (
        SELECT CASE WHEN EXISTS (
            SELECT 1 FROM sales.customers WHERE customer_id = @customer_id
        ) THEN 1 ELSE 0 END
    );
END;
-------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_IsStockAvailable (
    @product_id INT,
    @required_qty INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @available INT;

    SELECT @available = quantity 
    FROM production.products p
	join sales.order_items oi on oi.product_id=p.product_id
    WHERE p.product_id = @product_id;

    RETURN (
        SELECT CASE 
            WHEN @available IS NULL OR @available < @required_qty THEN 0 
            ELSE 1 
        END
    );
END;
----------------------
CREATE OR ALTER PROCEDURE sp_InsertValidatedOrder
    @customer_id INT,
    @staff_id INT,
    @order_date DATE,
    @product_id INT,
    @quantity INT,
    @unit_price DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- ???? ?? ??????
    IF dbo.fn_CustomerExists(@customer_id) = 0
    BEGIN
        PRINT ' Customer does not exist.';
        RETURN;
    END

    -- ???? ?? ???? ???????
    IF dbo.fn_IsStockAvailable(@product_id, @quantity) = 0
    BEGIN
        PRINT ' Not enough stock available.';
        RETURN;
    END

    -- ????? ?????
    DECLARE @order_id INT;

    INSERT INTO sales.orders (customer_id, staff_id, order_date, order_status)
    VALUES (@customer_id, @staff_id, @order_date, 0);  -- status = Pending

    SET @order_id = SCOPE_IDENTITY();

    -- ????? ????? ?????
    INSERT INTO sales.order_items (order_id, product_id, quantity, list_price)
    VALUES (@order_id, @product_id, @quantity, @unit_price);

    -- ????? ???????
    UPDATE sales.order_items
    SET quantity = quantity - @quantity
    WHERE product_id = @product_id;

    PRINT ' Order created successfully with validated data.';
END;
