 /*
 1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
 Я искал клиента с максимальной разовой суммой покупки, если надо посчитать суммарно все покупки по клиенту, то переделаю
 */
CREATE function dbo.usrGetBuyerWithMaxDeal()
returns nvarchar(100)
as
BEGIN
return
        (select top (1) t.CustomerName from 
            (SELECT 
                c.CustomerName
                , i.InvoiceID 
                , sum(il.UnitPrice * il.Quantity ) as [TotalSum]
            FROM Sales.Invoices i 
            Inner join Sales.InvoiceLines il on i.InvoiceID  = il.InvoiceID 
            inner join Sales.Customers c on c.CustomerID = i.CustomerID
            group by i.InvoiceID , c.CustomerName) as t
        order by t.[TotalSum] desc)
END

GO
DECLARE @BigBuyer NVARCHAR(100)
SET @BigBuyer = dbo.usrGetBuyerWithMaxDeal()
print N'The biggest buy was made by: ' + @BigBuyer
GO

/*2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/
CREATE PROCEDURE dbo.usrGetTotalSalesForBuyer
    @BuyerId int
AS
BEGIN
SELECT 
    c.CustomerName
    , SUM(il.UnitPrice * il.Quantity) as [TotalSum]
FROM Sales.Invoices i
inner join Sales.InvoiceLines il on i.InvoiceID = il.InvoiceID
inner join Sales.Customers c on c.CustomerID = i.CustomerID
WHERE c.CustomerID = @BuyerId
GROUP BY c.CustomerName
END
GO

EXEC dbo.usrGetTotalSalesForBuyer 12
GO
--3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
--сделал хранимую процедуру к первой функции
CREATE PROCEDURE dbo.usr_SP_GetBuyerWithMaxDeal
as
BEGIN
    select top (1) t.CustomerName from 
            (SELECT 
                c.CustomerName
                , i.InvoiceID 
                , sum(il.UnitPrice * il.Quantity ) as [TotalSum]
            FROM Sales.Invoices i 
            Inner join Sales.InvoiceLines il on i.InvoiceID  = il.InvoiceID 
            inner join Sales.Customers c on c.CustomerID = i.CustomerID
            group by i.InvoiceID , c.CustomerName) as t
        order by t.[TotalSum] desc
END
GO

EXEC dbo.usr_SP_GetBuyerWithMaxDeal
go
/*В чем разница в производительности и почему? - Да чёрт его знает) На моих примерах примерно одинаково по 
скорости отработало, т.к. делали по сути одно и то же
Я понимаю, что потенциально функции могут куда сильнее замедлять работу сервера,
т.к. если, например, мы написали какую-то свою сложную функцию, а потом испоьльзуем 
ее в другом запросе, то если запрос криво написан, то жестко замедлится сервер.
 А сохраненный запрос, это вроде как 
вьюха с плюшками в виде возможности передавать агрументы при его вызове
*/


/*4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/
--Пишем функцию, возвращающую через запятую список товаров для клиента, купленных им за 3 последних раза
go
CREATE FUNCTION dbo.FindBuys(@BuyerId int)
RETURNS TABLE
AS
RETURN (
        SELECT top(3)
            i.InvoiceID
            , i.InvoiceDate
            , cu.CustomerID
            , string_agg(cast(si.StockItemName as nvarchar(max)), ', ') as [Покупки]
        FROM Sales.Invoices i
        INNER JOIN Sales.InvoiceLines il on il.InvoiceID = i.InvoiceID
        INNER join Sales.Customers cu on cu.CustomerID = i.CustomerID
        INNER JOIN Warehouse.StockItems si on si.StockItemID = il.StockItemID
        WHERE cu.CustomerID = @BuyerId
        group by i.InvoiceID, i.InvoiceDate, cu.CustomerID
        order by i.InvoiceDate desc)
GO

SELECT
    c.CustomerID, c.CustomerName, Buys.InvoiceID, Buys.InvoiceDate, Buys.[Покупки]
FROM Sales.Customers c
CROSS APPLY(
    select tmp.[Покупки]
            , tmp.InvoiceDate
            , tmp.InvoiceID
    FROM dbo.FindBuys(c.CustomerID) tmp
) as Buys
