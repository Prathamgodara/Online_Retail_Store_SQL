-- Create the database
CREATE DATABASE OnlineRetailDB;
GO

-- Use the database
USE OnlineRetailDB;
Go

-- Create the Customers table
CREATE TABLE Customers (
	CustomerID INT PRIMARY KEY IDENTITY(1,1),
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	Email NVARCHAR(100),
	Phone NVARCHAR(50),
	Address NVARCHAR(255),
	City NVARCHAR(50),
	State NVARCHAR(50),
	ZipCode NVARCHAR(50),
	Country NVARCHAR(50),
	CreatedAt DATETIME DEFAULT GETDATE()
);

-- Create the Products table
CREATE TABLE Products (
	ProductID INT PRIMARY KEY IDENTITY(1,1),
	ProductName NVARCHAR(100),
	CategoryID INT,
	Price DECIMAL(10,2),
	Stock INT,
	CreatedAt DATETIME DEFAULT GETDATE()
);

-- Create the Categories table
CREATE TABLE Categories (
	CategoryID INT PRIMARY KEY IDENTITY(1,1),
	CategoryName NVARCHAR(100),
	Description NVARCHAR(255)
);

-- Create the Orders table
CREATE TABLE Orders (
	OrderId INT PRIMARY KEY IDENTITY(1,1),
	CustomerId INT,
	OrderDate DATETIME DEFAULT GETDATE(),
	TotalAmount DECIMAL(10,2),
	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Alter / Rename the Column Name
EXEC sp_rename 'OnlineRetailDB.dbo.Orders.CustomerId', 'CustomerID', 'COLUMN'; 

-- Create the OrderItems table
CREATE TABLE OrderItems (
	OrderItemID INT PRIMARY KEY IDENTITY(1,1),
	OrderID INT,
	ProductID INT,
	Quantity INT,
	Price DECIMAL(10,2),
	FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
	FOREIGN KEY (OrderId) REFERENCES Orders(OrderID)
);

-- Insert sample data into Categories table
INSERT INTO Categories (CategoryName, Description) 
VALUES 
('Electronics', 'Devices and Gadgets'),
('Clothing', 'Apparel and Accessories'),
('Books', 'Printed and Electronic Books');

-- Insert sample data into Products table
INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES 
('Smartphone', 1, 699.99, 50),
('Laptop', 1, 999.99, 30),
('T-shirt', 2, 19.99, 100),
('Jeans', 2, 49.99, 60),
('Fiction Novel', 3, 14.99, 200),
('Science Journal', 3, 29.99, 150);

-- Insert sample data into Customers table
INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
('Sameer', 'Khanna', 'sameer.khanna@example.com', '123-456-7890', '123 Elm St.', 'Springfield', 
'IL', '62701', 'USA'),
('Jane', 'Smith', 'jane.smith@example.com', '234-567-8901', '456 Oak St.', 'Madison', 
'WI', '53703', 'USA'),
('harshad', 'patel', 'harshad.patel@example.com', '345-678-9012', '789 Dalal St.', 'Mumbai', 
'Maharashtra', '41520', 'INDIA');

-- Insert sample data into Orders table
INSERT INTO Orders(CustomerId, OrderDate, TotalAmount)
VALUES 
(1, GETDATE(), 719.98),
(2, GETDATE(), 49.99),
(3, GETDATE(), 44.98);

-- Insert sample data into OrderItems table
INSERT INTO OrderItems(OrderID, ProductID, Quantity, Price)
VALUES 
(1, 1, 1, 699.99),
(1, 3, 1, 19.99),
(2, 4, 1,  49.99),
(3, 5, 1, 14.99),
(3, 6, 1, 29.99);

SET IDENTITY_INSERT Products ON;
INSERT INTO Products(ProductID, ProductName, CategoryID, Price, Stock) 
VALUES (7, 'Keyboard', 1, 39.99, 0);
SET IDENTITY_INSERT Products OFF;


SET IDENTITY_INSERT Customers ON;
INSERT INTO Customers(CustomerID ,FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
(4, 'Ishwar', 'Panchariya', 'Ishwar@example.com', '9960134220', '123 Elm St.', 'Springfield', 
'IL', '62701', 'USA');
SET IDENTITY_INSERT Customers OFF;



SET IDENTITY_INSERT Orders ON;
INSERT INTO Orders(OrderId, CustomerId, OrderDate, TotalAmount)
VALUES 
(4, 4, GETDATE(), 3499.95)
SET IDENTITY_INSERT Orders OFF;

--Query 1: Retrieve all orders for a specific customer

SELECT o.OrderID, o.OrderDate, o.TotalAmount, oi.ProductID, p.ProductName, oi.Quantity, oi.Price
FROM Orders o
JOIN OrderItems oi ON o.OrderId = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID
WHERE o.CustomerID = 1;

--Query 2: Find the total sales for each product

SELECT p.ProductID, p.ProductName, SUM(oi.Quantity * oi.Price) AS TotalSales
FROM OrderItems oi
JOIN Products p 
ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalSales DESC;

--Query 3: Calculate the average order value

SELECT AVG(TotalAmount) AS AverageOrderValue FROM Orders;

--Query 4: List the top 5 customers by  total spending

SELECT c.CustomerID, c.FirstName, c.LastName , sum(o.TotalAmount) as TotalSpent FROM Customers as c
JOIN Orders as o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
ORDER BY TotalSpent DESC  
OFFSET 0 ROWS
FETCH NEXT 5 ROWS ONLY;

SELECT CustomerID, FirstName, LastName, TotalSpent FROM 
(SELECT c.CustomerID, c.FirstName, c.LastName, sum(o.TotalAmount) AS TotalSpent, 
ROW_NUMBER() OVER(ORDER BY sum(o.TotalAmount) DESC) as rn
FROM Customers as c
JOIN Orders as o 
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName) SUB
WHERE rn <=5;

--Query 5: Retrieve the most popular product category

SELECT c.CategoryID, c.CategoryName, STRING_AGG(p.ProductName, ', ') AS ProductName, 
SUM(Quantity) AS N_QUANTITY FROM Categories AS c
JOIN Products AS p ON c.CategoryID = p.CategoryID
JOIN OrderItems AS o ON p.ProductID = o.ProductID
GROUP BY c.CategoryID, c.CategoryName
Order by N_QUANTITY Desc
OFFSET 0 ROWS 
FETCH NEXT 1 ROWS ONLY;

SELECT CategoryID, CategoryName, ProductName, N_QUANTITY FROM (
SELECT c.CategoryID, c.CategoryName, STRING_AGG(p.ProductName, ', ') AS ProductName, 
SUM(Quantity) AS N_QUANTITY,
ROW_NUMBER() OVER (ORDER BY SUM(Quantity) DESC) AS rn
FROM Categories AS c
JOIN Products AS p ON c.CategoryID = p.CategoryID
JOIN OrderItems AS o ON p.ProductID = o.ProductID
GROUP BY c.CategoryID, c.CategoryName ) SUB
WHERE rn = 1;

--Query 6:List all products that are out of stock, i.e stock = 0
SELECT ProductID, ProductName, Stock FROM Products 
WHERE Stock = 0;

--Query 7: Find customers who placed orders in the 30 days 
SELECT c.CustomerID, c.FirstName, c.LastName, c.Email, c.Phone FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= DATEADD(DAY,-30,GETDATE());

--Query 8: Calculate the total number of orders placed each month
SELECT YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, COUNT(OrderId) AS TotalOrders FROM Orders 
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY YEAR(OrderDate), MONTH(OrderDate);

--Query 9: Retrieve the details of the most recent order
SELECT TOP 1 o.OrderID, o.Orderdate, o.TotalAmount, c.FirstName, c.LastName FROM Orders O
JOIN Customers c
ON o.CustomerID = c.CustomerID 
ORDER BY o.OrderDate DESC ;

--Query 10: Find the average price of products in each category
SELECT c.CategoryID, c.CategoryName, STRING_AGG(p.ProductName, ', ') ProductNames, AVG(p.Price) AvgPrice FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID 
GROUP BY c.CategoryID, c.CategoryName;

--Query 11: List customers who have never placed an order
SELECT c.CustomerID, c.FirstName, c.LastName, c.Email, c.Phone FROM Customers c 
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL; 

--Query 12: Retrieve the total quantity sold for each product 
SELECT p.ProductID, p.ProductName, SUM(oi.Quantity) Totalquantitysold FROM Products p
JOIN OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY Totalquantitysold DESC;

--Query 13: Calculate the total revenue generated from each category
WITH revenue_cte as 
(
SELECT c.CategoryID, c.CategoryName, p.ProductName, SUM(oi.Quantity*oi.Price) RevenueProductWise,
SUM(SUM(oi.Quantity*oi.Price)) OVER (Partition by c.CategoryID) TotalRevenueCategorywise,
ROW_NUMBER() OVER (PARTITION BY c.CategoryID ORDER BY SUM(oi.Quantity*oi.Price) DESC) as RANK
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
JOIN OrderItems OI ON p.ProductID = oi.ProductID
GROUP BY c.CategoryID, c.CategoryName, p.ProductName
)
SELECT CategoryID, CategoryName, ProductName, RevenueProductWise, TotalRevenueCategorywise FROM revenue_cte;

--Query 14: Find the highest-priced product in each category
SELECT c.CategoryID, c.CategoryName, p1.ProductID, p1.ProductName, p1.Price FROM Categories c
JOIN Products p1 ON c.CategoryID = p1.CategoryID
WHERE p1.Price = (SELECT MAX(Price) FROM Products p2 WHERE p2.CategoryID = p1.CategoryID)
ORDER BY p1.Price DESC;

--Query 15: Retrieve orders with a total amount greater than a specific value (e. g., $49.99)
SELECT o.OrderID, o.CustomerID, c.FirstName, c.LastName, o.TotalAmount FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE o.TotalAmount > 49.99
ORDER BY o.TotalAmount;

--Query 16: List products along with the number of orders they appear in 
SELECT p.ProductID, p.ProductName, COUNT(oi.OrderID) OrderCount FROM Products p
JOIN OrderItems oi ON p.ProductID = oi.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY COUNT(oi.OrderID) DESC;

--Query 17: Find the top 3 most frequently ordered products
SELECT TOP 3 p.ProductID, p.ProductName, Count(oi.OrderId) OrderCount FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY Count(oi.OrderId) DESC;

--Query 18: Calculate the total number of customers from each country
SELECT Country, COUNT(CustomerID) TotalCustomers FROM Customers
GROUP BY Country
ORDER BY COUNT(CustomerID) DESC;

--Query 19: Retrieve the list of customer along with their total spending 
SELECT c.CustomerId, c.FirstName, c.LastName, SUM(o.TotalAmount) TotalSpending FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerId, c.FirstName, c.LastName;

--Query 20 List orders with more than a specified number of items (e.g., 5 items)
SELECT o.OrderID, c.customerId, c.FirstName, c.LastName, COUNT(oi.OrderitemID) NumberofItems FROM Orders o
JOIN  OrderItems oi ON o.OrderId = oi.OrderId
JOIN Customers c ON o.CustomerId = c.CustomerId
GROUP BY o.OrderID, c.customerId, c.FirstName, c.LastName
HAVING COUNT(oi.OrderitemID) > 1
ORDER BY NumberofItems;

SET IDENTITY_INSERT OrderItems ON;
INSERT INTO OrderItems(OrderItemID, OrderID, ProductID, Quantity, Price)
VALUES 
(6, 1, 1, 5, 699.99)
SET IDENTITY_INSERT OrderItems OFF;
