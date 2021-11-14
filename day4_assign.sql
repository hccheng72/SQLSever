-- Part 1
-- 1: View is like a virtual table which has rows and columns that come from one or more tables in the database. Views can
--    be stored permanently.
-- 2: Yes, modifications on views also affect the data in original tables.
-- 3: Stored Procedure is a group of SQL statements that can be stored permanatly, accepts parameters or return values. 
--    The benefits include we can reused the SQL statements without rewriting. And saving more space when two severs are communicating.
-- 4: Views doen't accept parameters or return values. Views are used as a window to keep the resultset from tables we need frequently.
--    Stored Procedure can handle many logical SQL statements that include but not limit to INSERT, DELETE, UPDATE.
-- 5: Stored Procedure only can return int data type except for using output parameters, while function can return any type of values.
-- 6: Yes, Stored Prodedure can return multiple resultsets.  
-- 7: SELECT works with a resultset, but Stored Prodedure doesn't guarantee to return a resultset. It could be none or more than one.
-- 8: Trigger is a special type of Stored Procedure which is executed automatically when a specified event happens. There are DDL trigger, 
--    DML Trigger, and LOGON trigger.
-- 9: Like to implement a business rule, enforece referential integrity, create an audit trail of activity in the database, derive 
--    additional data that is not available within a table or within the database.
-- 10: Trigger is a special type of sorted procedure, but can't be executed manually.

-- Part 2
-- 1
INSERT INTO Region VALUES (5, 'Middle Earth')
INSERT INTO Territories VALUES ('11111', 'Gondor', 5)
INSERT INTO Employees VALUES ('King', 'Aragorn', 'Engeiner', 'Dr.', null, null, 'abc', 'Dublin', 
    'CA', '95567', 'USA', '2099992345', '1234', null, null, 3, null)
INSERT INTO EmployeeTerritories VALUES (14, '11111') 
-- 2
UPDATE Territories SET TerritoryDescription = 'Arnor' WHERE TerritoryID = '11111'
-- 3
DELETE FROM EmployeeTerritories WHERE EmployeeID = 14
DELETE FROM Employees WHERE EmployeeID = 14
DELETE FROM Territories WHERE RegionID = 5
DELETE FROM Region WHERE RegionID = 5
-- 4
CREATE VIEW view_product_order_cheng AS
	SELECT p.ProductID, SUM(od.Quantity) "TotalOrderQuantities"
	FROM [Order Details] od
	LEFT JOIN Products p ON od.ProductID = p.ProductID
	GROUP BY p.ProductID 

SELECT * FROM view_product_order_cheng
-- 5
CREATE PROC sp_product_order_quantity_cheng 
	@prodID int,
	@orderQuant smallint OUTPUT
AS
	SELECT @orderQuant = SUM(od.Quantity)
	FROM [Order Details] od
	WHERE ProductID = @prodID
GO

DECLARE @orderQuantity smallint
EXEC sp_product_order_quantity_cheng 1, @orderQuantity OUTPUT
SELECT @orderQuantity "orderQuantity"
-- 6
CREATE PROC sp_product_order_city_cheng
	@prodID int
	--@top5Cities table (nvarchar(15)) OUTPUT
AS
BEGIN
	SELECT dt2.City
	FROM (SELECT bt.ProductID, c.City, bt.qt, RANK() OVER(PARTITION BY bt.ProductID ORDER BY bt.qt DESC) "RN"
		FROM (SELECT od.ProductID, o.CustomerID, SUM(od.Quantity) "qt"
			FROM [Order Details] od
			LEFT JOIN Orders o ON od.OrderID = o.OrderID
			GROUP BY od.ProductID, o.CustomerID) bt
		LEFT JOIN Customers c ON bt.CustomerID = c.CustomerID) dt2
	WHERE RN <= 5 AND dt2.ProductID = @prodID
END

EXEC sp_product_order_city_cheng 1
-- 7
CREATE PROC sp_move_employees_cheng
AS
BEGIN
	DECLARE @count int

	CREATE TABLE #empInTroy (EmployeeID int, TerritoryID nchar(50))
	INSERT INTO #empInTroy 
		SELECT et.EmployeeID, et.TerritoryID
		FROM EmployeeTerritories et LEFT JOIN Territories t ON et.TerritoryID = t.TerritoryID 
		WHERE t.TerritoryDescription = 'Troy'

	 SELECT @count = COUNT(EmployeeID) FROM #empInTroy

	IF @count != 0
	BEGIN
		INSERT INTO Territories VALUES ('94567', 'Steven Points', 3)
		UPDATE #empInTroy SET TerritoryID = '94567'
	END
END
-- 8
CREATE TRIGGER tg_move_employees_cheng ON EmployeeTerritories
FOR UPDATE AS
BEGIN
	DECLARE @count int

	CREATE TABLE #empInStevenPoints (EmployeeID int, TerritoryID nchar(50))
	INSERT INTO #empInStevenPoints 
		SELECT et.EmployeeID, et.TerritoryID
		FROM EmployeeTerritories et LEFT JOIN Territories t ON et.TerritoryID = t.TerritoryID 
		WHERE t.TerritoryDescription = 'Steven Points'

	 SELECT @count = COUNT(EmployeeID) FROM #empInStevenPoints

	 IF @count > 100
	BEGIN
		DECLARE @idOfStevenPoints nvarchar(20)
		SELECT @idOfStevenPoints = t.TerritoryID FROM Territories t WHERE t.TerritoryDescription = 'Troy'
		UPDATE #empInStevenPoints SET TerritoryID = @idOfStevenPoints
	END
END
-- 9
CREATE TABLE people_cheng (pplId int, pplName nvarchar(20), cityId int)
CREATE TABLE city_cheng (cityId int, cityName nvarchar(15))

INSERT INTO people_cheng VALUES
(1, 'Aaron Rodgers', 2),
(2, 'Russell Wilson', 1)

INSERT INTO city_cheng VALUES
(1, 'Seattle'),
(2, 'Green Bay')

CREATE PROC remove_city_Seattle_cheng
AS
BEGIN
	DECLARE @count int

	SELECT @count = p.cityId
	FROM people_cheng p LEFT JOIN city_cheng c ON p.cityID = c.cityID
	WHERE c.cityName = 'Seattle'

	if @count > 0
	BEGIN
		INSERT INTO city_cheng VALUES (3, 'Madison')

		UPDATE p 
		SET p.cityID = 3
		FROM people_cheng p LEFT JOIN city_cheng c ON p.cityID = c.cityID
		WHERE c.cityName = 'Seattle'
	END
END
-- 10
CREATE PROC sp_birthday_employees_cheng
AS
BEGIN
	CREATE TABLE birthday_employees_cheng (EmployeeID int, LastName nvarchar(20), FirstName nvarchar(10), BirthDate datetime)
	INSERT INTO birthday_employees_cheng
		SELECT e.EmployeeID, e.LastName, e.FirstName, e.BirthDate
		FROM Employees e
		WHERE MONTH(BirthDate) = 2
END
-- 11
CREATE PROC sp_cheng_1
AS
BEGIN
	SELECT c.City
	FROM (SELECT COUNT(od.ProductID) "#OfProd", o.CustomerID
		FROM [Order Details] od 
		LEFT JOIN Orders o ON od.OrderID = o.OrderID
		GROUP BY o.CustomerID
		HAVING COUNT(od.ProductID) <= 1 ) dt
	LEFT JOIN Customers c ON dt.CustomerID = c.CustomerID
	GROUP BY c.City
	HAVING COUNT(dt.#OfProd) >=2
END

CREATE PROC sp_cheng_2
AS
BEGIN
	WITH 
	cte1 AS (
		SELECT COUNT(od.ProductID) "#OfProd", o.CustomerID
		FROM [Order Details] od 
		LEFT JOIN Orders o ON od.OrderID = o.OrderID
		GROUP BY o.CustomerID
		HAVING COUNT(od.ProductID) <= 1
	)
	
	SELECT c.City
	FROM cte1
	LEFT JOIN Customers c ON cte1.CustomerID = c.CustomerID
	GROUP BY c.City
	HAVING COUNT(cte1.#OfProd) >=2
END
-- 12
--- Assume there are tableA and tableB
select * from tableA
EXCEPT
select * from tableB
--- if the resultset is empty, tableA and tableB have the same data.