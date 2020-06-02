/*2) Взять готовые исходники из какой-нибудь статьи, скомпилировать, подключить dll, продемонстрировать использование.
Например,
https://www.sqlservercentral.com/articles/xlsexport-a-clr-procedure-to-export-proc-results-to-excel

https://www.mssqltips.com/sqlservertip/1344/clr-string-sort-function-in-sql-server/

https://habr.com/ru/post/88396/
*/
--Взял пример с сайта https://habr.com/ru/post/88396/
--Скопировал код в новый проект, нажил build - получил готовую dll, которую и загружаю дальше
create assembly ClrFunction from 'C:\Users\vdgdi\source\repos\HW Task2\HW Task2\bin\Debug\HW Task2.dll'
go

CREATE FUNCTION [dbo].SplitStringCLR(@text [nvarchar](max), @delimiter [nchar](1))
RETURNS TABLE (
part nvarchar(max),
ID_ODER int
) WITH EXECUTE AS CALLER
AS
EXTERNAL NAME CLRFunction.UserDefinedFunctions.SplitString
go

select * from SplitStringCLR('You can never be overdressed or overeducated', ' ');