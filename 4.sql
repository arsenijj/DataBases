create database simpledb1 
go 

use simpledb1 

create table automobile(
	autoID uniqueidentifier ,
	numberAutomobile int,
	mileage bigint ,
	mark nvarchar(50) , 
	model nvarchar(50) ,
	vin nvarchar(17) ,
	registrationNumber nvarchar(10) ,
	yearOfManufacture smallint ,
	color nvarchar(25), 
	clientID bigint,
	carEngineType nvarchar(255),
)

declare @n int = 0;

declare @autoID uniqueidentifier;

declare @id_customer nvarchar(12);

declare @mileage bigint; 


declare @mark nvarchar(25) = '���';

declare @model nvarchar(25) = '2114';

declare @year int;

declare @idclient int = 1234;

declare @allowedCharsForVIN nvarchar(36) = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'; 
declare @lenforvin int = len(@allowedCharsForVIN);
declare @allowedCharsForColor nvarchar(16) = '0123456789ABCDEF'; 
declare @allowedCharsForAN nvarchar(12) = N'������������';
declare @lenforcolor tinyint = len(@allowedCharsForColor);

declare @color nvarchar(7) = '#';
declare @vin nvarchar(17)
declare @loopcount int = 0;

declare @carnum nvarchar(9);
declare @randnum tinyint;

declare @carEngineType nvarchar(20);

declare @a char = '�', @z char = '�', @w int, @l int;
		SET @w = ascii(@z) - ascii(@a);
		SET @l = ascii(@a);

truncate table automobile 
while (@n<100000)
	begin 

		--ID ���������� 
		SET @autoID = NEWID();


		--������ 
		SET @mileage = rand()*(500000-5)+5;
	
		--����� 
		if (len(@mark)>21) SET @mark = '���' else SET @mark += char(round(rand() * @w, 0) + @l);

		--������
		if (len(@model)>17) SET @model = '2114' else SET @model += char(round(rand() * @w, 0) + @l);


		--VIN
		set @vin  = '';
		set @loopcount = 0;

		while (@loopcount < 17)
			BEGIN 
				select @vin += substring(@allowedCharsForVIN, convert(int, rand() * @lenforvin),1);
				select @loopcount += 1;
			END

		--��������������� ����� ����������
		declare @an1 char = substring (@allowedCharsForAN, cast((rand()*(12-1)+1) as int), 1);
		declare @an2 int = rand()*(9-0)+0;
		declare @an3 int = rand()*(9-0)+0;
		declare @an4 int = rand()*(9-0)+0;
		declare @an5 char = substring (@allowedCharsForAN, cast((rand()*(12-1)+1) as int), 1);
		declare @an6 char = substring (@allowedCharsForAN, cast((rand()*(12-1)+1) as int), 1);
		declare @an7 int = rand()*(89-1)+1;

		SET @carnum = CONCAT( @an1, CAST (@an2 AS VARCHAR(1)), CAST (@an3 AS VARCHAR(1)), CAST (@an4 AS VARCHAR(1)), @an5, @an6, CAST (@an7 AS VARCHAR(2)) );

		--��� ������� ���������� 
		set @year = rand()*(2020-1900) + 1900;

		--���� ���������� 
		set @color = '#';
		set @loopcount = 0;

		while (@loopcount < 6) 
			begin 
				set @color += substring(@allowedCharsForColor, convert(int, rand() * @lenforcolor),1);
				set @loopcount += 1;
			end

		--ID �������
		set @idclient = rand()*(10000-@n)+@n;

		--��� ������������� �������
		set @randnum = rand()*(40-1)+1;
		if (@randnum >= 0 and @randnum < 10) set @carEngineType = '���';
			else if (@randnum >= 10  and @randnum < 20) set @carEngineType = '������';
				else if (@randnum >= 20  and @randnum < 30) set @carEngineType = '�������������';
					else if (@randnum >= 30  and @randnum < 40) set @carEngineType = '������';

	
		insert into automobile(autoID,mileage,mark,model,vin,registrationNumber,yearOfManufacture,clientID,carEngineType,numberAutomobile,color) 
			values(@autoID,@mileage,@mark,@model,@vin,@carnum,@year,@idclient,@carEngineType,@n,@color);
		
		set @n += 1
	end 

	--���������� ������ 
	create clustered index cl_automobile on automobile(numberAutomobile)
	
	select * from automobile where numberAutomobile < 1000 and 
								   numberAutomobile > 900

	drop index cl_automobile on automobile
	
	--������������ ��������� ������ 	
	create index com_automobile on automobile(vin,registrationNumber)
	
	select vin,registrationNumber from automobile 
	where vin like 'G%' and  registrationNumber like '%64'
										 
	drop index com_automobile on automobile

	--������������ ���������� ������ 
	create unique index ui_automobile on automobile(numberAutomobile,carEngineType)

	select numberAutomobile,carEngineType from automobile 
	where carEngineType = '�������������' and numberAutomobile < 20 
	
	drop index ui_automobile on automobile

	--������������ ����������� ������ 
	create index covering_automobile on automobile (model)
				include(registrationnumber,yearofmanufacture) 
	
	select registrationNumber, model, yearofManufacture from automobile 
	where model like '2114' and yearOfManufacture = 1999 

	drop index covering_automobile on automobile

	--������������ ��������������� ������ 
	create index filtered_automobile on automobile(yearOfManufacture,mileage,registrationNumber) 
	where yearOfManufacture > 1990 and mileage < 100000 
	
	select yearOfManufacture,mileage,registrationNumber from automobile 
	where yearOfManufacture > 1990  and mileage < 100000
	
	drop index filtered_automobile on automobile 
	
	--������������ ������ � ����������� ��������� 
	create index incl_col_automobile on automobile(vin)
	include(registrationNumber, color, clientID)
	
	select registrationNumber, color, clientID, vin from automobile where vin like 'X%6%' and clientID < 1000 
	
	drop index incl_col_automobile on automobile