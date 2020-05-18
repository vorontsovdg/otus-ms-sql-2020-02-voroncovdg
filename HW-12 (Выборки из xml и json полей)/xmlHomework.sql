/* 1. Загрузить данные из файла StockItems.xml в таблицу Warehouse.StockItems.
Существующие записи в таблице обновить, отсутствующие добавить сопоставлять записи по полю StockItemName).
Файл StockItems.xml в личном кабинете.
*/

DECLARE @x xml
SELECT @x = WH
FROM openrowset (BULK 'D:\StockItems-188-f89807.xml', single_blob) as WarehouseStockItems(WH)

declare @hdoc int
EXEC sp_xml_preparedocument @hdoc output, @x 
merge Warehouse.StockItems as target
using
    (
    SELECT *
        FROM OPENXML (@hdoc, '/StockItems/Item', 3)
        WITH    ([StockItemName] NVARCHAR(100) './@Name'
                , [SupplierID] int
                , [UnitPackageID] int './Package/UnitPackageID'
                , [OuterPackageID] int './Package/OuterPackageID'
                , [QuantityPerOuter] int './Package/QuantityPerOuter'
                , [TypicalWeightPerUnit] decimal(18,3) './Package/TypicalWeightPerUnit'
                , [LeadTimeDays] int './LeadTimeDays'
                , [IsChillerStock] bit './IsChillerStock'
                , [TaxRate] decimal(18,3) './TaxRate'
                , [UnitPrice] decimal(18,2) './UnitPrice'

        ) as xmlfile) as source
        on target.[StockItemName] = source.[StockItemName]
        WHEN matched
        THEN
            update set
                target.[SupplierID] = source.[SupplierID]
                , target.[UnitPackageID] = source.[UnitPackageID]
                , target.[OuterPackageID] = source.[OuterPackageID]
                , target.[QuantityPerOuter] = source.[QuantityPerOuter]
                , target.[TypicalWeightPerUnit] = source.[TypicalWeightPerUnit]
                , target.[LeadTimeDays] = source.[LeadTimeDays]
                , target.[IsChillerStock] = source.[IsChillerStock]
                , target.[TaxRate] = source.[TaxRate]
                , target.[UnitPrice] = source.[UnitPrice]
        WHEN not matched
        THEN
            insert ([StockItemName]
                    , [SupplierID]
                    , [UnitPackageID]
                    , [OuterPackageID]
                    , [QuantityPerOuter]
                    , [TypicalWeightPerUnit]
                    , [LeadTimeDays]
                    , [IsChillerStock]
                    , [TaxRate]
                    , [UnitPrice]
                    , [LastEditedBy]--Я добавил руками запись в колонку LastEditedBy, иначе ругался,что не может быть пустых значений
                    )
            values (source.[StockItemName]
                    , source.[SupplierID]
                    , source.[UnitPackageID]
                    , source.[OuterPackageID]
                    , source.[QuantityPerOuter]
                    , source.[TypicalWeightPerUnit]
                    , source.[LeadTimeDays]
                    , source.[IsChillerStock]
                    , source.[TaxRate]
                    , source.[UnitPrice]
                    , 1 
                    );

exec sp_xml_removedocument @hdoc;

/*2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml

Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML.
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы.
*/
select 
    si.StockItemName as [@Name]
    , si.SupplierID as [SupplierID]
    , si.UnitPackageID as [Package/UnitPackageId]
    , si.OuterPackageID as [Package/OuterPackageID]
    , si.QuantityPerOuter as [Package/QuantityPerOuter]
    , si.TypicalWeightPerUnit as [Package/TypicalWeightPerUnit]
    , si.LeadTimeDays as [LeadTimeDays]
    , si.IsChillerStock as [IsChillerStock]
    , si.TaxRate as [TaxRate]
    , si.UnitPrice as [UnitPrice]
from Warehouse.StockItems si
for xml path('Item'), root('StockItems');

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

select 
    si.StockItemID
    , si.StockItemName
    , json_value(si.CustomFields, '$.CountryOfManufacture') as [CountryOfManufacture]
    , json_value(si.CustomFields, '$.Tags[0]') as [FirstTag]
from Warehouse.StockItems si;

/*

4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести:
- StockItemID
- StockItemName


Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.
*/

SELECT
    si.StockItemID
    , si.StockItemName
FROM Warehouse.StockItems si
CROSS APPLY openjson(si.CustomFields, '$.Tags') js
WHERE js.[value] = 'Vintage';

-- (опционально) все теги (из CustomFields) через запятую в одном поле
SELECT
    si.StockItemID
    , si.StockItemName
    , string_agg(cast (js.[value] as nvarchar(max)), ', ') as [Tag]
FROM Warehouse.StockItems si
CROSS APPLY openjson(si.CustomFields, '$.Tags') js
GROUP BY si.StockItemID, si.StockItemName

/*
5. Пишем динамический PIVOT.
По заданию из занятия “Операторы CROSS APPLY, PIVOT, CUBE”.
Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
Название клиента
МесяцГод Количество покупок

Нужно написать запрос, который будет генерировать результаты для всех клиентов.
Имя клиента указывать полностью из CustomerName.
Дата должна иметь формат dd.mm.yyyy например 25.12.2019 
*/

DECLARE @AllCustomers NVARCHAR(max)
set @AllCustomers = (
    select '[' + tmp.[Name] + ']' + ',' as 'data()'
    from (
        select distinct customerName as [Name]
        from Sales.Customers
    ) tmp
    for xml path('')
)
set @AllCustomers = left(@AllCustomers, len(@AllCustomers) - 1)

DECLARE @PivotQuerry NVARCHAR(MAX) = 'select 
    StartOfMonth, ' + @AllCustomers + '
from
    (
    select 
        SaleDate.[StartOfMonth],
        c.CustomerName, 
        i.InvoiceID
    from Sales.Customers as c
        join Sales.Invoices as i
        on i.CustomerID = c.CustomerID
    cross apply
        (
            select 
            format(dateadd(mm, datediff(mm, 0, i.InvoiceDate), 0), ''dd.MM.yyyy'') as [StartOfMonth]
        ) as SaleDate
    ) as t pivot(count(t.[InvoiceID]) for t.CustomerName in(' + @AllCustomers + ')) as p
order by cast(p.StartOfMonth as date);'

EXECUTE sp_executesql @PivotQuerry;