--1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
SELECT 
    FORMAT(o.OrderDate, 'yyyy/MM') as order_month, 
    AVG(ol.UnitPrice) AS avg_price, 
    SUM(ol.UnitPrice * ol.Quantity) AS total_sum
FROM Sales.Orders o
JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
GROUP BY FORMAT(o.OrderDate, 'yyyy/MM')
ORDER BY order_month;

--2. Отобразить все месяцы, где общая сумма продаж превысила 10 000
SELECT 
    FORMAT(o.OrderDate, 'yyyy/MM') as order_month
FROM Sales.Orders o
JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
GROUP BY FORMAT(o.OrderDate, 'yyyy/MM')
HAVING SUM(ol.UnitPrice * ol.Quantity) > 10000
ORDER BY order_month;


/*
3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц.
Группировка должна быть по году и месяцу.
*/

SELECT FORMAT(o.OrderDate, 'yyyy/MM') as order_month,
        ol.StockItemID as ItemId,
        SUM(ol.UnitPrice * ol.Quantity) as total_sum,
        MIN(o.OrderDate) as min_date,
        SUM(ol.Quantity) as Quantity
FROM Sales.Orders o
JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
GROUP BY ROLLUP(FORMAT(o.OrderDate, 'yyyy/MM'), ol.StockItemID)
HAVING SUM(ol.Quantity) < 50;


--4. Написать рекурсивный CTE sql запрос и заполнить им временную таблицу и табличную переменную
DROP TABLE IF EXISTS dbo.MyEmployees;

CREATE TABLE dbo.MyEmployees
(
EmployeeID smallint NOT NULL,
FirstName nvarchar(30) NOT NULL,
LastName nvarchar(40) NOT NULL,
Title nvarchar(50) NOT NULL,
DeptID smallint NOT NULL,
ManagerID int NULL,
CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC)
);

INSERT INTO dbo.MyEmployees VALUES
(1, N'Ken', N'Sánchez', N'Chief Executive Officer',16,NULL)
,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1)
,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273)
,(275, N'Michael', N'Blythe', N'Sales Representative',3,274)
,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274)
,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273)
,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285)
,(16, N'David',N'Bradley', N'Marketing Manager', 4, 273)
,(23, N'Mary', N'Gibson', N'Marketing Specialist', 4, 16); 

--временная
DROP TABLE IF EXISTS  #Workers_and_Managers;
CREATE TABLE #Workers_and_Managers(EmployeeId INT PRIMARY KEY, [Name] NVARCHAR(80), Title NVARCHAR(50), EmployeeLevel INT);

WITH tmp(EmployeeId, [Name], ManagerId, Title, EmployeeLevel) AS (
	SELECT m.EmployeeID, 
		CAST(m.FirstName + ' ' + m.LastName AS NVARCHAR(MAX)), 
		m.ManagerID, 
		m.Title, 
		1 
	FROM dbo.MyEmployees m
	WHERE m.ManagerID IS NULL
	UNION ALL
	SELECT m.EmployeeID, 
		CAST(REPLICATE('| ', tmp.EmployeeLevel)  AS NVARCHAR(MAX)) + m.FirstName + ' ' + m.LastName, 
		m.ManagerID, 
		m.Title, 
		tmp.EmployeeLevel + 1
	FROM tmp
	JOIN dbo.MyEmployees m ON tmp.EmployeeId = m.ManagerId
)
INSERT INTO #Workers_and_Managers
SELECT EmployeeId, [Name], Title, EmployeeLevel
FROM tmp;

SELECT * FROM #Workers_and_Managers
ORDER BY EmployeeLevel;

DROP TABLE IF EXISTS  #Workers_and_Managers;

--табличная переменная
DECLARE @Workers_and_Managers TABLE(EmployeeId INT PRIMARY KEY, [Name] NVARCHAR(80), Title NVARCHAR(50), EmployeeLevel INT);

WITH tmp(EmployeeId, [Name], ManagerId, Title, EmployeeLevel) AS (
	SELECT m.EmployeeID, 
		CAST(m.FirstName + ' ' + m.LastName AS NVARCHAR(MAX)), 
		m.ManagerID, 
		m.Title, 
		1 
	FROM dbo.MyEmployees m
	WHERE m.ManagerID IS NULL
	UNION ALL
	SELECT m.EmployeeID, 
		CAST(REPLICATE('| ', tmp.EmployeeLevel)  AS NVARCHAR(MAX)) + m.FirstName + ' ' + m.LastName, 
		m.ManagerID, 
		m.Title, 
		tmp.EmployeeLevel + 1
	FROM tmp
	JOIN dbo.MyEmployees m ON tmp.EmployeeId = m.ManagerId
)
INSERT INTO @Workers_and_Managers
SELECT EmployeeId, [Name], Title, EmployeeLevel
FROM tmp;

SELECT * FROM @Workers_and_Managers
ORDER BY EmployeeLevel;

