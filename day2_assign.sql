----Part 1
-- 1
-- result set is a table of data returned from database(s) after executing statements that query the database(s).
-- 2
-- UNION doesn't output deplications while UNION ALL does.
-- 3
-- EXCEPT: take data from the first result set, but not from the second result set
-- INTERSECT:  take common data from both result sets
-- 4
-- JOIN is used to combine resul tset from two or more tables, while UNION is used to combine result set from two or more SELECT statements.
-- 5
-- INNER JOIN returns records from both tables that satisfy join condition; FULL JOIN returns all records when there is a match in left or right table records.
-- 6
-- OUTER JOIN includes LEFT JOIN, RIGHT JOIN, and FULL JOIN
-- 7
-- CROSS JOIN produces a result set that is cartesian product of two tables
-- 8
-- WHERE is used before GROUP BY; HAVING is used after GROUP BY.
-- 9
-- Yes, each disctinct set of selected columns will be regarded as a group.

----Part 2
-- 1: 504 products, we can find it from number of Name or ProductNumber
SELECT COUNT(Name), COUNT(ProductNumber)
FROM Production.Product
-- 2: 295
SELECT COUNT(ProductNumber)
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL
-- 3
SELECT ProductSubcategoryID, COUNT(ProductNumber) "CountedProducts"
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL
GROUP BY ProductSubcategoryID
-- 4: 209
SELECT COUNT(ProductNumber)
FROM Production.Product
WHERE ProductSubcategoryID IS NULL
-- 5: 
SELECT ProductID, SUM(Quantity) "TheSum"
FROM Production.ProductInventory
GROUP BY ProductID 
-- 6
SELECT ProductID, SUM(Quantity) "TheSum"
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY ProductID
HAVING  SUM(Quantity) < 100
-- 7
SELECT Shelf, ProductID, SUM(Quantity) "TheSum"
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY Shelf, ProductID
HAVING  SUM(Quantity) < 100
-- 8 
SELECT AVG(Quantity) "TheAvg"
FROM Production.ProductInventory
WHERE LocationID = 10
-- 9
SELECT Shelf, ProductID, AVG(Quantity) "TheAvg"
FROM Production.ProductInventory
GROUP BY Shelf, ProductID
-- 10
SELECT Shelf, ProductID, AVG(Quantity) "TheAvg"
FROM Production.ProductInventory
WHERE Shelf != 'N/A'
GROUP BY Shelf, ProductID
-- 11
SELECT Color, Class, COUNT(ProductID) "TheCount", AVG(ListPrice) "AvgPrice"
FROM Production.Product
WHERE Color IS NOT NULL AND Class IS NOT NULL
GROUP BY Color, Class
-- 12
SELECT c.Name "Country", s.Name "Province"
FROM Person.CountryRegion c 
INNER JOIN Person.StateProvince s ON c.CountryRegioncode = s.CountryRegioncode
-- 13
SELECT c.Name "Country", s.Name "Province"
FROM Person.CountryRegion c 
INNER JOIN Person.StateProvince s ON c.CountryRegioncode = s.CountryRegioncode
WHERE c.Name IN ('Germany', 'Canada')
-- 14
----Orders--OrderID, OrderDate
----[Order Details]--OrderID, ProductID
----Products--ProductID, ProdcutName
SELECT DISTINCT p.ProductName
FROM Orders o 
INNER JOIN [Order Details] od  ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
WHERE DATEDIFF(year, GETDATE(), o.OrderDate) <= 25
-- 15
SELECT TOP 5 p.ProductName, SUM(Quantity)"SumOfOrder"
FROM [Order Details] od 
INNER JOIN Products p ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY SUM(Quantity) DESC
-- 16
----Customers--PostalCode, CusomerID
----[Order Details]--Quantity, OrderID
----Orders--CusomerID, OrderID
SELECT TOP 5 c.PostalCode, SUM(od.Quantity) "SumOfOrder"
FROM [Order Details] od 
INNER JOIN Orders o ON od.OrderID = o.OrderID
INNER JOIN Customers c ON c.CustomerID = o.CustomerID
WHERE c.PostalCode IS NOT NULL
GROUP BY c.PostalCode
ORDER BY SUM(od.Quantity) DESC
-- 17
SELECT c.City, SUM(od.Quantity) "SumOfOrder"
FROM [Order Details] od 
INNER JOIN Orders o ON od.OrderID = o.OrderID
INNER JOIN Customers c ON c.CustomerID = o.CustomerID
WHERE c.City IS NOT NULL
GROUP BY c.City
-- 19
----Customers--CompanyName, CustomerID
----Orders--OrderDate, CustomerID
SELECT DISTINCT c.CompanyName
FROM Customers c 
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= '1998.01.01'
-- 20: list customers of top 5% of most recent oders 
SELECT TOP 5 PERCENT c.CompanyName, o.OrderDate
FROM Customers c 
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
ORDER bY o.OrderDate DESC
-- 21
----Customers--CustomerID, CompanyName
----Orders--OrderID, CustomerID
----[Order Details]--OrderID, ProductID
----Products--ProductID
SELECT c.CompanyName, COUNT(p.ProductID) "#OfProductsBought"
FROM Orders o 
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
GROUP BY c.CompanyName
-- 22
SELECT c.CustomerID, COUNT(p.ProductID) "#OfProductsBought"
FROM Orders o 
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
GROUP BY c.CustomerID
Having COUNT(p.ProductID) > 100
-- 23
SELECT DISTINCT su.CompanyName "Supplier Company Name", sh.CompanyName "Shipping Company Name"
FROM Orders o 
LEFT JOIN [Order Details] od ON o.OrderID = od.OrderID
LEFT JOIN Shippers sh ON o.ShipVia = sh.ShipperID
LEFT JOIN Products p ON od.ProductID = p.ProductID
LEFT JOIN Suppliers su ON su.SupplierID = p.SupplierID
ORDER BY su.CompanyName
-- 24
SELECT DISTINCT o.OrderDate, p.ProductName
FROM Orders o
LEFT JOIN [Order Details] od ON o.OrderID = od.OrderID
LEFT JOIN Products p ON od.ProductID = p.ProductID
-- 25: avoid permutation
SELECT a.LastName, a.FirstName, b.LastName, b.FirstName,  a.Title
FROM Employees a
INNER JOIN Employees b ON a.Title = b.Title AND CONCAT(a.FirstName, ' ', a.LastName) < CONCAT(b.FirstName, ' ', b.LastName)
-- 26
SELECT b.LastName, b.FirstName, COUNT(a.ReportsTo) "#OfPplReportTo"
FROM Employees a
LEFT JOIN Employees b ON a.ReportsTo = b.EmployeeID
GROUP BY a.ReportsTo, b.LastName, b.FirstName
HAVING COUNT(a.ReportsTo) > 2
-- 27: create additional col, the second AS Type can be omitted
SELECT City, CompanyName, ContactName, 'Customer' AS Type
FROM Customers
UNION SELECT City, CompanyName, ContactName, 'Supplier' AS Type
FROM Suppliers
ORDER BY City, CompanyName
-- 28: 
----I suppose F1 and F2 are column names
----output is a empty table
SELECT T1.F1, T2.F2
FROM T1
INNER JOIN T2 ON T1.F1 = T2.F2
-- 29
----output:
--F1 F2
--1  null
--2  null
--3  null
SELECT T1.F1, T2.F2
FROM T1
LEFT JOIN T2 ON T1.F1 = T2.F2