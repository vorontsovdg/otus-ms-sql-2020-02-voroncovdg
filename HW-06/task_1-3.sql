--1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
SELECT 
    CAST(YEAR(o.OrderDate) AS varchar(4)) + '/' + CAST(MONTH(o.OrderDate) AS varchar(2)) as order_month, 
    AVG(ol.UnitPrice) AS avg_price, 
    SUM(ol.UnitPrice * ol.Quantity) AS total_sum
FROM Sales.Orders o
JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
ORDER BY YEAR(o.OrderDate), MONTH(o.OrderDate);

--2. Отобразить все месяцы, где общая сумма продаж превысила 10 000
SELECT 
    CAST(YEAR(o.OrderDate) AS varchar(4)) + '/' + CAST(MONTH(o.OrderDate) AS varchar(2)) as order_month
FROM Sales.Orders o
JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
HAVING SUM(ol.UnitPrice * ol.Quantity) > 10000
ORDER BY YEAR(o.OrderDate), MONTH(o.OrderDate);

/*
3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц.
Группировка должна быть по году и месяцу.
*/
--Группировка должна быть по году и месяцу. -> не совсем понял, что означает такая задача по группировке, на всякий случай сделал обычный и rollup
--первый вариант

SELECT CAST(YEAR(o.OrderDate) as varchar(4)) + '/' + CAST(MONTH(o.OrderDate) as varchar(2)) as order_month,
        ol.StockItemID as ItemId,
        SUM(ol.UnitPrice * ol.Quantity) as total_sum,
        MIN(o.OrderDate) as min_date,
        SUM(ol.Quantity) as Quantity
FROM Sales.Orders o
JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate), ol.StockItemID
HAVING SUM(ol.Quantity) < 50;

--второй

SELECT CAST(YEAR(o.OrderDate) as varchar(4)) + '/' + CAST(MONTH(o.OrderDate) as varchar(2)) as order_month,
        ol.StockItemID as ItemId,
        SUM(ol.UnitPrice * ol.Quantity) as total_sum,
        MIN(o.OrderDate) as min_date,
        SUM(ol.Quantity) as Quantity
FROM Sales.Orders o
JOIN Sales.OrderLines ol ON o.OrderID = ol.OrderID
GROUP BY ROLLUP(YEAR(o.OrderDate), MONTH(o.OrderDate), ol.StockItemID)
HAVING SUM(ol.Quantity) < 50;



