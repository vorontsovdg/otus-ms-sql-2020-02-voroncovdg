/*3) Написать полностью свое (что-то одно):
* Тип: JSON с валидацией, IP / MAC - адреса, ...
* Функция: работа с JSON, ...
* Агрегат: аналог STRING_AGG, ...
* (любой ваш вариант)
*/
--простенькая регулярка

create assembly regexp from 'C:\Users\vdgdi\source\repos\USQLCSharpProject3\USQLCSharpProject3\bin\Debug\USQLCSharpProject3.dll'
go

create function IsMatch(@inputText nvarchar(max), @pattern nvarchar(max))
returns bit
as external name regexp.re.match
go

select dbo.IsMatch('12345', '\d+');