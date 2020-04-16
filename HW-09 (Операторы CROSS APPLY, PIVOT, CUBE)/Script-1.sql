/*1. Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
Название клиента
МесяцГод Количество покупок

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys
имя клиента нужно поменять так чтобы осталось только уточнение
например исходное Tailspin Toys (Gasport, NY) - вы выводите в имени только Gasport,NY
дата должна иметь формат dd.mm.yyyy например 25.12.2019

Например, как должны выглядеть результаты:
InvoiceMonth Peeples Valley, AZ Medicine Lodge, KS Gasport, NY Sylvanite, MT Jessie, ND
01.01.2013 3 1 4 2 2
01.02.2013 7 3 4 2 1
*/
SELECT *
FROM (
    SELECT
        substring(c.CustomerName , charindex('(', c.customername) + 1, len(c.CustomerName) - charindex('(', c.CustomerName )-1) as [CustomerName]
        , CAST(format( dateadd(MM, datediff(MM, 0, i.InvoiceDate), 0), 'dd.MM.yyyy') as Date) as [Month]
    FROM Sales.Customers c
    join Sales.Invoices i on i.CustomerID = c.CustomerID 
    where c.CustomerID BETWEEN 2 and 6
    ) as s
PIVOT 
    (COUNT([CustomerName])
    FOR [CustomerName] in (
                [Sylvanite, MT]
                ,[Peeples Valley, AZ]
                ,[Medicine Lodge, KS]
                ,[Gasport, NY]
                ,[Jessie, ND]
                )
    ) as pvt;

/*
 * 2. Для всех клиентов с именем, в котором есть Tailspin Toys
вывести все адреса, которые есть в таблице, в одной колонке

Пример результатов
CustomerName AddressLine
Tailspin Toys (Head Office) Shop 38
Tailspin Toys (Head Office) 1877 Mittal Road
Tailspin Toys (Head Office) PO Box 8975
Tailspin Toys (Head Office) Ribeiroville
*/
with tmp as (
            SELECT [CustomerName]
                   , [AddressType]
                   , [AddressValue]
            FROM (
                 SELECT 
                    substring(c.CustomerName , charindex('(', c.customername) + 1, len(c.CustomerName) - charindex('(', c.CustomerName )-1) as [CustomerName]
                    , c.DeliveryAddressLine1 
                    , c.DeliveryAddressLine2 
                    , c.PostalAddressLine1 
                    , c.PostalAddressLine2 
                 FROM Sales.Customers AS C
                 where c.CustomerName LIKE '%Tailspin Toys%') as t
            UNPIVOT (
                    [AddressValue] for [AddressType] in (DeliveryAddressLine1
                                        , DeliveryAddressLine2
                                        , PostalAddressLine1
                                        , PostalAddressLine2)) as unpvt)
select tmp.CustomerName
       , tmp.AddressValue
from tmp;
                                    
/*
 * 3. В таблице стран есть поля с кодом страны цифровым и буквенным
сделайте выборку ИД страны, название, код - чтобы в поле был либо цифровой либо буквенный код
Пример выдачи

CountryId CountryName Code
1 Afghanistan AFG
1 Afghanistan 4
3 Albania ALB
3 Albania 8
 */

with tmp as (
            SELECT 
                CountryID
                , CountryName
                , [CountryCodeType]
                , [Code]
            FROM (
                    SELECT 
                        c.CountryID 
                        , c.CountryName 
                        , cast(c.IsoAlpha3Code as nvarchar) as [IsoAlpha3Code]
                        , cast(c.IsoNumericCode  as nvarchar) as [IsoNumericCode]
                    FROM Application.Countries c ) as t
            unpivot(
                [Code] for [CountryCodeType] in ([IsoAlpha3Code]
                                             , [IsoNumericCode])) as unpvt)
 select tmp.CountryID
        , tmp.CountryName
        , tmp.Code
from tmp;

/*
 * 4. Перепишите ДЗ из оконных функций через CROSS APPLY
Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
 */

SELECT c.CustomerID, 
    c.CustomerName
    , TopProducts.*
FROM  Sales.Customers c
CROSS APPLY 
(
    SELECT DISTINCT TOP 2 
        il.StockItemID 
        , wsi.StockItemName as [Name] 
        , wsi.UnitPrice as [Price]
        , i.InvoiceDate as [Date]
    FROM Sales.InvoiceLines il
    INNER JOIN Sales.Invoices i
        ON i.InvoiceID=il.InvoiceLineID
    INNER JOIN Warehouse.StockItems wsi
        ON il.StockItemID=wsi.StockItemID
    WHERE i.CustomerID=c.CustomerID
    ORDER BY wsi.UnitPrice DESC
) AS TopProducts

