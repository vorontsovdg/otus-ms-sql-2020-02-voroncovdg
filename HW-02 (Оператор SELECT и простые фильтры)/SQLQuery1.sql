--1. Все товары, в которых в название есть пометка urgent или название начинается с Animal
SELECT * FROM Warehouse.StockItems
WHERE StockItemName LIKE '%urgent%' 
	OR
	StockItemName LIKE 'Animal%';



--2. Поставщиков, у которых не было сделано ни одного заказа (потом покажем как это делать через подзапрос, сейчас сделайте через JOIN)
SELECT * FROM Purchasing.Suppliers p1
LEFT JOIN Purchasing.PurchaseOrders p2
ON p1.SupplierID = p2.SupplierID
WHERE p2.PurchaseOrderID IS NULL;

--Второй вариант:
SELECT * FROM Purchasing.Suppliers
WHERE Purchasing.Suppliers.SupplierID NOT IN (
	SELECT DISTINCT SupplierID FROM Purchasing.PurchaseOrders);



/*3. Продажи с названием месяца, в котором была продажа, номером квартала, к которому относится продажа,
включите также к какой трети года относится дата - каждая треть по 4 месяца, дата забора заказа должна быть задана
, с ценой товара более 100$ либо количество единиц товара более 20.
*/
SELECT FORMAT(ord.OrderDate, 'MMMM', 'En-en') as [Month]
	, DATEPART(quarter, ord.OrderDate) as [Quarter]
	, CEILING(CAST(DATEPART(MONTH, ord.OrderDate) AS DEC(12,4)) / 4) AS [Third_of_the_Year]
	, COALESCE(ord_lines.UnitPrice, stock.UnitPrice) AS [Price]
	, ord_lines.Quantity AS [Quantity]
FROM Sales.Orders AS ord
INNER JOIN Sales.OrderLines AS ord_lines ON ord_lines.OrderID = ord.OrderID
INNER JOIN Warehouse.StockItems AS stock ON stock.StockItemID = ord_lines.StockItemID
WHERE ord.PickingCompletedWhen IS NOT NULL
	AND (COALESCE(ord_lines.UnitPrice, stock.UnitPrice) > 100 OR ord_lines.Quantity > 20);


/*Добавьте вариант этого запроса с постраничной выборкой пропустив первую 1000 и отобразив следующие 100 записей. 
Соритровка должна быть по номеру квартала, трети года, дате продажи. 
*/
SELECT FORMAT(ord.OrderDate, 'MMMM', 'En-en') as [Month]
	, DATEPART(quarter, ord.OrderDate) as [Quarter_of_the_Year]
	, CEILING(CAST(DATEPART(MONTH, ord.OrderDate) AS DEC(12,4)) / 4) AS [Third_of_the_Year]
	, COALESCE(ord_lines.UnitPrice, stock.UnitPrice) AS [Price]
	, ord_lines.Quantity AS [Quantity]
FROM Sales.Orders AS ord
INNER JOIN Sales.OrderLines AS ord_lines ON ord_lines.OrderID = ord.OrderID
INNER JOIN Warehouse.StockItems AS stock ON stock.StockItemID = ord_lines.StockItemID
WHERE ord.PickingCompletedWhen IS NOT NULL
	AND (COALESCE(ord_lines.UnitPrice, stock.UnitPrice) > 100 OR ord_lines.Quantity > 20)
ORDER BY [Quarter_of_the_Year],  [Third_of_the_Year], ord.OrderDate
OFFSET 1000 ROWS FETCH NEXT 100 ROWS ONLY;



--4. Заказы поставщикам, которые были исполнены за 2014й год с доставкой Road Freight или Post, добавьте название поставщика, имя контактного лица принимавшего заказ
SELECT orders.OrderDate, supplier.SupplierName, men.FullName
FROM Purchasing.PurchaseOrders as orders
	JOIN Application.DeliveryMethods as delivery_method on orders.DeliveryMethodID = delivery_method.DeliveryMethodID
	JOIN Purchasing.Suppliers as supplier ON orders.SupplierID = supplier.SupplierID
	JOIN Application.People AS men ON orders.ContactPersonID = men.PersonID
	JOIN Purchasing.SupplierTransactions AS trans ON orders.PurchaseOrderID = trans.PurchaseOrderID
WHERE delivery_method.DeliveryMethodName IN ('Road Freight', 'Post') 
	AND	trans.FinalizationDate >= '01.01.2014' AND trans.FinalizationDate < '01.01.2015';



--5. 10 последних по дате продаж с именем клиента и именем сотрудника, который оформил заказ.
SELECT TOP (10) ord.OrderDate, cust.CustomerName, men.FullName as [Salesman Full Name]
FROM Sales.Orders as ord
JOIN Sales.Customers as cust ON ord.CustomerID = cust.CustomerID
JOIN Application.People as men ON ord.SalespersonPersonID = men.PersonID
ORDER BY ord.OrderDate DESC;


--6. Все ид и имена клиентов и их контактные телефоны, которые покупали товар Chocolate frogs 250g 
SELECT DISTINCT cust.CustomerID, cust.CustomerName, cust.PhoneNumber 
FROM Sales.Orders as ord
JOIN Sales.Customers as cust ON ord.CustomerID = cust.CustomerID
JOIN sales.OrderLines as line ON ord.OrderID = line.OrderID
WHERE line.Description = 'Chocolate frogs 250g';