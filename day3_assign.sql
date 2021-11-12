-- Part 1
-- 1: If it's not correlated subquery, join will be a better choice. This is because inner query will be evaluated once when each
--	  of outter query processes which causes inefficient performance.
-- 2: Common Table Expression. It can be used to define a derived table for readability and a recursive query.
-- 3: Its scope is the duration of batch, function, or stored procedure. Like temp tables, it is stored in tempdb database.
-- 4: DELETE is a DML command and it can be used to delete specific rows filtered by conditions. TRUNCATE is a DDL command and 
--    removes whole table. In term of removing whole table, TRUNCATE is more efficient because DELETE removes one row at a time,
--    and records an entry for each deleted row into transaction log.
-- 5: Giving uniq index to each row when create a new row. Seed number and increment can be set by a user. When TRUNCATE happens,
--    the index will reset to the seed number. On the other hand, identity is retained after using DELETE statement.
-- 6: They both delete the all rows of a table, but TRUNCATE has faster performance.

-- Part 2
-- 1
SELECT c.City
FROM Customers c 
GROUP BY c.City
HAVING COUNT(c.CustomerID) > 0 AND c.City IN (SELECT e.City FROM Employees e GROUP BY e.City HAVING COUNT(e.EmployeeID) > 0) 
-- 2.a
SELECT c.City
FROM Customers c 
GROUP BY c.City
HAVING COUNT(c.CustomerID) > 0 AND c.City NOT IN (SELECT e.City FROM Employees e GROUP BY e.City HAVING COUNT(e.EmployeeID) > 0)
-- 2.b (or use EXCEPT)
SELECT DISTINCT c.City FROM Customers c
LEFT JOIN Employees e ON c.City = e.City
WHERE c.CustomerID Is not null and e.employeeid is null
-- 3
----productID orderQuantity
----OD(orderid, productid, quantity)->products
SELECT p.ProductName, dt.totalOrderQuantity
FROM (SELECT od.ProductID, COUNT(od.Quantity) "totalOrderQuantity"
	FROM [Order Details] od
	GROUP BY od.ProductID) dt
LEFT JOIN Products p ON dt.ProductID = p.ProductID
-- 4
----customerCity totalProducts
----customers(city, customerid)->orders(orderid)->OD(productid)
SELECT dt.City "customerCity", COUNT(od.ProductID) "totalProducts"
FROM (SELECT c.City, c.CustomerID, o.OrderID
	FROM Customers c
	LEFT JOIN Orders o ON c.CustomerID = o.CustomerID) dt
LEFT JOIN [Order Details] od ON dt.OrderID = od.OrderID
GROUP BY dt.City
-- 5
SELECT City, COUNT(CustomerID) "#OfCustomers" FROM Customers GROUP BY City HAVING COUNT(CustomerID) >= 2
-- 6
SELECT dt.City "customerCity", COUNT(od.ProductID) "totalProducts"
FROM (SELECT c.City, c.CustomerID, o.OrderID
	FROM Customers c
	LEFT JOIN Orders o ON c.CustomerID = o.CustomerID) dt
LEFT JOIN [Order Details] od ON dt.OrderID = od.OrderID
GROUP BY dt.City
HAVING COUNT(od.ProductID) >= 2
-- 7
---customercity shipCity
---orders(shipcity, customerid)->customers(city)
SELECT DISTINCT dt.CompanyName
FROM (SELECT c.CompanyName, c.City, o.ShipCity
	FROM Orders o
	LEFT JOIN Customers c ON o.CustomerID = c.CustomerID
	WHERE o.ShipCity != c.City) dt
-- 8 ??
---productName(top 5 most quantities) AvgPrice customerCity(top 1 most quantity)
---OD(quantity, productid)->products ->orders(orderid) ->customers(customerid, city)
SELECT dt3.ProductID, dt3.City
FROM (SELECT dt2.ProductID, dt2.City, SUM(dt2.Quantity) "CityQuantity", RANK() OVER(PARTITION BY dt2.ProductID ORDER BY SUM(dt2.Quantity) desc) "RN"
	FROM (SELECT c.City, dt.ProductID, dt.Quantity, dt.UnitPrice
		FROM (SELECT o.CustomerID, od.ProductID, od.Quantity, od.UnitPrice
			FROM [Order Details] od
			LEFT JOIN Orders o ON od.OrderID = o.OrderID) dt
		LEFT JOIN Customers c ON dt.CustomerID = c.CustomerID) dt2
	GROUP BY dt2.City, dt2.ProductID
	HAVING dt2.ProductID IN
		(SELECT TOP 5 p.ProductID
		FROM [Order Details] od
		LEFT JOIN Products p ON od.ProductID = p.ProductID
		GROUP BY p.ProductID
		ORDER BY SUM(od.Quantity) desc)) dt3
WHERE dt3.RN = 1
ORDER BY dt3.ProductID
-- 9.a
SELECT DISTINCT e.City
FROM Employees e
WHERE e.City NOT IN (SELECT c.City FROM Orders o LEFT JOIN Customers c ON o.CustomerID = c.CustomerID)
-- 9.b
SELECT DISTINCT e.City FROM Employees e
EXCEPT
SELECT c.City FROM Orders o LEFT JOIN Customers c ON o.CustomerID = c.CustomerID
-- 10
---Orders(employeeid, orderid)->employees(city)
---Orders(customerid)->OD(quamtity)->customers(city)
SELECT * 
FROM (SELECT TOP 1 e.City
	FROM Orders o
	LEFT JOIN Employees e ON o.EmployeeID = e.EmployeeID
	GROUP BY o.EmployeeID, e.City
	ORDER BY COUNT(o.OrderID) DESC) a

INTERSECT

SELECT * 
FROM (SELECT TOP 1 c.City
	FROM (SELECT o.CustomerID, od.Quantity
		FROM Orders o
		LEFT JOIN [Order Details] od ON o.OrderID = od.OrderID) dt
	LEFT JOIN Customers c ON dt.CustomerID = c.CustomerID
	GROUP BY c.City
	ORDER BY COUNT(dt.Quantity) DESC) b
-- 11: lecture assign: remove duplications
--- table Example:
--- Name   Gender
--- abc    0
--- abc    0
--- xyz    1
WITH CTE AS (
	SELECT Name, Gender, DENSE_RANK() OVER(PARTITION BY Name, Gender ORDER BY Name) "rn"
	FROM Example
)
DELETE FROM CTE WHERE rn > 1
-- 12
---Employee(empid, mgrid, deptid, salary)
---Dept(deptid, deptname)
--find empid not in mgrid
SELECT empid
FROM Employee
WHERE empid NOT IN (
	SELECT DISTINCT e.mgrid FROM Employee e
)
-- 13
---order by #emp, select rn = 1
SELECT dt.deptname, RANK() OVER(ORDER BY dt.#OfEmp DESC) "rn"
FROM (SELECT e.deptid, d.deptname, COUNT(e.empid) "#OfEmp"
	FROM Employee e
	LEFT JOIN Dept d ON e.deptid = d.deptid
	GROUP BY e.deptid, , d.deptname) dt
WHERE rn = 1
ORDER BY dt.deptname
-- 14
SELECT d.deptname, e.empid, e.salry, RANK() OVER(PARTITION BY e.deptid ORDER BY e.salary DESC)
FROM Employee e
LEFT JOIN Dept d ON e.deptid = d.deptid
ORDER BY d.deptname
-- 15: lecture Assign: top 3 products from every city which were sold maximum (customers->orders->products)
SELECT * FROM (
SELECT SUM(dt.Quantity) "TotalQuantity", dt.ProductID, c.City, DENSE_RANK() OVER(PARTITION BY c.City ORDER BY SUM(dt.Quantity) DESC) "rn"
FROM (SELECT o.CustomerID, od.ProductID, od.Quantity
	FROM Orders o
	LEFT JOIN [Order Details] od ON o.OrderID = od.OrderID) dt
LEFT JOIN Customers c ON dt.CustomerID = c.CustomerID
GROUP BY dt.ProductID, c.City) dt2
WHERE dt2.rn <= 3
ORDER BY dt2.City
-- 16: lecture assign: change gender code 0->1, 1->0
--- Employee
--- id  Name  Gender
--- 1   abc   0
--- 2   xyz   1
UPDATE Employee
SET Gender = 0
WHERE Gender = 1

UPDATE Employee
SET Gender = 1
WHERE Gender = 0
-- 17: lecture assign: calculate distance between two points
--- GIVEN: Example        Result:
--- City  Distance        City  Distance
--- A     80              B-A   70
--- B     150             C-B   30
--- C     180             D-c   40
--- D     220
WITH 
T AS (
	SELECT ROW_NUMBER() OVER(PARTITION BY city ORDER BY city) rn, City, Distance
	FROM Example
),

T_JOINT AS (
	SELECT T1.city "city1", T1.dist "dist1", T2.city "city2", T2.dist "dist2"
	FROM T AS T1, T AS T2
	WHERE T1.rn + 1 = T2.rn
)

SELECT CONCAT(TJ.city2, '-', TJ.city1) "City", ABS(TJ.dist2 - TJ.dist1) "Distance"
FROM T_JOINT AS TJ