--1. ����������� � ���� 5 ������� ��������� insert � ������� Customers ��� Suppliers
INSERT INTO Purchasing.Suppliers (
	SupplierID
	,SupplierName
	,SupplierCategoryID
	,PrimaryContactPersonID
	,AlternateContactPersonID
	,DeliveryMethodID
	,DeliveryCityID
	,PostalCityID
	,SupplierReference
	,BankAccountName
	,BankAccountBranch
	,BankAccountCode
	,BankAccountNumber
	,BankInternationalCode
	,PaymentDays
	,InternalComments
	,PhoneNumber
	,FaxNumber
	,WebsiteURL
	,DeliveryAddressLine1
	,DeliveryAddressLine2
	,DeliveryPostalCode
	,PostalAddressLine1
	,PostalAddressLine2
	,PostalPostalCode
	,LastEditedBy
	)
VALUES (
		next value for sequences.SupplierID
		,'Fabrikam, Inc3.'
		,4
		,27
		,28
		,7
		,18557
		,18557
		,293092
		,'Fabrikam, Inc3.'
		,'Woodgrove Bank Lakeview Heights'
		,789568
		,4125863879
		,12546
		,30
		,'Marcos is not in on Mondays'
		,'(406) 555-0105'
		,'(406) 555-0106'
		,'http://www.graphicdesigninstitute.com'
		,'Level 2'
		,'45th Street'
		,64847
		,'PO Box 393'
		,'Willow'
		,64847
		,1)
		
		,(
		next value for sequences.SupplierID
		,'Fabrikam, Inc4.'
		,4
		,27
		,28
		,7
		,18557
		,18557
		,293092
		,'Fabrikam, Inc4.'
		,'Woodgrove Bank Lakeview Heights'
		,789568
		,4125863879
		,12546
		,30
		,'Marcos is not in on Mondays'
		,'(406) 555-0105'
		,'(406) 555-0106'
		,'http://www.graphicdesigninstitute.com'
		,'Level 2'
		,'45th Street'
		,64847
		,'PO Box 393'
		,'Willow'
		,64847
		,1)
		
		,(
		next value for sequences.SupplierID
		,'Fabrikam, Inc5.'
		,4
		,27
		,28
		,7
		,18557
		,18557
		,293092
		,'Fabrikam, Inc5.'
		,'Woodgrove Bank Lakeview Heights'
		,789568
		,4125863879
		,12546
		,30
		,'Marcos is not in on Mondays'
		,'(406) 555-0105'
		,'(406) 555-0106'
		,'http://www.graphicdesigninstitute.com'
		,'Level 2'
		,'45th Street'
		,64847
		,'PO Box 393'
		,'Willow'
		,64847
		,1)

		,(
		next value for sequences.SupplierID
		,'Fabrikam, Inc6.'
		,4
		,27
		,28
		,7
		,18557
		,18557
		,293092
		,'Fabrikam, Inc6.'
		,'Woodgrove Bank Lakeview Heights'
		,789568
		,4125863879
		,12546
		,30
		,'Marcos is not in on Mondays'
		,'(406) 555-0105'
		,'(406) 555-0106'
		,'http://www.graphicdesigninstitute.com'
		,'Level 2'
		,'45th Street'
		,64847
		,'PO Box 393'
		,'Willow'
		,64847
		,1)

		,(
		next value for sequences.SupplierID
		,'Fabrikam, Inc7.'
		,4
		,27
		,28
		,7
		,18557
		,18557
		,293092
		,'Fabrikam, Inc7.'
		,'Woodgrove Bank Lakeview Heights'
		,789568
		,4125863879
		,12546
		,30
		,'Marcos is not in on Mondays'
		,'(406) 555-0105'
		,'(406) 555-0106'
		,'http://www.graphicdesigninstitute.com'
		,'Level 2'
		,'45th Street'
		,64847
		,'PO Box 393'
		,'Willow'
		,64847
		,1);

--2. ������� 1 ������ �� Customers, ������� ���� ���� ���������
DELETE FROM Purchasing.Suppliers
WHERE SupplierID = 19;

--3. �������� ���� ������, �� ����������� ����� UPDATE
UPDATE Purchasing.Suppliers
SET SupplierCategoryID += 1
WHERE SupplierID = 20;

--4. �������� MERGE, ������� ������� ������� ������ � �������, ���� �� ��� ���, � ������� ���� ��� ��� ����
MERGE Purchasing.Suppliers AS [target]
USING (
		SELECT 'Unknown Supplier' AS [SupplierName]--���� ����� ���������
		UNION
		SELECT 'Trey Research' AS [SupplierName]--���� ����� ���������
) AS source
ON [target].SupplierName = [source].SupplierName
WHEN MATCHED
	THEN UPDATE
		SET [target].SupplierName = [source].SupplierName + '!Updated!'
WHEN NOT MATCHED
	THEN INSERT
			(SupplierID
			,SupplierName
			,SupplierCategoryID
			,PrimaryContactPersonID
			,AlternateContactPersonID
			,DeliveryMethodID
			,DeliveryCityID
			,PostalCityID
			,SupplierReference
			,BankAccountName
			,BankAccountBranch
			,BankAccountCode
			,BankAccountNumber
			,BankInternationalCode
			,PaymentDays
			,InternalComments
			,PhoneNumber
			,FaxNumber
			,WebsiteURL
			,DeliveryAddressLine1
			,DeliveryAddressLine2
			,DeliveryPostalCode
			,PostalAddressLine1
			,PostalAddressLine2
			,PostalPostalCode
			,LastEditedBy
			)
		VALUES
			(999
			,'Unknown Supplier.'
			,4
			,27
			,28
			,7
			,18557
			,18557
			,293092
			,'Unknown Supplier.'
			,'Woodgrove Bank Lakeview Heights'
			,789568
			,4125863879
			,12546
			,30
			,'Marcos is not in on Mondays'
			,'(406) 555-0105'
			,'(406) 555-0106'
			,'http://www.graphicdesigninstitute.com'
			,'Level 2'
			,'45th Street'
			,64847
			,'PO Box 393'
			,'Willow'
			,64847
			,1);


--5. �������� ������, ������� �������� ������ ����� bcp out � ��������� ����� bulk insert 
--��������� ������
--����� ��� �������� ���� � ����� sql.ru https://www.sql.ru/forum/493094/ne-rabotaet-xp-cmdshell
-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1
GO
-- To update the currently configured value for advanced options.
RECONFIGURE
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1
GO
-- To update the currently configured value for this feature.
RECONFIGURE
GO

EXEC master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.Orders" out "D:\SalesOrders.data" -T -w -t@@+@@ -S DESKTOP-4OQUVKT\SQL2017'
GO

--��������� �������
--�������� ����� ������� Sales.Orders
SELECT * INTO [WideWorldImporters].Sales.OrdersCopy
FROM [WideWorldImporters].Sales.Orders
WHERE 5 = 2;
--�������, ��� ������� ����, �� ��� ������
SELECT * FROM [WideWorldImporters].Sales.OrdersCopy;
--�� ������ ������ ������ ������ ������
truncate table [WideWorldImporters].Sales.OrdersCopy;

--��������
BEGIN TRAN
BULK INSERT [WideWorldImporters].Sales.OrdersCopy
	FROM "D:\SalesOrders.data"
	WITH
		(BATCHSIZE = 1000,
		DATAFILETYPE = 'widechar',
		FIELDTERMINATOR = '@@+@@',
		ROWTERMINATOR = '\n',
		KEEPNULLS,
		TABLOCK,
		CODEPAGE = 65001
		);
