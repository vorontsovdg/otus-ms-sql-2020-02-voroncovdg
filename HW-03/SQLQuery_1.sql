--1. Выберите сотрудников, которые являются продажниками, и еще не сделали ни одной продажи.
--Подзапрос
SELECT * FROM Application.People p
WHERE P.IsSalesperson = 1 AND 
NOT EXISTS (
	SELECT 1 FROM Sales.Invoices i
	WHERE i.SalespersonPersonID = p.PersonID);

SELECT * FROM Application.People p
WHERE P.IsSalesperson = 1
AND p.PersonID NOT IN (
	select i.SalespersonPersonID 
	from sales.Invoices i
	);

--WITH
WITH sp AS (
	SELECT DISTINCT i.SalespersonPersonID
	FROM Sales.Invoices i
	)
SELECT p.FullName, p.IsSalesperson
FROM Application.People p
LEFT JOIN sp ON p.PersonID = sp.SalespersonPersonID
WHERE p.IsSalesperson = 1 AND sp.SalespersonPersonID IS NULL;
/*В общем мне кажется, что продажников, которые не совершили ни одной продажи нет
Возможно я ошибаюсь, но насколько вижу, у всех есть какие либо продажи
*/

--2. Выберите товары с минимальной ценой (подзапросом), 2 варианта подзапроса. 
--Подзапрос
SELECT si.StockItemName, si.RecommendedRetailPrice
FROM Warehouse.StockItems si
WHERE si.RecommendedRetailPrice = (
	SELECT TOP 1 si2.RecommendedRetailPrice
	FROM Warehouse.StockItems si2
	ORDER BY si2.RecommendedRetailPrice ASC);

--WITH
WITH MinPrice AS (
	SELECT TOP 1 si.RecommendedRetailPrice
	FROM Warehouse.StockItems si
	ORDER BY si.RecommendedRetailPrice ASC)
SELECT *
FROM WAREHOUSE.StockItems si2
LEFT JOIN MinPrice ON si2.RecommendedRetailPrice = MinPrice.RecommendedRetailPrice
WHERE MinPrice.RecommendedRetailPrice IS NOT NULL;

--3. Выберите информацию по клиентам, которые перевели компании 5 максимальных платежей из [Sales].[CustomerTransactions] представьте 3 способа (в том числе с CTE)
--1-й способ
SELECT TOP 5  c.CustomerID, c.CustomerName, t.AmountExcludingTax
FROM Sales.Customers c
JOIN Sales.CustomerTransactions t
ON c.CustomerID = t.CustomerID
ORDER BY t.AmountExcludingTax DESC;

--2-й
SELECT DISTINCT c.CustomerName
FROM Sales.Customers c
WHERE c.CustomerID IN (
	SELECT TOP 5 t.CustomerID
	FROM Sales.CustomerTransactions t
	ORDER BY t.AmountExcludingTax DESC);

--3-й
WITH MainCustomers AS (
	SELECT TOP 5 t.CustomerID
	FROM Sales.CustomerTransactions t
	ORDER BY t.AmountExcludingTax DESC)
SELECT DISTINCT c.CustomerName
FROM Sales.Customers c
JOIN MainCustomers ON c.CustomerID = MainCustomers.CustomerID;


--4. Выберите города (ид и название), в которые были доставлены товары, входящие в тройку самых дорогих товаров, а также Имя сотрудника, который осуществлял упаковку заказов
SELECT ct.CityID, ct.CityName, p.FullName
FROM Sales.Orders o
	JOIN Sales.Invoices i ON o.OrderID = i.OrderID
	JOIN Application.People p ON p.PersonID = i.PackedByPersonID
	JOIN Sales.Customers c ON o.CustomerID = c.CustomerID
	JOIN Application.Cities ct ON c.DeliveryCityID = ct.CityID
	JOIN Sales.OrderLines ol ON ol.OrderID = o.OrderID
WHERE ol.StockItemID IN (
	SELECT TOP 3 si.StockItemID
	FROM Warehouse.StockItems si
	ORDER BY si.UnitPrice DESC);


WITH ExpensiveGoods AS (
	SELECT TOP 3 si.StockItemID
	FROM Warehouse.StockItems si
	ORDER BY si.UnitPrice DESC)
SELECT ct.CityID, ct.CityName, p.FullName
FROM Sales.Orders o
	JOIN Sales.Invoices i ON o.OrderID = i.OrderID
	JOIN Application.People p ON p.PersonID = i.PackedByPersonID
	JOIN Sales.Customers c ON o.CustomerID = c.CustomerID
	JOIN Application.Cities ct ON c.DeliveryCityID = ct.CityID
	JOIN Sales.OrderLines ol ON ol.OrderID = o.OrderID
	LEFT JOIN ExpensiveGoods eg ON eg.StockItemID = ol.StockItemID
WHERE eg.StockItemID IS NOT NULL;

--5. Объясните, что делает и оптимизируйте запрос:

SELECT
Invoices.InvoiceID,
Invoices.InvoiceDate,
(SELECT People.FullName
FROM Application.People
WHERE People.PersonID = Invoices.SalespersonPersonID
) AS SalesPersonName,
SalesTotals.TotalSumm AS TotalSummByInvoice,
(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
FROM Sales.OrderLines
WHERE OrderLines.OrderId = (SELECT Orders.OrderId
FROM Sales.Orders
WHERE Orders.PickingCompletedWhen IS NOT NULL
AND Orders.OrderId = Invoices.OrderId)
) AS TotalSummForPickedItems
FROM Sales.Invoices
JOIN
(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
FROM Sales.InvoiceLines
GROUP BY InvoiceId
HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

/*
Я вижу, что данный sql запрос выбирает счета, которых общая сумма покупки товаров клиентом превышает 27000
Также для этого счета выбирается сумма по собранному заказу и соответственно, можно сравнить: на какую сумму пришел счет, а на какую был собран заказ
Также выводится id счета, его дата и имя продавца.
По оптимизации:
	Можно переписать части запроса для TotalSummForPickedItems и TotalSummByInvoice в виде CTE
*/
;WITH TotalSum AS (
	SELECT il.InvoiceID, SUM(il.UnitPrice * il.Quantity) TotalInvoiceSum
	FROM Sales.InvoiceLines il
	GROUP BY il.InvoiceID
	HAVING SUM(il.UnitPrice * il.Quantity) > 27000),
	TotalPick AS (
		SELECT o.OrderID, SUM(ol.PickedQuantity*ol.UnitPrice) TotalPickSum
		FROM Sales.Orders o 
		JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
		WHERE ol.PickingCompletedWhen IS NOT NULL
		GROUP BY o.OrderID)
SELECT i.InvoiceID, i.InvoiceDate, p.FullName SalesPersonName, ts.TotalInvoiceSum TotalSummByInvoice, tp.TotalPickSum TotalSummForPickedItems
FROM Sales.Invoices i
JOIN Application.People p ON p.PersonID = i.SalespersonPersonID
JOIN TotalSum ts ON i.InvoiceID = ts.InvoiceID
JOIN TotalPick tp ON i.OrderID = tp.OrderID
ORDER BY ts.TotalInvoiceSum DESC;


