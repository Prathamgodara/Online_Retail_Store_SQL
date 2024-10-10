--Step 1: Create a Log Table

CREATE TABLE ChangeLog (
	LogID INT PRIMARY KEY IDENTITY(1,1),
	TableName NVARCHAR(50),
	Operation NVARCHAR(10),
	RecordID INT,
	ChangeDate DATETIME DEFAULT GETDATE(),
	ChangedBy NVARCHAR(100)
);
GO

--Step 2: Create Triggers for Each Table
	
--A. Triggers for Products Table
-- Trigger for INSERT on Products table

CREATE OR ALTER TRIGGER trg_Insert_Product 
ON Products
AFTER INSERT
AS
BEGIN
	-- Insert a record into ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Products', 'INSERT', inserted.ProductID, SYSTEM_USER 
	FROM inserted;

	--Display a message indicating that the trigger has fired.
	PRINT 'INSERT operation logged for Products table.'
END;
GO

-- Try to insert one record into the Products table 
INSERT INTO Products (ProductName, CategoryID, Price, Stock)
VALUES  ('Wireless Mouse', 1, 4.99, 20);
GO

INSERT INTO Products (ProductName, CategoryID, Price, Stock)
VALUES  ('Spireman Multiverse Comic', 3, 2.50, 150);
GO


--Display products table
SELECT * FROM Products;
GO
--Display ChangeLog table
SELECT * FROM ChangeLog;
GO

-- Trigger for UPDATE on Products table

CREATE OR ALTER TRIGGER trg_Update_Product 
ON Products
AFTER UPDATE
AS
BEGIN
	-- Insert a record into ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Products', 'UPDATE', inserted.ProductID, SYSTEM_USER 
	FROM inserted;

	--Display a message indicating that the trigger has fired.
	PRINT 'UPDATE operation logged for Products table.'
END;
GO

-- Try to update any record from Products table
UPDATE Products 
SET Price = 550 WHERE ProductID = 2;
GO

-- Trigger for DELETE on Products table

CREATE OR ALTER TRIGGER trg_Delete_Product 
ON Products
AFTER DELETE
AS
BEGIN
	-- Insert a record into ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Products', 'DELETE', deleted.ProductID, SYSTEM_USER 
	FROM deleted;

	--Display a message indicating that the trigger has fired.
	PRINT 'DELETE operation logged for Products table.'
END;
GO

SET NOCOUNT ON;

DELETE FROM Products WHERE ProductID = 2002;
GO



--B. Triggers for Customers Table
-- Trigger for INSERT on Customers table

CREATE OR ALTER TRIGGER trg_Insert_Customers 
ON Customers
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON
	-- Insert a record into ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Customers', 'INSERT', inserted.CustomerID, SYSTEM_USER 
	FROM inserted;

	--Display a message indicating that the trigger has fired.
	PRINT 'INSERT operation logged for Products table.'
END;
GO

-- Trigger for UPDATE on Customers table

CREATE OR ALTER TRIGGER trg_Update_Customers 
ON Customers
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON
	-- Insert a record into ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Customers', 'UPDATE', inserted.CustomerID, SYSTEM_USER 
	FROM inserted;

	--Display a message indicating that the trigger has fired.
	PRINT 'UPDATE operation logged for Products table.'
END;
GO
-- Trigger for DELETE on Customers table
CREATE OR ALTER TRIGGER trg_Delete_Customers 
ON Customers
AFTER DELETE
AS
BEGIN
	SET NOCOUNT ON
	-- Insert a record into ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Customers', 'DELETE', deleted.CustomerID, SYSTEM_USER 
	FROM deleted;

	--Display a message indicating that the trigger has fired.
	PRINT 'DELETED operation logged for Products table.'
END;
GO


-- Try to insert a new record to see the effect of trigger
INSERT INTO Customers (FirstName, LastName, Email, Phone, Address, city, State, ZipCode, Country)
Values
('Virat', 'Kohli', 'virat.kingkohli@example.com', '123-456-7890', 'South Delhi', 'Delhi', 'Delhi', '545665', 'INDIA')

--Try to update an existing record to see the effect of trigger
UPDATE Customers SET State = 'Florida' WHERE State = 'IL'

--Try to delete an existing record to see the effect of trigger
DELETE FROM Customers WHERE CustomerID = 1003



--A. Indexes on Categories table
--  1. Clustered index on CategoryID: Usually created with the primary key.

CREATE CLUSTERED INDEX IDX_Categories_CategoryID
ON Categories(CategoryID);
GO


--B. Indexes on Products table 
--  1. Clustered index on ProductId: This is usually created automatically when the primary key is defined.
--  2. Non Clustered index on CategoryId: To speed up queries filtering or sorting by CategoryId.
--  3. Non Clustered index on Price: To speed up queries filtering or sorting by Price.

-- Drop foreign key constraint from OrderItems table - ProductID
ALTER TABLE OrderItems DROP CONSTRAINT [FK__OrderItem__Produ__4316F928]
GO

-- Clustered INDEX on Products Table (ProductID)
CREATE CLUSTERED INDEX IDX_Clustered_Products_ProductID
ON Products(ProductID);
GO

-- Non Clustered index on CategoryId: To speed up queries filtering or sorting by CategoryId.

CREATE NONCLUSTERED INDEX IDX_Products_CategoryID
ON Products(CategoryID);
GO

--Non Clustered index on Price: To speed up queries filtering or sorting by Price.
CREATE NONCLUSTERED INDEX IDX_Products_Price
ON Products(Price);
GO

-- Recreate foreign key consraint on OrderItems(ProductID)
ALTER TABLE OrderItems ADD CONSTRAINT FK_OrderItems_Products
FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
GO

-- C. Indexes on Orders Table 
--   1. Clustered Index on OrderID: Usually created with primary key.
--   2. NON-Clustered Index on CustomerID: To speed up queries filtering or sorting by CustomerID
--   3. NON-Clustered Index on OrderDate: To speed up queries filtering or sorting by OrderDate

-- Drop foreign key constraint from OrderItems table - OrderID
ALTER TABLE OrderItems DROP CONSTRAINT [FK__OrderItem__Order__440B1D61];
GO

-- Clustered index on OrderID
CREATE CLUSTERED INDEX IDX_Orders_OrderID 
ON Orders(OrderID);
GO

-- NON-Clustered Index on CustomerID: To speed up queries filtering or sorting by CustomerID
CREATE NONCLUSTERED INDEX IDX_Orders_CustomerID 
ON Orders(CustomerID);
GO

-- NON-Clustered Index on OrderDate: To speed up queries filtering or sorting by OrderDate
CREATE NONCLUSTERED INDEX IDX_Orders_OrderDate
ON Orders(OrderDate);
GO 

-- Recreate foreign key consraint on OrderItems(OrderID)
ALTER TABLE OrderItems ADD CONSTRAINT FK_OrderItems_Orders
FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
GO

/*
D. Indexes on OrderItems Table 
1. Clustered Index on OrderItemsID: Usually created with primary key.
2. NON-Clustered Index on OrderID: To speed up queries filtering or sorting by OrderID
3. NON-Clustered Index on ProductID: To speed up queries filtering or sorting by ProductID
*/

--Clustered index on OrderItemsID
CREATE CLUSTERED INDEX IDX_OrderItems_OrderItemID
ON OrderItems(OrderItemID);
GO

-- NON-Clustered Index on OrderID: To speed up queries filtering or sorting by OrderID
CREATE NONCLUSTERED INDEX IDX_OrderItems_OrderID 
ON OrderItems(OrderID);
GO

-- NON-Clustered Index on ProductID: To speed up queries filtering or sorting by ProductID
CREATE NONCLUSTERED INDEX IDX_OrderItems_ProductID
ON OrderItems(ProductID);
GO

/*
D. Indexes on Customers Table 
1. Clustered Index on CustomerId: Usually created with primary key.
2. NON-Clustered Index on Email: To speed up queries filtering or sorting by Email
3. NON-Clustered Index on Country: To speed up queries filtering or sorting by Country
*/

-- Clustered index on CustomerId
CREATE CLUSTERED INDEX IDX_Customers_CustomerID
ON Customers(CustomerID);
GO

--NON-Clustered Index on Email: To speed up queries filtering or sorting by Email
CREATE NONCLUSTERED INDEX IDX_Customer_Email
ON Customers(Email)
GO

--NON-Clustered Index on Country: To speed up queries filtering or sorting by Country
CREATE NONCLUSTERED INDEX IDX_Customer_Country
ON Customers(Country)
GO

-- DROP Foreign key Orders(CustomerID) 
ALTER TABLE Orders DROP CONSTRAINT [FK__Orders__Customer__403A8C7D]
GO
-- Recreate Foreign Key Orders(CustomerID)
ALTER TABLE Orders ADD CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID);
GO


/* Implementing security / Role - Based Access Control (RBAC)

To manage access control in SQL server, We'll need to use a combinaton of SQL Server's security features,
Such as Logins, users, roles and permissions.

## Step 1: Create Logins
---------------------------------
               First, Create logins at the SQL server level.
			   Logins are used to authenticate users to the SQL server instance.
*/

-- Create a login with SQL Server Authentication 
CREATE LOGIN SalesUser WITH PASSWORD = '-------';

/*
## Step 2: Create Users
----------------------------
           Next, create users in the 'OnlineRetailDB' database for each login.
		   Users are associated with logins and are used  grant access to the database
*/

USE OnlineRetailDB;
GO

-- CREATE a user in the database for the SQL server login
CREATE USER SalesUser FOR LOGIN SalesUser;

/* ## Step 3: Create Roles 
-----------------------------
                DEfine roels in the database that will be used to group users with similer permissions. 
				This helps simplify permission management.
*/
-- Create roels inthe database 
CREATE ROLE Sales;
CREATE ROLE MarketingRole;

/* ## Step 4: Assign Users to Roles
-----------------------------------
               Add the users to the appropriate roles.
*/

-- Add users to Roles
EXEC sp_addrolemember 'Sales', 'SalesUser'

/* ## Step 5: Grant Permissions
----------------------------------
               Grant the necessary permissions to the roels based on the access requirements 
*/

--Grant SELECT permission on the Customers Table to the Sales Role

GRANT SELECT ON Customers TO Sales;

--Grant UPDATE permission on the Orders Table to the Sale Role

GRANT UPDATE ON Orders TO Sales;

-- Grant INSERT permission on the Products Table to the Sale Role

GRANT INSERT ON Products TO Sales;

SELECT * FROM Customers;
DELETE FROM Orders;

SELECT * FROM Orders;
DELETE FROM Orders;
INSERT INTO Orders(CustomerID, OrderDate, TotalAmount)
VALUES(1, GETDATE(), 600);

SELECT * FROM Products;
DELETE FROM Products;

/*## Step 6: Revoke Permssion (if Needed)
----------------------------------------
             Revoke statement
*/

--Revoke INSERT permission on the Orders to the Sale Role

REVOKE INSERT ON Orders FROM Sales ;

/* ## Step 7: View Effective Permissions
-----------------------------------------
             BY using query
*/

SELECT * FROM fn_my_permissions(NULL, 'DATABASE');

-- Scenario1: Read-only Access to all tables
CREATE ROLE ReadonlyRole;
GRANT SELECT ON SCHEMA::dbo TO ReadonlyRole;

-- Scenario2 : Data Entry Clerk (Insert Only on Orders and OrderItems)
CREATE ROLE DataEntryROle ;
GRANT INSERT ON Orders TO DataEntryROle;
GRANT INSERT ON OrderItems TO DataEntryROle;

-- Scenario3 : Product Manager (Full Access to product and Categories)
CREATE ROLE ProductManageRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO ProductManageRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Categories TO ProductManageRole;

--Scenario 4:Order Processor (READ and UPDATE orders)
CREATE ROLE OrderProcessorRole;
GRANT SELECT, UPDATE ON Orders TO OrderProcessorRole;

--Scenario 5: Customer Support (Read Access to customers and Orders)
CREATE ROLE CustomerSupportRole;
GRANT SELECT ON Customers TO CustomerSupportRole;
GRANT SELECT ON Orders TO CustomerSupportRole;

-- Scenario 6: Marketing Analyst (Read Access to All Tables, No DML)
CREATE ROLE MarketingAnalystRole;
GRANT SELECT ON SCHEMA::dbo TO MarketingAnalystRole;

--- Scenario 7: Sales Analyst (Read Access to Orders and OrderItems)
CREATE ROLE SalesAnalystRole;
GRANT SELECT ON Orders TO SalesAnalystRole;
GRANT SELECT ON OrderItems TO SalesAnalystRole;

--- Scenario 8: Inventory Manager (Full Access to Products)
CREATE ROLE InventoryManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO InventoryManagerRole;

--- Scenario 9: Finance Manager (Read and Update Orders)
CREATE ROLE FinanceManagerRole;
GRANT SELECT, UPDATE ON Orders TO FinanceManagerRole;

--- Scenario 10: Database Backup Operator (Backup Database)
CREATE ROLE BackupOperatorRole;
GRANT BACKUP DATABASE TO BackupOperatorRole;

--- Scenario 11: Database Developer (Full Access to Schema Objects)
CREATE ROLE DatabaseDeveloperRole;
GRANT CREATE TABLE, ALTER, DROP ON SCHEMA::dbo TO DatabaseDeveloperRole;

--- Scenario 12: Restricted Read Access (Read Only Specific Columns)
CREATE ROLE RestrictedReadRole;
GRANT SELECT (FirstName, LastName, Email) ON Customers TO RestrictedReadRole;

--- Scenario 13: Reporting User (Read Access to Views Only)
CREATE ROLE ReportingRole;
GRANT SELECT ON SalesReportView TO ReportingRole;
GRANT SELECT ON InventoryReportView TO ReportingRole;

--- Scenario 14: Temporary Access (Time-Bound Access)
-- Grant access
CREATE ROLE TempAccessRole;
GRANT SELECT ON SCHEMA::dbo TO TempAccessRole;

-- Revoke access after the specified period
REVOKE SELECT ON SCHEMA::dbo FROM TempAccessRole;

--- Scenario 15: External Auditor (Read Access with No Data Changes)
CREATE ROLE AuditorRole;
GRANT SELECT ON SCHEMA::dbo TO AuditorRole;
DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO AuditorRole;

--- Scenario 16: Application Role (Access Based on Application)
CREATE APPLICATION ROLE AppRole WITH PASSWORD = 'StrongPassword1';
GRANT SELECT, INSERT, UPDATE ON Orders TO AppRole;

--- Scenario 17: Role-Based Access Control (RBAC) for Multiple Roles 
-- Combine roles
CREATE ROLE CombinedRole;
EXEC sp_addrolemember 'SalesRole', 'CombinedRole';
EXEC sp_addrolemember 'MarketingRole', 'CombinedRole';

--- Scenario 18: Sensitive Data Access (Column-Level Permissions)
CREATE ROLE SensitiveDataRole;
GRANT SELECT (Email, Phone) ON Customers TO SensitiveDataRole;

--- Scenario 19: Developer Role (Full Access to Development Database)
CREATE ROLE DevRole;
GRANT CONTROL ON DATABASE::OnlineRetailDB TO DevRole;

--- Scenario 20: Security Administrator (Manage Security Privileges)
CREATE ROLE SecurityAdminRole;
GRANT ALTER ANY LOGIN TO SecurityAdminRole;
GRANT ALTER ANY USER TO SecurityAdminRole;
GRANT ALTER ANY ROLE TO SecurityAdminRole;
