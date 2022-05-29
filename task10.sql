create DATABASE AutorepairDW
ON PRIMARY
( NAME = N'AutorepairDW', 
  FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\Autorepair.mdf',
  SIZE = 51200KB, FILEGROWTH = 10240KB )
 LOG ON
( NAME = N'Autorepair_log', 
  FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\Autorepair_log.ldf',
  SIZE = 10240KB, FILEGROWTH = 10% )
 COLLATE Cyrillic_General_100_CI_AI

ALTER DATABASE AutorepairDW SET RECOVERY SIMPLE WITH NO_WAIT;
ALTER DATABASE AutorepairDW SET AUTO_SHRINK OFF

USE AutorepairDW

CREATE TABLE [Date_partition] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [date_not_separated] datetime,
  [year] int,
  [month] int,
  [day] int,
  [hour] int,
  [minute] int,
  [month_name] nvarchar(50),
  [day_name] nvarchar(50)
)
GO

CREATE TABLE [Geography] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [country] nvarchar(50),
  [region] nvarchar(50),
  [index] int,
  [city] nvarchar(50),
  [district] nvarchar(50)
)
GO

CREATE TABLE [Cars] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [class_id] int,
  [class_cost_id] int,
  [mark_id] int,
  [model_id] int
)
GO

CREATE TABLE [Mark] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [name] nvarchar(50)
)
GO

CREATE TABLE [Model] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [name] nvarchar(50)
)
GO

CREATE TABLE [Class] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [name] nvarchar(50)
)
GO



CREATE TABLE [Class_cost] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [name] nvarchar(50)
)
GO

CREATE TABLE [Client] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [first_name] nvarchar(50),
  [second_name] nvarchar(50),
  [last_name] nvarchar(50),
  [age] int,
  [gender] nvarchar(50)
)
GO

CREATE TABLE [Cheque] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [purchase_amount] money,
  [date_id] int,
  [client_id] int,
  [geography_id] int,
  [car_id] int
)
GO

ALTER TABLE [Cheque] ADD FOREIGN KEY ([geography_id]) REFERENCES [Geography] ([id])
GO

ALTER TABLE [Cheque] ADD FOREIGN KEY ([date_id]) REFERENCES [Date_partition] ([id])
GO

ALTER TABLE [Cheque] ADD FOREIGN KEY ([car_id]) REFERENCES [Cars] ([id])
GO

ALTER TABLE [Cars] ADD FOREIGN KEY ([mark_id]) REFERENCES [Mark] ([id])
GO

ALTER TABLE [Cars] ADD FOREIGN KEY ([class_cost_id]) REFERENCES [Class_cost] ([id])
GO

ALTER TABLE [Cars] ADD FOREIGN KEY ([model_id]) REFERENCES [Model] ([id])
GO

ALTER TABLE [Cars] ADD FOREIGN KEY ([class_id]) REFERENCES [Class] ([id])
GO

ALTER TABLE [Cheque] ADD FOREIGN KEY ([client_id]) REFERENCES [Client] ([id])
GO


insert into Class(name)
values	(N'A'), (N'B'), (N'C'), (N'D'), (N'E'), (N'F'), 
		(N'G'), (N'H'), (N'SUV1'), (N'SUV2'), (N'MPV')

insert into [Class_cost](name)
values	(N'бюджет'), (N'средний'), (N'премиум'), (N'спорт'), (N'супер-спорт')

insert into model(name) 
values	('Priora'),
		('Model 3'),
		('Model S'),
		('Granta'),
		('2109'),
		('Vesta'),
		('Vesta'),
		('Bentayaga'),
		('2114')

insert into mark(name)
values	(N'ВАЗ'),
		(N'Tesla'),
		(N'LADA'),
		(N'Ford'),
		(N'NISSAN'),
		(N'MAZDA'),
		(N'Acura'),
		(N'Toyota'),
		(N'Ferrari'),
		(N'Land Rover'),
		(N'KIA'),
		(N'HONDA'),
		(N'Maybach'),
		('Cadillac')


declare @n int = 0;
declare @country nvarchar(25) = 'Россия';
declare @index bigint; 
declare @city nvarchar(25) = 'Саратов';
declare @region nvarchar(25) = 'Южный';
declare @district nvarchar(25) = 'Окт';
declare @a char = 'А', @z char = 'я', @w int, @l int;
		SET @w = ascii(@z) - ascii(@a);
		SET @l = ascii(@a);

while (@n<99000)
	begin 
		--страна
		if (len(@country)>14) SET @country = 'Россия' else SET @country += char(round(rand() * @w, 0) + @l);
		--индекс
		SET @index = FLOOR(RAND()*(800000-350000)+350000);
		--регион
		if (len(@region)>15) SET @region = 'Южный' else SET @region += char(round(rand() * @w, 0) + @l);
		--город 
		if (len(@city)>21) SET @city = 'Саратов' else SET @city += char(round(rand() * @w, 0) + @l);
		--район
		if (len(@district)>13) SET @district = 'Окт' else SET @district += char(round(rand() * @w, 0) + @l);
		insert into Geography(country, region, [index], city, district)
			values(@country,@region, @index, @city, @district);
		set @n += 1
	end 

select * from Client
declare @n1 int = 0;
declare @first_name nvarchar(25) = 'Сеня';
declare @age int; 
declare @second_name nvarchar(25) = 'Никитин';
declare @last_name nvarchar(25) = 'Горович';
declare @gender nvarchar(25) = 'Муж';

declare @a char = 'А', @z char = 'я', @w int, @l int;
		SET @w = ascii(@z) - ascii(@a);
		SET @l = ascii(@a);

while (@n1<100000)
	begin 
		--имя
		if (len(@first_name)>14) SET @first_name = 'Сеня' else SET @first_name += char(round(rand() * @w, 0) + @l);
		--возраст
		SET @age = FLOOR(RAND()*(87-18)+18);
		--фамилия
		if (len(@second_name)>15) SET @second_name = 'Никитин' else SET @second_name += char(round(rand() * @w, 0) + @l);

		if (len(@last_name)>15) SET @last_name = 'Горович' else SET @last_name += char(round(rand() * @w, 0) + @l);

		--гендер 
		if (len(@gender)>21) SET @gender = 'Муж' else SET @gender += char(round(rand() * @w, 0) + @l);
		insert into Client(first_name, second_name, last_name,  age, gender)
			values(@first_name,@second_name, @last_name, @age, @gender);
		set @n1 += 1
	end 




declare @n2 int = 0;
declare @date_not_separated datetime;
declare @year int;
declare @month int;
declare @day int;
declare @hour int;
declare @minute int;
declare @month_name nvarchar(50) = 'янв'
declare @day_name nvarchar(50) = 'ПН'

declare @a char = 'А', @z char = 'я', @w int, @l int;
		SET @w = ascii(@z) - ascii(@a);
		SET @l = ascii(@a);

while (@n2<100000)
	begin
		SET @date_not_separated = CAST(STR(Round(RAND()*31, 0))+'-'+LTRIM(STR(Round(RAND()*12, 0)))+'-'+LTRIM(STR(Round(RAND()*16, 0) + 2000)) AS SmallDateTime);
		SET @year = year(@date_not_separated)
		SET @month = month(@date_not_separated)
		SET @day = day(@date_not_separated)
		SET @hour = FLOOR(RAND()*(24-0)+0)
		SET @minute = FLOOR(RAND()*(59-0)+0)
		--возраст
		--фамилия
		if (len(@month_name)>21) SET @month_name = 'янв' else SET @month_name += char(round(rand() * @w, 0) + @l);
		if (len(@day_name)>30) SET @day_name = 'янв' else SET @day_name += char(round(rand() * @w, 0) + @l);
		insert into Date_partition([date_not_separated],[year],[month],[day],[hour],[minute],[month_name],[day_name])
			values(@date_not_separated, @year, @month, @day, @hour, @minute, @month_name, @day_name);
		set @n2 += 1
	end 

----- Индексы
SELECT * FROM Date_partition
SELECT * FROM Date_partition WHERE year = 2022

SELECT * FROM Geography
SELECT country, city, [index] FROM Geography WHERE country = 'Россия'

-- ?
DROP INDEX Geography.NonCL_Geography_Country
CREATE NONCLUSTERED INDEX NonCL_Geography_Country
	ON Geography (country)
	INCLUDE(city, [index])

SELECT * FROM Client
SELECT * FROM Client WHERE id = 13
drop index Client.NonCl_dPas_keyAlt
CREATE NONCLUSTERED INDEX NonCl_dPas_keyAlt
	ON Client (id)

SELECT * FROM Cheque
SELECT id FROM Cheque WHERE purchase_amount > 500 and geography_id > 5

CREATE INDEX NonCL_dimPlanes
	on Cheque (purchase_amount, geography_id)
	INCLUDE (id)
	WHERE purchase_amount > 450 and geography_id > 3

SELECT * FROM Cheque ORDER BY purchase_amount
SELECT * FROM Cheque WHERE date_id > 20210000000000 AND purchase_amount < 2000

CREATE NONCLUSTERED COLUMNSTORE INDEX NonCl_Columnstore_FastFl
ON Client (id, first_name, second_name, age, gender)

SELECT *
FROM Client


---- Секционирование

CREATE PARTITION FUNCTION Part_func_days(bigint)
AS RANGE RIGHT FOR VALUES (20190101001500, 20200101001500, 20210101001500, 
							20220101001500, 20230101001500, 20240101001500)

CREATE PARTITION SCHEME SEPARATED_DAYS
AS PARTITION Part_func_days TO
(Fast_Growing, Fast_Growing, Frequently_Requested, 
 Frequently_Requested, 
 Frequently_Requested, Frequently_Requested, Frequently_Requested)

SELECT
prt.partition_number
,prt.rows
,prv.value low_boundary
,flg.name name_filegroup
FROM sys.partitions prt
JOIN sys.indexes idx ON prt.object_id = idx.object_id
JOIN sys.data_spaces dts ON dts.data_space_id = idx.data_space_id
LEFT JOIN sys.partition_schemes prs ON prs.data_space_id = dts.data_space_id
LEFT JOIN sys.partition_range_values prv ON prv.function_id = prs.function_id AND prv.boundary_id = prt.partition_number - 1
LEFT JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = prs.data_space_id AND dds.destination_id = prt.partition_number
LEFT JOIN sys.filegroups flg ON flg.data_space_id = dds.data_space_id
WHERE prt.object_id = (SELECT object_id FROM Sys.Tables WHERE name = 'CLient')

SELECT * FROM SYS.Partitions
WHERE OBJECT_ID = (SELECT OBJECT_ID FROM Sys.Tables WHERE name = 'Date_partition')


----- Метод скользящего окна

CREATE PARTITION FUNCTION PartFunctionForDt (bigint)
AS RANGE RIGHT FOR VALUES (201612140209)

CREATE PARTITION SCHEME PartFunctionForDt
AS PARTITION PartFunctionForDt TO
([date_not_separated],
[date_not_separated])


SELECT
prt.partition_number
,prt.rows
,prv.value low_boundary
,flg.name name_filegroup
FROM sys.partitions prt
JOIN sys.indexes idx ON prt.object_id = idx.object_id
JOIN sys.data_spaces dts ON dts.data_space_id = idx.data_space_id
LEFT JOIN sys.partition_schemes prs ON prs.data_space_id = dts.data_space_id
LEFT JOIN sys.partition_range_values prv ON prv.function_id = prs.function_id AND prv.boundary_id = prt.partition_number - 1
LEFT JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = prs.data_space_id AND dds.destination_id = prt.partition_number
LEFT JOIN sys.filegroups flg ON flg.data_space_id = dds.data_space_id
WHERE prt.object_id = (SELECT object_id FROM Sys.Tables WHERE name = 'Geography')

SET XACT_ABORT ON
ALTER PROCEDURE Pr_SlidingWindow
AS
DECLARE @DayForMax VARCHAR(16)
DECLARE @DayForMax VARCHAR(16)
DECLARE @DayForMin VARCHAR(16)
DECLARE @DayForMin VARCHAR(16)

SET @DayForMaxPartCl = CAST((SELECT TOP 1 [value] FROM
sys.partition_range_values
 WHERE function_id = (SELECT function_id 
 FROM sys.partition_functions
 WHERE name = 'PartFunctionForDt')
 ORDER BY boundary_id DESC) AS VARCHAR(16))
SET @DayForMax = CAST((SELECT TOP 1 [value] FROM
sys.partition_range_values
 WHERE function_id = (SELECT function_id 
 FROM sys.partition_functions
 WHERE name = 'PartFunctionForDt')
 ORDER BY boundary_id DESC) AS VARCHAR(16))

DECLARE @Day_DT DATETIME
SET @Day_DT = DATEADD(YEAR, 1, (SELECT date_not_separated FROM Date_partition
							   WHERE date_not_separated = CONVERT(bigint, @DayForMax)))
DECLARE @DayOrder DATETIME
SET @DayOrder = DATEADD(YEAR, 1, (SELECT date_not_separated FROM Date_partition
							    WHERE date_not_separated = CONVERT(bigint, @DayForMax)))

ALTER PARTITION SCHEME PartSchCl_Date
NEXT USED [Frequently_Requested];
ALTER PARTITION SCHEME PartSchForCl
NEXT USED [Frequently_Requested]

DECLARE @Day_DT_BI bigint
SET @Day_DT_BI = ( SELECT DATEPART(second, @Day_DT) +
							DATEPART(minute, @Day_DT) * 100 +
							DATEPART(hour, @Day_DT) * 10000 +
							DATEPART(day, @Day_DT) * 1000000 +
							DATEPART(month, @Day_DT) * 100000000 +
							DATEPART(year, @Day_DT) * 10000000000 )
DECLARE @DayArchival_DT_BI bigint
SET @Day_DT_BI = ( SELECT DATEPART(second, @Day_DT) +
							DATEPART(minute, @Day_DT) * 100 +
							DATEPART(hour, @Day_DT) * 10000 +
							DATEPART(day, @Day_DT) * 1000000 +
							DATEPART(month, @Day_DT) * 100000000 +
							DATEPART(year, @Day_DT) * 10000000000 )


ALTER PARTITION FUNCTION PartFunctionFactFlights_Date()
SPLIT RANGE (@Day_DT_BI)
ALTER PARTITION FUNCTION PartFunctionForArchivalTable()
SPLIT RANGE (@DayArchival_DT_BI)

ALTER TABLE FactFlights
SWITCH PARTITION 2
TO ArchivalFactFlights PARTITION 2

SET @DayForMin = CAST((SELECT TOP 1 [value] FROM
sys.partition_range_values
 WHERE function_id = (SELECT function_id 
 FROM sys.partition_functions
 WHERE name = 'PartFunctionForDt')
 ORDER BY boundary_id) AS VARCHAR(16))
SET @DayForMin = CAST((SELECT TOP 1 [value] FROM
sys.partition_range_values
 WHERE function_id = (SELECT function_id 
 FROM sys.partition_functions
 WHERE name = 'PartFunctionForDt')
 ORDER BY boundary_id) AS VARCHAR(16))

ALTER PARTITION FUNCTION PartFunctionFactFlights_Date()
MERGE RANGE (CAST(@DayForMin AS BIGINT));
ALTER PARTITION FUNCTION PartFunctionDt()
MERGE RANGE (CAST(@DayForMin AS BIGINT));

EXEC Pr_SlidingWindow


SELECT * INTO #Time FROM Date_partition
SELECT * INTO #Date_partition1 FROM #Time
SELECT * FROM #Time
DROP TABLE #Date_partition1
SELECT * FROM FactFlights


*/