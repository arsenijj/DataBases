use simpledb1

create table client (
	id int,
	firstName nvarchar(50),
	secondName nvarchar(50),
	patronymic nvarchar(50),
	age int,
)

declare @n int = 0;
declare @a char = 'А', @z char = 'я', @w int, @l int
SET @w = ascii(@z) - ascii(@a);
SET @l = ascii(@a);
declare @name nvarchar(50) = 'Хан';
declare @surname nvarchar(50) = 'Ким';
declare @patronymic nvarchar(50) = 'Чу';
declare @age smallint;
truncate table client
while (@n < 100000) 
	begin 
		set @age = rand()*(75-20)+20;
		if (len(@name)>18) SET @name = 'Хан' else SET @name = @name+char(round(rand() * @w, 0) + @l);
		if (len(@surname)>27) SET @surname = 'Ким' else SET @surname = @surname+char(round(rand() * @w, 0) + @l);
		if (len(@patronymic)>21) SET @patronymic = 'Чу' else SET @patronymic = @patronymic+char(round(rand() * @w, 0) + @l);
		insert into client(id,firstName,secondName,patronymic,age) values (@n, @name, @surname, @patronymic, @age);
		set @n += 1;
	end 


--представление 1 
create view auto_client 
with encryption 
as select clientID, mileage, registrationNumber, carEngineType
	from automobile
	left join client on client.id = automobile.clientID

select * from auto_client
drop view auto_client

--представление 2
create view client_age_more_than_35 
with encryption 
as select id as 'Порядк. номер кл.', 
		  firstName + ' ' + secondname as 'Имя Фамилия' 
from client where age > 35 

select * from client_age_more_than_35 
drop view client_age_more_than_35

--представление 3
create view automobile_saratov
with encryption 
as select [registrationNumber] as 'Гос. номер',
		  [mark] as 'Марка',
		  [model] as 'Модель'
from automobile where registrationNumber like '%64'

select * from automobile_saratov
drop view automobile_saratov

--обновляемое представление 

create view automobile_mileage 
with encryption 
as select autoID, mileage, yearOfManufacture 
from automobile where mileage < 100000 and mileage > 50000
with check option

select * from automobile_mileage

insert into automobile_mileage values (NEWID(), 75100, 2020), (NEWID(), 75101, 2020)
insert into automobile_mileage values (NEWID(), 49100, 2020), (NEWID(), 75101, 2020)
select * from automobile where yearOfManufacture = 2020 and mileage in(75100,75101)
select * from automobile_mileage where yearOfManufacture = 2020 and mileage in(75100,75101)

delete from automobile_mileage where mileage < 76000

drop view automobile_mileage

--создание индексированного представления 
SET NUMERIC_ROUNDABORT OFF; 
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON;

create view automobile_client_indexed
			with schemabinding
as select dbo.automobile.numberAutomobile,
		  dbo.automobile.vin, 
		  dbo.automobile.registrationNumber,
		  dbo.automobile.mileage
from dbo.automobile 
where registrationNumber like '%А%6%' or numberAutomobile = 1000
drop view automobile_client_indexed

select * from automobile_client_indexed with (noexpand)

create unique clustered index cl_indx_automobile_client 
on automobile_client_indexed(registrationNumber,numberAutomobile)

drop index cl_indx_automobile_client on automobile_client_indexed
