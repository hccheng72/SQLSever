-- 1
SELECT ProductId, Name, Color, ListPrice
FROM Production.Product
-- 2
SELECT ProductId, Name, Color, ListPrice
FROM Production.Product
WHERE ListPrice = 0
-- 3
SELECT ProductId, Name, Color, ListPrice
FROM Production.Product
WHERE Color IS NULL
-- 4
SELECT ProductId, Name, Color, ListPrice
FROM Production.Product
WHERE Color IS NOT NULL
-- 5
SELECT ProductId, Name, Color, ListPrice
FROM Production.Product
WHERE Color IS NOT NULL AND ListPrice > 0
-- 6
SELECT Name+'_'+ Color as Name_Color
FROM Production.Product
WHERE Color IS NOT NULL
-- 7
SELECT 'NAME: ' + Name +' -- COLOR: '+ Color as [Name And Color]
FROM Production.Product
WHERE Name IS NOT NULL AND Color IS NOT NULL
-- 8
SELECT ProductId, Name
FROM Production.Product
WHERE ProductId BETWEEN 400 AND 500
-- 9
SELECT ProductId, Name, Color
FROM Production.Product
WHERE Color IN ('black', 'blue')
-- 10
SELECT Name
FROM Production.Product
WHERE Name LIKE 'S%'
-- 11
SELECT Name, ListPrice
FROM Production.Product
ORDER BY Name
-- 12
SELECT Name, ListPrice
FROM Production.Product
WHERE Name LIKE '[A,S]%' /*no space in []*/
ORDER BY Name
-- 13
SELECT *
FROM Production.Product
WHERE Name LIKE 'SPO[^k]%'
ORDER BY Name
-- 14
SELECT DISTINCT Color
FROM Production.Product
ORDER BY Color desc
-- 15
SELECT DISTINCT ProductSubcategoryID, Color
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL AND Color IS NOT NULL
-- 17
SELECT ProductSubcategoryID, Name, Color, ListPrice
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL AND Color IS NOT NULL AND ListPrice IS NOT NULL
		AND ProductSubcategoryID <= 14
ORDER BY ProductSubcategoryID desc, Name, Color