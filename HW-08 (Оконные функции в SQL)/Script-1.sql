/*1. Напишите запрос с временной таблицей и перепишите его с табличной переменной. Сравните планы.
В качестве запроса с временной таблицей и табличной переменной можно взять свой запрос или следующий запрос:
Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года (в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки)
Выведите id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом
Пример
Дата продажи Нарастающий итог по месяцу
2015-01-29 4801725.31
2015-01-30 4801725.31
2015-01-31 4801725.31
2015-02-01 9626342.98
2015-02-02 9626342.98
2015-02-03 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

--временная таблица
/*
 * SQL Server Execution Times:
   CPU time = 106 ms,  elapsed time = 113 ms.
 */
SET STATISTICS TIME ON;
WITH tmp AS (
            SELECT 
                i.InvoiceID 
                , c.CustomerName 
                , i.InvoiceDate 
                , SUM(il.UnitPrice * il.Quantity) AS [InvoiceSum]
            FROM Sales.Invoices i 
            JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
            JOIN Sales.Customers c ON i.CustomerID = c.CustomerID 
            WHERE i.InvoiceDate >= '01.01.2015'
            GROUP BY 
                i.InvoiceID
                , c.CustomerName 
                , i.InvoiceDate )
SELECT 
    *
    , SUM(InvoiceSum) OVER (ORDER BY YEAR(InvoiceDate), MONTH(InvoiceDate)) AS [Нарастающий итог за месяц]
FROM tmp
ORDER BY InvoiceDate;


--без оконной функции
/*
 * SQL Server Execution Times:
   CPU time = 122237 ms,  elapsed time = 152684 ms.
 */
WITH tmp AS (
            SELECT 
                i.InvoiceID 
                , c.CustomerName 
                , i.InvoiceDate 
                , SUM(il.UnitPrice * il.Quantity) AS [InvoiceSum]
            FROM Sales.Invoices i 
            JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
            JOIN Sales.Customers c ON i.CustomerID = c.CustomerID 
            WHERE i.InvoiceDate >= '01.01.2015'
            GROUP BY 
                i.InvoiceID
                , c.CustomerName 
                , i.InvoiceDate )
SELECT 
*
, (SELECT 
    SUM(InvoiceSum)
    FROM tmp
    WHERE tmp.InvoiceDate <= EOMONTH(t.InvoiceDate)) AS [Нарастающий итог за месяц]
FROM tmp t;
/*
 * Разница в скорости выполнения очень заметна.
 * Оконные фукнции выполняют свою работу гораздо быстрее
 */

/*2. Вывести список 2х самых популярных продуктов (по кол-ву проданных) в каждом месяце за 2016й год (по 2 самых популярных продукта в каждом месяце)
 */

WITH AllMonths AS (SELECT 
                    FORMAT(i.InvoiceDate , 'yyyy.MM') AS [Месяц продажи]
                    , s.StockItemName 
                    , SUM(il.Quantity ) AS [Total]
                FROM Sales.Invoices i 
                JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID 
                JOIN Warehouse.StockItems s ON il.StockItemID  = s.StockItemID 
                WHERE YEAR(i.InvoiceDate) = 2016
                GROUP BY FORMAT(i.InvoiceDate , 'yyyy.MM'), s.StockItemName
                )
    ,Ranked AS (SELECT 
                *,
                (IIF(ROW_NUMBER () OVER(PARTITION BY a.[Месяц продажи] ORDER BY a.Total DESC) <= 2, 'Top Ranked', 'Trash')) AS [Position]
                FROM AllMonths a
                )
SELECT
    *
FROM Ranked r
WHERE r.Position = 'Top Ranked'
ORDER BY r.[Месяц продажи]
;

/*
 * 3. Функции одним запросом
Посчитайте по таблице товаров, в вывод также должен попасть ид товара, название, брэнд и цена
пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
посчитайте общее количество товаров и выведете полем в этом же запросе
посчитайте общее количество товаров в зависимости от первой буквы названия товара
отобразите следующий id товара исходя из того, что порядок отображения товаров по имени
предыдущий ид товара с тем же порядком отображения (по имени)
названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
сформируйте 30 групп товаров по полю вес товара на 1 шт
Для этой задачи НЕ нужно писать аналог без аналитических функций
 */

SELECT 
    si.StockItemID 
    , si.StockItemName 
    , si.Brand 
    , si.UnitPrice 
    , (ROW_NUMBER () OVER(PARTITION BY LEFT(si.StockItemName, 1) ORDER BY si.StockItemName )) AS [Нумерация по названию и букве]
    , (COUNT(*) OVER()) AS [Общее количество товара]
    , (COUNT(*) OVER(PARTITION BY LEFT(si.StockItemName, 1))) AS [Кол-во товаров по первой букве]
    , (LEAD(si.StockItemID) OVER(ORDER BY si.StockItemName ) ) AS [След. ID]
    , (LAG(si.StockItemID) OVER(ORDER BY si.StockItemName)) AS [Пред-й ID]
    , (LAG(si.StockItemName, 2, 'No items') OVER(ORDER BY si.StockItemName)) AS [Название 2 строки назад]
    , (NTILE(30) OVER(ORDER BY si.TypicalWeightPerUnit)) AS [Группа товара]
FROM Warehouse.StockItems si ;



/*
 * 4. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал
В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки
 */
WITH trans AS (SELECT 
                    si.SalespersonPersonID 
                    , p.FullName 
                    , cu.CustomerID 
                    , cu.CustomerName 
                    , ct.TransactionDate 
                    , ct.TransactionAmount 
                    , (ROW_NUMBER () OVER(PARTITION BY si.SalespersonPersonID ORDER BY ct.TransactionDate DESC)) AS [Номер транзакции]
                FROM Sales.CustomerTransactions ct
                INNER JOIN Sales.Customers cu ON ct.CustomerID = cu.CustomerID 
                INNER JOIN Sales.Invoices si ON si.InvoiceID = ct.InvoiceID 
                INNER JOIN Application.People p ON p.PersonID = si.SalespersonPersonID)
SELECT 
    SalespersonPersonID
    , FullName
    , CustomerID
    , CustomerName
    , TransactionDate
    , TransactionAmount
FROM trans
WHERE [Номер транзакции] = 1;


/*
 * 5. Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
 */

WITH tmp AS (SELECT DISTINCT
                i.CustomerID 
                , cu.CustomerName 
                , si.StockItemID 
                , si.StockItemName 
                , si.UnitPrice 
                , i.InvoiceDate 
                , (ROW_NUMBER() OVER(PARTITION BY i.CustomerID ORDER BY si.UnitPrice DESC )) AS [Место по стоимости]
            FROM Sales.Invoices i 
            INNER JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID 
            INNER JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID 
            INNER JOIN Sales.Customers cu ON cu.CustomerID = i.CustomerID )
SELECT
    CustomerID
    , CustomerName 
    , StockItemID
    , StockItemName
    , UnitPrice
    , InvoiceDate
FROM tmp
WHERE [Место по стоимости] <= 2
ORDER BY CustomerID;