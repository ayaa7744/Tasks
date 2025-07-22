--1.1 List all employees hired after January 1, 2012, showing their ID, first name, last name, and hire date, ordered by hire date descending.

select  pp.BusinessEntityID,FirstName,LastName,HireDate from Person.Person pp
join HumanResources.Employee he on pp.BusinessEntityID=he.BusinessEntityID
where HireDate > '2012-01-01'
order by HireDate desc

--1.2 List products with a list price between $100 and $500, showing product ID, name, list price, and product number, ordered by list price ascending.

select ProductID,name,ListPrice,ProductNumber from Production.Product
where ListPrice between 100 and 500
order by ListPrice asc

--1.3 List customers from the cities 'Seattle' or 'Portland', showing customer ID, first name, last name, and city, using appropriate joins.
SELECT 
    c.CustomerID,
    p.FirstName,
    p.LastName,
    a.City
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON c.PersonID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
WHERE a.City IN ('Seattle', 'Portland');



--1.4 List the top 15 most expensive products currently being sold, showing name, list price, product number, and category name, excluding discontinued products.
select top 15 
pp.name,ListPrice,ProductNumber,pc.name as CategoryName 
from Production.Product pp
JOIN Production.ProductSubcategory psc ON pp.ProductSubcategoryID = psc.ProductSubcategoryID
join Production.ProductCategory pc on psc.ProductCategoryID=pc.ProductCategoryID
where pp.SellEndDate is null
ORDER BY pp.ListPrice DESC;


--2.1 List products whose name contains 'Mountain' and color is 'Black', showing product ID, name, color, and list price.
SELECT 
    ProductID,
    Name,
    Color,
    ListPrice
FROM Production.Product
WHERE Name LIKE '%Mountain%'
  AND Color = 'Black';


--2.2 List employees born between January 1, 1970, and December 31, 1985, showing full name, birth date, and age in years.
SELECT 
    CONCAT(p.FirstName, ' ', p.LastName) AS FullName,
    e.BirthDate,
    DATEDIFF(YEAR, e.BirthDate, GETDATE()) AS Age
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.BirthDate BETWEEN '1970-01-01' AND '1985-12-31';

--2.3 List orders placed in the fourth quarter of 2013, showing order ID, order date, customer ID, and total due.
SELECT 
    SalesOrderID,
    OrderDate,
    CustomerID,
    TotalDue
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013 AND MONTH(OrderDate) BETWEEN 10 AND 12;

--2.4 List products with a null weight but a non-null size, showing product ID, name, weight, size, and product number.
SELECT 
    ProductID,
    Name,
    Weight,
    Size,
    ProductNumber
FROM Production.Product
WHERE Weight IS NULL AND Size IS NOT NULL;

---3.1 Count the number of products by category, ordered by count descending.
SELECT 
    pc.Name AS Category,
    COUNT(*) AS ProductCount
FROM Production.Product p
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY ProductCount DESC;

--3.2 Show the average list price by product subcategory, including only subcategories with more than five products.
SELECT 
    psc.Name AS Subcategory,
    AVG(p.ListPrice) AS AvgPrice,
    COUNT(*) AS ProductCount
FROM Production.Product p
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
GROUP BY psc.Name
HAVING COUNT(*) > 5;

--3.3 List the top 10 customers by total order count, including customer name.
SELECT TOP 10 
    c.CustomerID,
    CONCAT(p.FirstName, ' ', p.LastName) AS CustomerName,
    COUNT(o.SalesOrderID) AS OrderCount
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.LastName
ORDER BY OrderCount DESC;

--3.4 Show monthly sales totals for 2013, displaying the month name and total amount.
SELECT 
    DATENAME(MONTH, OrderDate) AS MonthName,
    SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013
GROUP BY DATENAME(MONTH, OrderDate), MONTH(OrderDate)
ORDER BY MONTH(OrderDate);

--4.1 Find all products launched in the same year as 'Mountain-100 Black, 42'. Show product ID, name, sell start date, and year.
SELECT 
    ProductID,
    Name,
    SellStartDate,
    YEAR(SellStartDate) AS StartYear
FROM Production.Product
WHERE YEAR(SellStartDate) = (
    SELECT YEAR(SellStartDate)
    FROM Production.Product
    WHERE Name = 'Mountain-100 Black, 42'
);

--4.2 Find employees who were hired on the same date as someone else. Show employee names, shared hire date, and the count of employees hired that day.
SELECT 
    p.FirstName + ' ' + p.LastName AS EmployeeName,
    e.HireDate,
    COUNT(*) OVER (PARTITION BY e.HireDate) AS HiredSameDay
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.HireDate IN (
    SELECT HireDate
    FROM HumanResources.Employee
    GROUP BY HireDate
    HAVING COUNT(*) > 1
)
ORDER BY e.HireDate;

--5.1 Create a table named Sales.ProductReviews with columns for review ID, product ID, customer ID, rating, review date, review text, verified purchase flag, and helpful votes.
-- Include appropriate primary key, foreign keys, check constraints, defaults, and a unique constraint on product ID and customer ID.
CREATE TABLE Sales.ProductReviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    CustomerID INT NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    ReviewDate DATE DEFAULT GETDATE(),
    ReviewText NVARCHAR(1000),
    VerifiedPurchase BIT DEFAULT 0,
    HelpfulVotes INT DEFAULT 0,
    CONSTRAINT UQ_Product_Customer UNIQUE (ProductID, CustomerID),
    CONSTRAINT FK_Product FOREIGN KEY (ProductID) REFERENCES Production.Product(ProductID),
    CONSTRAINT FK_Customer FOREIGN KEY (CustomerID) REFERENCES Sales.Customer(CustomerID)
);

--6.1 Add a column named LastModifiedDate to the Production.Product table, with a default value of the current date and time.
ALTER TABLE Production.Product
ADD LastModifiedDate DATETIME DEFAULT GETDATE();

--6.2 Create a non-clustered index on the LastName column of the Person.Person table, including FirstName and MiddleName.
CREATE NONCLUSTERED INDEX IX_Person_LastName
ON Person.Person (LastName)
INCLUDE (FirstName, MiddleName);

--6.3 Add a check constraint to the Production.Product table to ensure that ListPrice is greater than StandardCost.
ALTER TABLE Production.Product
ADD CONSTRAINT CK_ListPrice_StandardCost
CHECK (ListPrice > StandardCost);

--7.1 Insert three sample records into Sales.ProductReviews using existing product and customer IDs, with varied ratings and meaningful review text.
INSERT INTO Sales.ProductReviews (ProductID, CustomerID, Rating, ReviewText, VerifiedPurchase, HelpfulVotes)
VALUES 
(707, 30105, 5, 'Excellent quality and performance.', 1, 12),
(709, 30106, 3, 'Average experience, could be better.', 1, 4),
(710, 30107, 1, 'Poor quality, not recommended.', 0, 0);

--7.2 Insert a new product category named 'Electronics' and a corresponding product subcategory named 'Smartphones' under Electronics.

INSERT INTO Production.ProductCategory (Name, rowguid, ModifiedDate)
VALUES ('Electronics', NEWID(), GETDATE());

SELECT ProductCategoryID
FROM Production.ProductCategory
WHERE Name = 'Electronics';

INSERT INTO Production.ProductSubcategory (ProductCategoryID, Name, rowguid, ModifiedDate)
VALUES (5, 'Smartphones', NEWID(), GETDATE());

--7.3 Copy all discontinued products (where SellEndDate is not null) into a new table named Sales.DiscontinuedProducts.
SELECT *
INTO Sales.DiscontinuedProducts
FROM Production.Product
WHERE SellEndDate IS NOT NULL;

--8.1 Update the ModifiedDate to the current date for all products where ListPrice is greater than $1000 and SellEndDate is null.
UPDATE Production.Product
SET LastModifiedDate = GETDATE()
WHERE ListPrice > 1000 AND SellEndDate IS NULL;

--8.2 Increase the ListPrice by 15% for all products in the 'Bikes' category and update the ModifiedDate.
UPDATE p
SET ListPrice = ListPrice * 1.15,
    LastModifiedDate = GETDATE()
FROM Production.Product p
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE pc.Name = 'Bikes';

--8.3 Update the JobTitle to 'Senior' plus the existing job title for employees hired before January 1, 2010.
UPDATE HumanResources.Employee
SET JobTitle = 'Senior ' + JobTitle
WHERE HireDate < '2010-01-01';

--9.1 Delete all product reviews with a rating of 1 and helpful votes equal to 0.
DELETE FROM Sales.ProductReviews
WHERE Rating = 1 AND HelpfulVotes = 0;

--9.2 Delete products that have never been ordered, using a NOT EXISTS condition with Sales.SalesOrderDetail.

DELETE FROM Production.Product
WHERE NOT EXISTS (
    SELECT 1 
    FROM Sales.SalesOrderDetail sod
    WHERE sod.ProductID = Production.Product.ProductID
)
AND NOT EXISTS (
    SELECT 1 
    FROM Production.BillOfMaterials bom
    WHERE bom.ComponentID = Production.Product.ProductID
       OR bom.ProductAssemblyID = Production.Product.ProductID
)
AND NOT EXISTS (
    SELECT 1 
    FROM Production.ProductInventory pi
    WHERE pi.ProductID = Production.Product.ProductID
)
AND NOT EXISTS (
    SELECT 1
    FROM Production.ProductCostHistory pch
    WHERE pch.ProductID = Production.Product.ProductID
);

--9.3 Delete all purchase orders from vendors that are no longer active.

DELETE pod
FROM Purchasing.PurchaseOrderDetail pod
JOIN Purchasing.PurchaseOrderHeader poh ON pod.PurchaseOrderID = poh.PurchaseOrderID
JOIN Purchasing.Vendor v ON poh.VendorID = v.BusinessEntityID
WHERE v.ActiveFlag = 0;


DELETE poh
FROM Purchasing.PurchaseOrderHeader poh
JOIN Purchasing.Vendor v ON poh.VendorID = v.BusinessEntityID
WHERE v.ActiveFlag = 0;


--10.1 Calculate the total sales amount by year from 2011 to 2014, showing year, total sales, average order value, and order count.
SELECT 
    YEAR(OrderDate) AS OrderYear,
    SUM(TotalDue) AS TotalSales,
    AVG(TotalDue) AS AvgOrderValue,
    COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) BETWEEN 2011 AND 2014
GROUP BY YEAR(OrderDate)
ORDER BY OrderYear;

--10.2 For each customer, show customer ID, total orders, total amount, average order value, first order date, and last order date.
SELECT 
    CustomerID,
    COUNT(SalesOrderID) AS TotalOrders,
    SUM(TotalDue) AS TotalAmount,
    AVG(TotalDue) AS AvgOrderValue,
    MIN(OrderDate) AS FirstOrderDate,
    MAX(OrderDate) AS LastOrderDate
FROM Sales.SalesOrderHeader
GROUP BY CustomerID;

--10.3 List the top 20 products by total sales amount, including product name, category, total quantity sold, and total revenue.
SELECT TOP 20
    p.Name AS ProductName,
    pc.Name AS Category,
    SUM(sod.OrderQty) AS TotalQtySold,
    SUM(sod.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY p.Name, pc.Name
ORDER BY TotalRevenue DESC;

--10.4 Show sales amount by month for 2013, displaying the month name, sales amount, and percentage of the yearly total.
WITH MonthlySales AS (
    SELECT 
        DATENAME(MONTH, OrderDate) AS MonthName,
        MONTH(OrderDate) AS MonthNumber,
        SUM(TotalDue) AS SalesAmount
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) = 2013
    GROUP BY DATENAME(MONTH, OrderDate), MONTH(OrderDate)
),
YearlyTotal AS (
    SELECT SUM(SalesAmount) AS Total2013 FROM MonthlySales
)
SELECT 
    m.MonthName,
    m.SalesAmount,
    ROUND(m.SalesAmount * 100.0 / y.Total2013, 2) AS PercentageOfYear
FROM MonthlySales m, YearlyTotal y
ORDER BY m.MonthNumber;

--11.1 Show employees with their full name, age in years, years of service, hire date formatted as 'Mon DD, YYYY', and birth month name.
SELECT 
    p.FirstName + ' ' + p.LastName AS FullName,
    DATEDIFF(YEAR, e.BirthDate, GETDATE()) AS Age,
    DATEDIFF(YEAR, e.HireDate, GETDATE()) AS YearsOfService,
    FORMAT(e.HireDate, 'MMM dd, yyyy') AS FormattedHireDate,
    DATENAME(MONTH, e.BirthDate) AS BirthMonth
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID;

--11.2 Format customer names as 'LAST, First M.' (with middle initial), extract the email domain, and apply proper case formatting.
SELECT 
    UPPER(p.LastName) + ', ' + 
    UPPER(LEFT(p.FirstName, 1)) + LOWER(SUBSTRING(p.FirstName, 2, LEN(p.FirstName))) + ' ' +
    UPPER(LEFT(p.MiddleName, 1)) + '.' AS FormattedName,
    RIGHT(e.EmailAddress, LEN(e.EmailAddress) - CHARINDEX('@', e.EmailAddress)) AS EmailDomain
FROM Person.Person p
JOIN Person.EmailAddress e ON p.BusinessEntityID = e.BusinessEntityID
WHERE p.MiddleName IS NOT NULL;

--11.3 For each product, show name, weight rounded to one decimal, weight in pounds (converted from grams), and price per pound.
SELECT 
    Name,
    ROUND(Weight, 1) AS WeightKg,
    ROUND(Weight * 2.20462, 1) AS WeightLbs,
    CASE 
        WHEN Weight IS NOT NULL AND Weight > 0 
        THEN ROUND(ListPrice / (Weight * 2.20462), 2)
        ELSE NULL
    END AS PricePerPound
FROM Production.Product;

--12.1 List product name, category, subcategory, and vendor name for products that have been purchased from vendors.
SELECT 
    p.Name AS ProductName,
    pc.Name AS Category,
    ps.Name AS Subcategory,
    v.Name AS VendorName
FROM Production.Product p
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID;

--12.2 Show order details including order ID, customer name, salesperson name, territory name, product name, quantity, and line total.
SELECT 
    soh.SalesOrderID,
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS CustomerName,
    sp.FirstName + ' ' + sp.LastName AS SalespersonName,
    st.Name AS Territory,
    pr.Name AS ProductName,
    sod.OrderQty,
    sod.LineTotal
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesPerson s ON soh.SalesPersonID = s.BusinessEntityID
JOIN Person.Person sp ON s.BusinessEntityID = sp.BusinessEntityID
JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID;

--12.3 List employees with their sales territories, including employee name, job title, territory name, territory group, and sales year-to-date.
SELECT 
    p.FirstName + ' ' + p.LastName AS EmployeeName,
    e.JobTitle,
    st.Name AS TerritoryName,
    st.[Group] AS TerritoryGroup,
    s.SalesYTD
FROM Sales.SalesPerson s
JOIN HumanResources.Employee e ON s.BusinessEntityID = e.BusinessEntityID
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
JOIN Sales.SalesTerritory st ON s.TerritoryID = st.TerritoryID;


--13.1 List all products with their total sales, including those never sold. Show product name, category, total quantity sold (zero if never sold), and total revenue (zero if never sold).
SELECT 
    p.Name AS ProductName,
    pc.Name AS Category,
    COALESCE(SUM(sod.OrderQty), 0) AS TotalQty,
    COALESCE(SUM(sod.LineTotal), 0) AS TotalRevenue
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
LEFT JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
LEFT JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
GROUP BY p.Name, pc.Name;

--13.2 Show all sales territories with their assigned employees, including unassigned territories. Show territory name, employee name (null if unassigned), and sales year-to-date.
SELECT 
    st.Name AS Territory,
    p.FirstName + ' ' + p.LastName AS EmployeeName,
    s.SalesYTD
FROM Sales.SalesTerritory st
LEFT JOIN Sales.SalesPerson s ON st.TerritoryID = s.TerritoryID
LEFT JOIN Person.Person p ON s.BusinessEntityID = p.BusinessEntityID;

--13.3 Show the relationship between vendors and product categories, including vendors with no products and categories with no vendors.
SELECT 
    v.Name AS VendorName,
    pc.Name AS CategoryName
FROM Purchasing.Vendor v
FULL JOIN Purchasing.ProductVendor pv ON v.BusinessEntityID = pv.BusinessEntityID
FULL JOIN Production.Product p ON pv.ProductID = p.ProductID
FULL JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
FULL JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID;

--14.1 List products with above-average list price, showing product ID, name, list price, and price difference from the average.
SELECT 
    ProductID,
    Name,
    ListPrice,
    ListPrice - (SELECT AVG(ListPrice) FROM Production.Product WHERE ListPrice > 0) AS PriceDifference
FROM Production.Product
WHERE ListPrice > (SELECT AVG(ListPrice) FROM Production.Product WHERE ListPrice > 0);

--14.2 List customers who bought products from the 'Mountain' category, showing customer name, total orders, and total amount spent.
SELECT 
    p.FirstName + ' ' + p.LastName AS CustomerName,
    COUNT(DISTINCT soh.SalesOrderID) AS TotalOrders,
    SUM(sod.LineTotal) AS TotalSpent
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
WHERE pr.Name LIKE '%Mountain%'
GROUP BY p.FirstName, p.LastName;

--14.3 List products that have been ordered by more than 100 different customers, showing product name, category, and unique customer count.
SELECT 
    pr.Name AS ProductName,
    pc.Name AS Category,
    COUNT(DISTINCT soh.CustomerID) AS UniqueCustomerCount
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
JOIN Production.ProductSubcategory ps ON pr.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pr.Name, pc.Name
HAVING COUNT(DISTINCT soh.CustomerID) > 100;

--14.4 For each customer, show their order count and their rank among all customers.
SELECT 
    c.CustomerID,
    COUNT(soh.SalesOrderID) AS OrderCount,
    RANK() OVER (ORDER BY COUNT(soh.SalesOrderID) DESC) AS CustomerRank
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID;
-- 15.1
CREATE VIEW vw_ProductCatalog AS
SELECT 
    p.ProductID,
    p.Name,
    p.ProductNumber,
    pc.Name AS Category,
    ps.Name AS Subcategory,
    p.ListPrice,
    p.StandardCost,
    ROUND(CASE WHEN p.StandardCost > 0 THEN ((p.ListPrice - p.StandardCost) / p.StandardCost) * 100 ELSE 0 END, 2) AS ProfitMarginPercentage,
    ISNULL(pi.Quantity, 0) AS InventoryLevel,
    CASE WHEN p.SellEndDate IS NULL THEN 'Active' ELSE 'Discontinued' END AS Status
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
LEFT JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
LEFT JOIN Production.ProductInventory pi ON p.ProductID = pi.ProductID;

-- 15.2
CREATE VIEW vw_SalesAnalysis AS
SELECT 
    YEAR(OrderDate) AS [Year],
    MONTH(OrderDate) AS [Month],
    st.Name AS Territory,
    SUM(TotalDue) AS TotalSales,
    COUNT(*) AS OrderCount,
    AVG(TotalDue) AS AvgOrderValue,
    (SELECT TOP 1 p.Name
     FROM Sales.SalesOrderDetail sod
     JOIN Production.Product p ON sod.ProductID = p.ProductID
     WHERE sod.SalesOrderID = soh.SalesOrderID
     ORDER BY sod.LineTotal DESC) AS TopProductName
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
GROUP BY YEAR(OrderDate), MONTH(OrderDate), st.Name;

-- 15.3
CREATE VIEW vw_EmployeeDirectory AS
SELECT 
    p.FirstName + ' ' + p.LastName AS FullName,
    e.JobTitle,
    d.Name AS Department,
    m.FirstName + ' ' + m.LastName AS ManagerName,
    e.HireDate,
    DATEDIFF(YEAR, e.HireDate, GETDATE()) AS YearsOfService,
    ea.EmailAddress,
    pp.PhoneNumber
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID AND edh.EndDate IS NULL
JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
LEFT JOIN HumanResources.Employee mng ON e.ManagerID = mng.BusinessEntityID
LEFT JOIN Person.Person m ON mng.BusinessEntityID = m.BusinessEntityID
LEFT JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID
LEFT JOIN Person.PersonPhone pp ON p.BusinessEntityID = pp.BusinessEntityID;

-- 15.4
-- a. List active products with high profit margins
SELECT * FROM vw_ProductCatalog
WHERE ProfitMarginPercentage > 50 AND Status = 'Active';

-- b. Monthly sales summary by territory
SELECT * FROM vw_SalesAnalysis
WHERE [Year] = 2013 AND Territory = 'Northwest';

-- c. Employees with 10+ years of service
SELECT * FROM vw_EmployeeDirectory
WHERE YearsOfService >= 10;

-- 16.1
SELECT 
    CASE 
        WHEN ListPrice > 500 THEN 'Premium'
        WHEN ListPrice BETWEEN 100 AND 500 THEN 'Standard'
        ELSE 'Budget'
    END AS PriceCategory,
    COUNT(*) AS ProductCount,
    AVG(ListPrice) AS AvgPrice
FROM Production.Product
GROUP BY 
    CASE 
        WHEN ListPrice > 500 THEN 'Premium'
        WHEN ListPrice BETWEEN 100 AND 500 THEN 'Standard'
        ELSE 'Budget'
    END;

-- 16.2
SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, HireDate, GETDATE()) >= 10 THEN 'Veteran'
        WHEN DATEDIFF(YEAR, HireDate, GETDATE()) BETWEEN 5 AND 9 THEN 'Experienced'
        WHEN DATEDIFF(YEAR, HireDate, GETDATE()) BETWEEN 2 AND 4 THEN 'Regular'
        ELSE 'New'
    END AS ServiceCategory,
    COUNT(*) AS EmployeeCount
FROM HumanResources.Employee
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, HireDate, GETDATE()) >= 10 THEN 'Veteran'
        WHEN DATEDIFF(YEAR, HireDate, GETDATE()) BETWEEN 5 AND 9 THEN 'Experienced'
        WHEN DATEDIFF(YEAR, HireDate, GETDATE()) BETWEEN 2 AND 4 THEN 'Regular'
        ELSE 'New'
    END;
-- 16.3
SELECT 
    CASE 
        WHEN TotalDue > 5000 THEN 'Large'
        WHEN TotalDue BETWEEN 1000 AND 5000 THEN 'Medium'
        ELSE 'Small'
    END AS OrderSize,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Sales.SalesOrderHeader) AS Percentage
FROM Sales.SalesOrderHeader
GROUP BY 
    CASE 
        WHEN TotalDue > 5000 THEN 'Large'
        WHEN TotalDue BETWEEN 1000 AND 5000 THEN 'Medium'
        ELSE 'Small'
    END;
-- 17.1
SELECT 
    Name,
    ISNULL(CAST(Weight AS VARCHAR), 'Not Specified') AS Weight,
    ISNULL(Size, 'Standard') AS Size,
    ISNULL(Color, 'Natural') AS Color
FROM Production.Product;

-- 17.2
SELECT 
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS FullName,
    COALESCE(ea.EmailAddress, pp.PhoneNumber, a.AddressLine1) AS BestContact
FROM Sales.Customer c
LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Person.EmailAddress ea ON p.BusinessEntityID = ea.BusinessEntityID
LEFT JOIN Person.PersonPhone pp ON p.BusinessEntityID = pp.BusinessEntityID
LEFT JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
LEFT JOIN Person.Address a ON bea.AddressID = a.AddressID;

--17.3 Find products where weight is null but size is not null, and also find products where both weight and size are null. Discuss the impact on inventory management.
SELECT 
    p.Name AS ProductName,
    SUM(CASE WHEN YEAR(OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END) AS Sales2013,
    SUM(CASE WHEN YEAR(OrderDate) = 2014 THEN sod.LineTotal ELSE 0 END) AS Sales2014,
    ROUND(
        CASE 
            WHEN SUM(CASE WHEN YEAR(OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END) = 0 THEN NULL
            ELSE (SUM(CASE WHEN YEAR(OrderDate) = 2014 THEN sod.LineTotal ELSE 0 END) - 
                  SUM(CASE WHEN YEAR(OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END)) * 100.0 /
                  SUM(CASE WHEN YEAR(OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END)
        END, 2
    ) AS GrowthPercentage,
    CASE 
        WHEN SUM(CASE WHEN YEAR(OrderDate) = 2014 THEN sod.LineTotal ELSE 0 END) >
             SUM(CASE WHEN YEAR(OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END)
        THEN 'Increased'
        ELSE 'Decreased'
    END AS GrowthCategory
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE YEAR(OrderDate) IN (2013, 2014)
GROUP BY p.Name;

--18.1 Create a recursive query to show the complete employee hierarchy, including employee name, manager name, hierarchy level, and path.
WITH EmployeeHierarchy AS (
    SELECT 
        e.BusinessEntityID,
        p.FirstName + ' ' + p.LastName AS EmployeeName,
        e.ManagerID,
        0 AS HierarchyLevel,
        CAST(p.FirstName + ' ' + p.LastName AS VARCHAR(MAX)) AS Path
    FROM HumanResources.Employee e
    JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
    WHERE e.ManagerID IS NULL

    UNION ALL

    SELECT 
        e.BusinessEntityID,
        p.FirstName + ' ' + p.LastName,
        e.ManagerID,
        eh.HierarchyLevel + 1,
        CAST(eh.Path + ' > ' + p.FirstName + ' ' + p.LastName AS VARCHAR(MAX))
    FROM HumanResources.Employee e
    JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
    JOIN EmployeeHierarchy eh ON e.ManagerID = eh.BusinessEntityID
)
SELECT * FROM EmployeeHierarchy ORDER BY Path;

--18.2 Create a query to compare year-over-year sales for each product, showing product, sales for 2013, sales for 2014, growth percentage, and growth category.
SELECT 
    p.Name AS ProductName,
    SUM(CASE WHEN YEAR(OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END) AS Sales2013,
    SUM(CASE WHEN YEAR(OrderDate) = 2014 THEN sod.LineTotal ELSE 0 END) AS Sales2014,
    ROUND(
        CASE 
            WHEN SUM(CASE WHEN YEAR(OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END) = 0 THEN NULL
            ELSE (SUM(CASE WHEN YEAR(OrderDate) = 2014 THEN sod.LineTotal ELSE 0 END) - 
                  SUM(CASE WHEN YEAR(OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END)) * 100.0 /
                  SUM(CASE WHEN YEAR(OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END)
        END, 2
    ) AS GrowthPercentage,
    CASE 
        WHEN SUM(CASE WHEN YEAR(OrderDate) = 2014 THEN sod.LineTotal ELSE 0 END) >
             SUM(CASE WHEN YEAR(OrderDate) = 2013 THEN sod.LineTotal ELSE 0 END)
        THEN 'Increased'
        ELSE 'Decreased'
    END AS GrowthCategory
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE YEAR(OrderDate) IN (2013, 2014)
GROUP BY p.Name;

--19.1 Rank products by sales within each category, showing product name, category, sales amount, rank, dense rank, and row number.
SELECT 
    pc.Name AS Category,
    p.Name AS ProductName,
    SUM(sod.LineTotal) AS SalesAmount,
    RANK() OVER (PARTITION BY pc.Name ORDER BY SUM(sod.LineTotal) DESC) AS SalesRank,
    DENSE_RANK() OVER (PARTITION BY pc.Name ORDER BY SUM(sod.LineTotal) DESC) AS DenseRank,
    ROW_NUMBER() OVER (PARTITION BY pc.Name ORDER BY SUM(sod.LineTotal) DESC) AS RowNumber
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name, p.Name;

--19.2 Show the running total of sales by month for 2013, displaying month, monthly sales, running total, and percentage of year-to-date.
SELECT 
    FORMAT(OrderDate, 'yyyy-MM') AS Month,
    SUM(TotalDue) AS MonthlySales,
    SUM(SUM(TotalDue)) OVER (ORDER BY FORMAT(OrderDate, 'yyyy-MM')) AS RunningTotal,
    ROUND(
        100.0 * SUM(SUM(TotalDue)) OVER (ORDER BY FORMAT(OrderDate, 'yyyy-MM')) /
        SUM(TotalDue) OVER (), 2
    ) AS PercentOfYTD
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013
GROUP BY FORMAT(OrderDate, 'yyyy-MM');

--19.3 Show the three-month moving average of sales for each territory, displaying territory, month, sales, and moving average.
SELECT 
    st.Name AS Territory,
    FORMAT(soh.OrderDate, 'yyyy-MM') AS [Month],
    SUM(soh.TotalDue) AS MonthlySales,
    AVG(SUM(soh.TotalDue)) OVER (
        PARTITION BY st.Name
        ORDER BY FORMAT(soh.OrderDate, 'yyyy-MM')
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS MovingAverage
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
GROUP BY st.Name, FORMAT(soh.OrderDate, 'yyyy-MM');

--19.4 Show month-over-month sales growth, displaying month, sales, previous month sales, growth amount, and growth percentage.
WITH MonthlySales AS (
    SELECT 
        FORMAT(OrderDate, 'yyyy-MM') AS [Month],
        SUM(TotalDue) AS Sales
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) = 2013
    GROUP BY FORMAT(OrderDate, 'yyyy-MM')
)
SELECT 
    [Month],
    Sales,
    LAG(Sales) OVER (ORDER BY [Month]) AS PrevMonthSales,
    Sales - LAG(Sales) OVER (ORDER BY [Month]) AS GrowthAmount,
    ROUND(
        100.0 * (Sales - LAG(Sales) OVER (ORDER BY [Month])) / 
        NULLIF(LAG(Sales) OVER (ORDER BY [Month]), 0), 2
    ) AS GrowthPercentage
FROM MonthlySales;

--19.5 Divide customers into four quartiles based on total purchase amount, showing customer name, total purchases, quartile, and quartile average.
WITH CustomerTotals AS (
    SELECT 
        c.CustomerID,
        p.FirstName + ' ' + p.LastName AS CustomerName,
        SUM(soh.TotalDue) AS TotalPurchases
    FROM Sales.Customer c
    JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
    JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
    GROUP BY c.CustomerID, p.FirstName, p.LastName
)
SELECT 
    CustomerName,
    TotalPurchases,
    NTILE(4) OVER (ORDER BY TotalPurchases DESC) AS Quartile,
    AVG(TotalPurchases) OVER (PARTITION BY NTILE(4) OVER (ORDER BY TotalPurchases DESC)) AS QuartileAverage
FROM CustomerTotals;

--20.1 Create a pivot table showing product categories as rows and years (2011-2014) as columns, displaying sales amounts with totals.
SELECT *
FROM (
    SELECT 
        pc.Name AS Category,
        YEAR(soh.OrderDate) AS SalesYear,
        sod.LineTotal AS SalesAmount
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
    JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    WHERE YEAR(soh.OrderDate) BETWEEN 2011 AND 2014
) AS SourceTable
PIVOT (
    SUM(SalesAmount)
    FOR SalesYear IN ([2011], [2012], [2013], [2014])
) AS PivotTable;

--20.2 Create a pivot table showing departments as rows and gender as columns, displaying employee count by department and gender.
SELECT *
FROM (
    SELECT 
        d.Name AS Department,
        e.Gender
    FROM HumanResources.Employee e
    JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
    JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
    WHERE edh.EndDate IS NULL
) AS SourceTable
PIVOT (
    COUNT(Gender)
    FOR Gender IN ([M], [F])
) AS PivotTable;

--20.3 Create a dynamic pivot table for quarterly sales, automatically handling an unknown number of quarters.

--21.1 Find products sold in both 2013 and 2014, and combine with products sold only in 2013, showing a complete analysis.
-- Sold in both 2013 and 2014
SELECT DISTINCT p.Name, 'Sold in Both Years' AS SaleStatus
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE YEAR(soh.OrderDate) = 2013
INTERSECT
SELECT DISTINCT p.Name, 'Sold in Both Years'
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE YEAR(soh.OrderDate) = 2014

UNION

-- Sold only in 2013
SELECT DISTINCT p.Name, 'Only 2013'
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE YEAR(soh.OrderDate) = 2013
EXCEPT
SELECT DISTINCT p.Name, 'Only 2013'
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE YEAR(soh.OrderDate) = 2014;

--21.2 Compare product categories with high-value products (greater than $1000) to those with high-volume sales (more than 1000 units sold), using set operations.
-- High-value categories (price > $1000)
SELECT DISTINCT pc.Name AS Category, 'High-Value' AS CategoryType
FROM Production.Product p
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE p.ListPrice > 1000

UNION

-- High-volume categories (> 1000 units sold)
SELECT pc.Name, 'High-Volume'
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
HAVING SUM(sod.OrderQty) > 1000;

--22.1 Declare variables for the current year, total sales, and average order value, and display year-to-date statistics with formatted output.
DECLARE @CurrentYear INT = YEAR(GETDATE());
DECLARE @TotalSales MONEY;
DECLARE @AvgOrderValue MONEY;

SELECT 
    @TotalSales = SUM(TotalDue),
    @AvgOrderValue = AVG(TotalDue)
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = @CurrentYear;

PRINT 'Year: ' + CAST(@CurrentYear AS VARCHAR);
PRINT 'Total Sales: $' + CAST(@TotalSales AS VARCHAR);
PRINT 'Average Order Value: $' + CAST(@AvgOrderValue AS VARCHAR);

--22.2 Check if a specific product exists in inventory. If it exists, show details; if not, suggest similar products.     22.3 Generate a monthly sales summary for each month in 2013 using a loop.
DECLARE @ProductName NVARCHAR(100) = 'Road-150 Red, 62';

IF EXISTS (
    SELECT 1 FROM Production.Product WHERE Name = @ProductName
)
    SELECT * FROM Production.Product WHERE Name = @ProductName;
ELSE
    SELECT TOP 3 * FROM Production.Product WHERE Name LIKE '%Road%' AND Name <> @ProductName;

--22.4 Implement error handling for a product price update operation, including logging errors and rolling back on failure.
BEGIN TRY
    BEGIN TRANSACTION

    UPDATE Production.Product
    SET ListPrice = ListPrice * 1.1
    WHERE ProductID = 707;

    -- Insert into audit log
    INSERT INTO dbo.ProductPriceAudit(ProductID, ChangedDate)
    VALUES (707, GETDATE());

    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH

--23.1 Create a scalar function to calculate customer lifetime value, including total amount spent and weighted recent activity, with parameters for date range and activity weight.
CREATE FUNCTION dbo.fn_CustomerLTV (
    @CustomerID INT,
    @FromDate DATE,
    @ToDate DATE,
    @Weight FLOAT
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @LTV FLOAT;

    SELECT @LTV = SUM(TotalDue) + MAX(TotalDue) * @Weight
    FROM Sales.SalesOrderHeader
    WHERE CustomerID = @CustomerID AND OrderDate BETWEEN @FromDate AND @ToDate;

    RETURN ISNULL(@LTV, 0);
END;

--23.2 Create a multi-statement table-valued function to return products by price range and category, including error handling for invalid parameters.
CREATE FUNCTION dbo.fn_GetProductsByPriceAndCategory (
    @MinPrice MONEY,
    @MaxPrice MONEY,
    @CategoryName NVARCHAR(100)
)
RETURNS @Result TABLE (
    ProductID INT,
    Name NVARCHAR(100),
    ListPrice MONEY,
    Category NVARCHAR(100)
)
AS
BEGIN
    IF @MinPrice < 0 OR @MaxPrice < 0
        RETURN;

    INSERT INTO @Result
    SELECT 
        p.ProductID, p.Name, p.ListPrice, pc.Name
    FROM Production.Product p
    JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
    WHERE p.ListPrice BETWEEN @MinPrice AND @MaxPrice
      AND pc.Name = @CategoryName;

    RETURN;
END;

--23.3 Create an inline table-valued function to return all employees under a specific manager, including hierarchy level and employee path.
CREATE FUNCTION dbo.fn_GetEmployeesByManager (
    @ManagerID INT
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        e.BusinessEntityID,
        p.FirstName + ' ' + p.LastName AS EmployeeName,
        e.JobTitle,
        e.HireDate
    FROM HumanResources.Employee e
    JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
    WHERE e.BusinessEntityID= @ManagerID
);

--24.1 Create a stored procedure to get products by category, with parameters for category name, minimum price, and maximum price, including parameter validation and error handling.
CREATE PROCEDURE dbo.sp_GetProductsByCategory
    @Category NVARCHAR(100),
    @MinPrice MONEY,
    @MaxPrice MONEY
AS
BEGIN
    IF @MinPrice < 0 OR @MaxPrice < 0 OR @MinPrice > @MaxPrice
    BEGIN
        RAISERROR('Invalid price range.', 16, 1);
        RETURN;
    END

    SELECT 
        p.ProductID, p.Name, p.ListPrice, pc.Name AS Category
    FROM Production.Product p
    JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
    WHERE pc.Name = @Category AND p.ListPrice BETWEEN @MinPrice AND @MaxPrice;
END;

--24.2 Create a stored procedure to update product pricing, including an audit trail, business rule validation, and transaction management.
CREATE PROCEDURE dbo.sp_UpdateProductPrice
    @ProductID INT,
    @NewPrice MONEY
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OldPrice MONEY;

        SELECT @OldPrice = ListPrice FROM Production.Product WHERE ProductID = @ProductID;

        UPDATE Production.Product
        SET ListPrice = @NewPrice
        WHERE ProductID = @ProductID;

        INSERT INTO dbo.ProductPriceAudit(ProductID, OldPrice, NewPrice, ChangeDate)
        VALUES (@ProductID, @OldPrice, @NewPrice, GETDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

--24.3 Create a stored procedure to generate a comprehensive sales report for a given date range and territory, including summary statistics and detailed breakdowns.
CREATE PROCEDURE dbo.sp_SalesReportByDateAndTerritory
    @StartDate DATE,
    @EndDate DATE,
    @Territory NVARCHAR(100)
AS
BEGIN
    SELECT 
        st.Name AS Territory,
        soh.OrderDate,
        COUNT(DISTINCT soh.SalesOrderID) AS OrderCount,
        SUM(soh.TotalDue) AS TotalSales,
        AVG(soh.TotalDue) AS AvgOrderValue
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
    WHERE soh.OrderDate BETWEEN @StartDate AND @EndDate
      AND st.Name = @Territory
    GROUP BY st.Name, soh.OrderDate
    ORDER BY soh.OrderDate;
END;

--24.4 Create a stored procedure to process bulk orders from XML input, including transaction management, validation, error handling, and returning order confirmation details.
-- Assume we already have a sample XML format and table
-- Bulk order processing with validation and transaction
CREATE PROCEDURE dbo.sp_ProcessBulkOrders
    @OrdersXml XML
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Extract data from XML
        INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, OrderQty, UnitPrice)
        SELECT 
            T.Item.value('(SalesOrderID)[1]', 'INT'),
            T.Item.value('(ProductID)[1]', 'INT'),
            T.Item.value('(OrderQty)[1]', 'INT'),
            T.Item.value('(UnitPrice)[1]', 'MONEY')
        FROM @OrdersXml.nodes('/Orders/Order') AS T(Item);

        COMMIT TRANSACTION;
        PRINT 'Orders processed successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;

--24.5 Create a stored procedure to perform flexible product searches with dynamic filtering by name, category, price range, and date range, returning paginated results and total count.
CREATE PROCEDURE dbo.sp_SearchProducts
    @Name NVARCHAR(100) = NULL,
    @Category NVARCHAR(100) = NULL,
    @MinPrice MONEY = NULL,
    @MaxPrice MONEY = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    WITH Filtered AS (
        SELECT 
            p.ProductID, p.Name, p.ListPrice, p.SellStartDate,
            pc.Name AS Category,
            ROW_NUMBER() OVER (ORDER BY p.Name) AS RowNum
        FROM Production.Product p
        JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
        WHERE (@Name IS NULL OR p.Name LIKE '%' + @Name + '%')
          AND (@Category IS NULL OR pc.Name = @Category)
          AND (@MinPrice IS NULL OR p.ListPrice >= @MinPrice)
          AND (@MaxPrice IS NULL OR p.ListPrice <= @MaxPrice)
          AND (@StartDate IS NULL OR p.SellStartDate >= @StartDate)
          AND (@EndDate IS NULL OR p.SellStartDate <= @EndDate)
    )
    SELECT * FROM Filtered
    WHERE RowNum BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize);
END;

--25.1 Create a trigger on Sales.SalesOrderDetail to update product inventory and maintain sales statistics after insert, including error handling and transaction management.
CREATE TRIGGER trg_UpdateInventory_AfterInsert
ON Sales.SalesOrderDetail
AFTER INSERT
AS
BEGIN
    BEGIN TRY
        UPDATE pi
        SET pi.Quantity = pi.Quantity - i.OrderQty
        FROM Production.ProductInventory pi
        JOIN inserted i ON pi.ProductID = i.ProductID;

        -- Optional: insert stats into log
        INSERT INTO dbo.SalesStatsLog(ProductID, OrderQty, ModifiedDate)
        SELECT ProductID, OrderQty, GETDATE()
        FROM inserted;
    END TRY
    BEGIN CATCH
        PRINT 'Trigger failed: ' + ERROR_MESSAGE();
    END CATCH
END;

--25.2 Create a view combining multiple tables and implement an INSTEAD OF trigger for insert operations, handling complex business logic and data distribution.
-- Assume we have a view that joins customer and order data
-- This trigger handles insert logic manually
CREATE VIEW dbo.vw_CustomerOrders AS
SELECT 
    c.CustomerID,
    c.PersonID,
    c.StoreID,
    c.TerritoryID,
    soh.SalesOrderID,
    soh.OrderDate
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID;


CREATE TRIGGER trg_InsteadOfInsert_View
ON dbo.vw_CustomerOrders
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO Sales.Customer (PersonID, StoreID, TerritoryID)
    SELECT PersonID, StoreID, TerritoryID FROM inserted;

 
END;

--25.3 Create an audit trigger for Production.Product price changes, logging old and new values with timestamp and user information.
CREATE TRIGGER trg_AuditPriceChange
ON Production.Product
AFTER UPDATE
AS
BEGIN
    IF UPDATE(ListPrice)
    BEGIN
        INSERT INTO dbo.ProductPriceAudit
        (
            ProductID, 
            OldPrice, 
            NewPrice, 
            ModifiedDate, 
            ModifiedBy
        )
        SELECT 
            d.ProductID,
            d.ListPrice,
            i.ListPrice,
            GETDATE(),
            SYSTEM_USER
        FROM deleted d
        JOIN inserted i ON d.ProductID = i.ProductID;
    END
END;

--26.1 Create a filtered index for active products only (SellEndDate IS NULL) and for recent orders (last 2 years), and measure performance impact.
-- Active products
CREATE NONCLUSTERED INDEX IX_Product_ActiveOnly
ON Production.Product(Name)
WHERE SellEndDate IS NULL;


-- Recent orders (last 2 years)
CREATE NONCLUSTERED INDEX IX_RecentOrders
ON Sales.SalesOrderHeader(OrderDate)
WHERE OrderDate >= '2023-07-19';
