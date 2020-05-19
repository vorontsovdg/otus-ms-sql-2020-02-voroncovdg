-- Написать хранимую процедуру возвращающую Клиента с набольшей разовой суммой покупки. 
CREATE procedure dbo.usrGetBuyerWithMaxDeal_SP
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
exec dbo.usrGetBuyerWithMaxDeal_SP;

--Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
GO
CREATE PROCEDURE dbo.getSumOfBuys
    @BuyerId int
AS
BEGIN
SELECT 
    sum(il.UnitPrice * il.Quantity) as [TotalSumOfBuys]
FROM Sales.Invoices i 
Inner join Sales.InvoiceLines il on i.InvoiceID  = il.InvoiceID 
inner join Sales.Customers c on c.CustomerID = i.CustomerID
WHERE c.CustomerID = @BuyerId
END

GO
EXEC dbo.getSumOfBuys 15
