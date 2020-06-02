/*1) Взять готовую dll, подключить ее и продемонстрировать использование.
Например, https://sqlsharp.com
*/

use WideWorldImporters
go

sp_configure 'show advanced options', 1
go
reconfigure
go
sp_configure 'clr enabled', 1
go
reconfigure
go

alter database WideWorldImporters set trustworthy on
go

exec sp_changedbowner 'sa'
go


create assembly CLR authorization dbo
from 'C:\Users\vdgdi\source\repos\USQLCSharpProject1\USQLCSharpProject1\bin\Release\USQLCSharpProject1.dll'
with permission_set = unsafe
go

create function GetFiles(@dirname nvarchar(max))
returns table ([Name] nvarchar(max), CreationTime datetime, LastWriteTime datetime)
as external name CLR.TableFunctions.GetFiles
go

select * from GetFiles('.');