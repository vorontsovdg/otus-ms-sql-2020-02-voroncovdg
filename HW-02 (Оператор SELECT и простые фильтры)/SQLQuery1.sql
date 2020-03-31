--1. ��� ������, � ������� � �������� ���� ������� urgent ��� �������� ���������� � Animal
SELECT * FROM Warehouse.StockItems
WHERE StockItemName LIKE '%urgent%' 
	OR
	StockItemName LIKE 'Animal%';



--2. �����������, � ������� �� ���� ������� �� ������ ������ (����� ������� ��� ��� ������ ����� ���������, ������ �������� ����� JOIN)
SELECT * FROM Purchasing.Suppliers p1
LEFT JOIN Purchasing.PurchaseOrders p2
ON p1.SupplierID = p2.SupplierID
WHERE p2.PurchaseOrderID IS NULL;

--������ �������:
SELECT * FROM Purchasing.Suppliers
WHERE Purchasing.Suppliers.SupplierID NOT IN (
	SELECT DISTINCT SupplierID FROM Purchasing.PurchaseOrders);



/*3. ������� � ��������� ������, � ������� ���� �������, ������� ��������, � �������� ��������� �������,
�������� ����� � ����� ����� ���� ��������� ���� - ������ ����� �� 4 ������, ���� ������ ������ ������ ���� ������
, � ����� ������ ����� 100$ ���� ���������� ������ ������ ����� 20.
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


/*�������� ������� ����� ������� � ������������ �������� ��������� ������ 1000 � ��������� ��������� 100 �������. 
���������� ������ ���� �� ������ ��������, ����� ����, ���� �������. 
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



--4. ������ �����������, ������� ���� ��������� �� 2014� ��� � ��������� Road Freight ��� Post, �������� �������� ����������, ��� ����������� ���� ������������ �����
SELECT orders.OrderDate, supplier.SupplierName, men.FullName
FROM Purchasing.PurchaseOrders as orders
	JOIN Application.DeliveryMethods as delivery_method on orders.DeliveryMethodID = delivery_method.DeliveryMethodID
	JOIN Purchasing.Suppliers as supplier ON orders.SupplierID = supplier.SupplierID
	JOIN Application.People AS men ON orders.ContactPersonID = men.PersonID
	JOIN Purchasing.SupplierTransactions AS trans ON orders.PurchaseOrderID = trans.PurchaseOrderID
WHERE delivery_method.DeliveryMethodName IN ('Road Freight', 'Post') 
	AND	trans.FinalizationDate >= '01.01.2014' AND trans.FinalizationDate < '01.01.2015';



--5. 10 ��������� �� ���� ������ � ������ ������� � ������ ����������, ������� ������� �����.
SELECT TOP (10) ord.OrderDate, cust.CustomerName, men.FullName as [Salesman Full Name]
FROM Sales.Orders as ord
JOIN Sales.Customers as cust ON ord.CustomerID = cust.CustomerID
JOIN Application.People as men ON ord.SalespersonPersonID = men.PersonID
ORDER BY ord.OrderDate DESC;


--6. ��� �� � ����� �������� � �� ���������� ��������, ������� �������� ����� Chocolate frogs 250g 
SELECT DISTINCT cust.CustomerID, cust.CustomerName, cust.PhoneNumber 
FROM Sales.Orders as ord
JOIN Sales.Customers as cust ON ord.CustomerID = cust.CustomerID
JOIN sales.OrderLines as line ON ord.OrderID = line.OrderID
WHERE line.Description = 'Chocolate frogs 250g';