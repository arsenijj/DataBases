use Autorepair2
CREATE TABLE [branchOffice] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [adress] nvarchar(255) not null,
  [openingTime] time not null,
  [closingTime] time not null
)
GO

CREATE TABLE [positions] (
  [id] int  IDENTITY(1,1) PRIMARY KEY,
  [name] nvarchar(255) not null,
  [salary] money not null
)
GO

CREATE TABLE [employees] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [firstName] nvarchar(255),
  [secondName] nvarchar(255) not null,
  [patronymic] nvarchar(255),
  [employmentDate] date not null,
  [shopID] int not null,
  [positionID] int not null
)
GO

CREATE TABLE [allservices] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [serviceName] nvarchar(255) not null,
  [price] money not null,
)
GO

CREATE TABLE [equipment] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [name] nvarchar(255) not null
)
GO

CREATE TABLE [spareParts] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [partname] nvarchar(255) not null,
  [price] money not null,
  [number] int
)
GO

CREATE TABLE [client] (
  [id] int IDENTITY(1,1)  PRIMARY KEY,
  [firstName] nvarchar(255),
  [secondName] nvarchar(255) not null,
  [patronymic] nvarchar(255),
  [age] int not null,
  [gender] nvarchar(255)
)
GO

CREATE TABLE [automobile] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [mileage] int not null,
  [markID] int not null,
  [modelID] int not null,
  [yearOfManufacture] int not null,
  [vin] nvarchar(255) not null
)
GO

CREATE TABLE [marks] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [name] nvarchar(255) not null
)
GO

CREATE TABLE [models] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [name] nvarchar(255) not null,
  [yearOfManufacture] int not null
)
GO

CREATE TABLE [cheque] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [data] date not null,
  [clientID] int not null,
  [automobileID] int not null,
  [purchase_amount] money 
)
GO

CREATE TABLE [servicesInCheque] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [servicesID] int not null,
  [chequeID] int not null
)
GO

CREATE TABLE [serviceEquipment] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [serviceID] int not null,
  [equipmentID] int not null
)
GO

CREATE TABLE [serviceSparePart] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [serviceID] int not null,
  [sparepartID] int not null
)
GO

CREATE TABLE [employeeServices] (
  [id] int IDENTITY(1,1) PRIMARY KEY,
  [employeeID] int not null,
  [serviceID] int not null
)
GO

ALTER TABLE [employees] ADD FOREIGN KEY ([positionID]) REFERENCES [positions] ([id])
GO

ALTER TABLE [automobile] ADD FOREIGN KEY ([markID]) REFERENCES [marks] ([id])
GO

ALTER TABLE [automobile] ADD FOREIGN KEY ([modelID]) REFERENCES [models] ([id])
GO

ALTER TABLE [employees] ADD FOREIGN KEY ([shopID]) REFERENCES [branchOffice] ([id])
GO

ALTER TABLE [servicesInCheque] ADD FOREIGN KEY ([servicesID]) REFERENCES [allservices] ([id])
GO

ALTER TABLE [servicesInCheque] ADD FOREIGN KEY ([chequeID]) REFERENCES [cheque] ([id])
GO

ALTER TABLE [serviceEquipment] ADD FOREIGN KEY ([serviceID]) REFERENCES [allservices] ([id])
GO

ALTER TABLE [serviceEquipment] ADD FOREIGN KEY ([equipmentID]) REFERENCES [equipment] ([id])
GO

ALTER TABLE [serviceSparePart] ADD FOREIGN KEY ([serviceID]) REFERENCES [allservices] ([id])
GO

ALTER TABLE [serviceSparePart] ADD FOREIGN KEY ([sparepartID]) REFERENCES [spareParts] ([id])
GO

ALTER TABLE [cheque] ADD FOREIGN KEY ([clientID]) REFERENCES [client] ([id])
GO

ALTER TABLE [employeeServices] ADD FOREIGN KEY ([employeeID]) REFERENCES [employees] ([id])
GO

ALTER TABLE [employeeServices] ADD FOREIGN KEY ([serviceID]) REFERENCES [allservices] ([id])
GO

ALTER TABLE [cheque] ADD FOREIGN KEY ([automobileID]) REFERENCES [automobile] ([id])
GO

insert into branchOffice (adress,openingTime,closingTime)
values(N'г. Доброволец, ул. Аргуновская, дом 144','8:00:00','20:00:00'),
	  (N'г. Сонково, ул. Еленинский пер, дом 17','8:00:00','22:00:00'),
      (N'г. Лебяжье, ул. Мамоновский пер, дом 186','10:00:00','23:00:00')



insert into positions(name,salary)
values	(N'Сервисный инженер',$800),
		(N'Автодиагност',$900),
		(N'Механик автосервиса',$700),
		(N'Автожестянщик',$800),
		(N'Мойщик авто',$450),
		(N'Автомаляр',$750),
		(N'Автомеханик',$850),
		(N'Автослесарь',$850),
		(N'Автоэлектрик',$900),
		(N'Арматурщик',$650),
		(N'Жестянщик',$700),
		(N'Шиномонтажник',$600),
		(N'Мастер приемщик',$650),
		(N'Управляющий автосервиса',$990)

insert into spareParts(partname,price,number)
values	(N'Блок управления ABS',$140,10),
		(N'Генератор', $80,5),
		(N'Тормозной суппорт', $60,20),
		(N'Тормозные диски', $50,14),
		(N'Датчик распредвала',$80,4),
		(N'Поперечный рычаг', $30,12),
		(N'Сальники коленвала',$45,4),
		(N'Карданный вал', $300,3),
		(N'Прокладка выпускного коллектора', $10,32),
		(N'Бензонасос', $35,10),
		(N'Прокладки головки блока', $35,12),
		(N'Патрубки', $45,30),
		(N'Поршневые кольца', $45,20),
		(N'Воздушный радиатор', $100,8)

insert into employees(firstName,secondName,patronymic,employmentDate,shopID,positionID)
values	(N'Чаурина', N'Берта', N'Владиславовна','20211017',3,14),   
		(N'Князев', N'Осип', N'Федорович','20190526',1,7),
		(N'Бартель', N'Любомира', N'Закировна','20210811',2,2), 
		(N'Медведева', N'Тереза', N'Филипповна','20200720',2,14), 
		(N'Гоголь', N'Леонтий', N'Юрьевич','20170721',3,7), 
		(N'Звездный' ,N'Феофан', N'Максимович','20180209',1,14), 
		(N'Федорчук', N'Бронислава', N'Дмитриевна','20170413',3,2), 
		(N'Пресняков', N'Данила', N'Денисович','20171231',2,7), 
		(N'Любимов', N'Федор', N'Артемович','20160914',1,2), 
		(N'Воронец', N'Оксана', N'Закировна','20210109',3,12)

insert into allservices(serviceName,price)
values	(N'Замена воздушного фильтра', $50),
		(N'Мойка автомобиля',$50),
		(N'Покраска детали',$100),
		(N'Шиномонтаж', $30),
		(N'Выправление вмятины без покраски',$85),
		(N'Замена генератора', $80),
		(N'Замена поршневых колец', $250),
		(N'Расточка ГБЦ',$150)

insert into serviceSparePart(serviceID,sparepartID)
values	(4,3),
		(6,2),
		(7,13),
		(5,6),
		(4,4)

insert into employeeServices(employeeID,serviceID)
values	(6,3),
		(6,5),
		(5,6),
		(3,7),
		(8,4)

insert into equipment(name)
values	(N'Гаечный ключ на 16'),
		(N'Подъемник для малотонных авто'),
		(N'Дрель на аккумуляторе'),
		(N'Электрический компрессор'),
		(N'Болторез')

insert into serviceEquipment(serviceID,equipmentID)
values	(4,2),
		(5,4),
		(5,2),
		(1,3),
		(1,3),
		(5,3),
		(5,2),
		(1,1),
		(3,2)



insert into marks(name)
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
		(N'Maybach')

insert into marks(name) values('Cadillac')

insert into models(name,yearOfManufacture) 
values	('Priora',2018),
		('Model 3',2003),
		('Model S',2010),
		('Granta',2009),
		('2109',2018),
		('RussianBeer',2014),
		('Vesta',2020),
		('Abobus',2021),
		('Hehe',2018),
		('2114',2009)

insert into automobile(mileage,markID,modelID,yearOfManufacture,vin)

values	(17830,1,4,2010, '1D4HR38NX3F552491'),
		(157977,4,6,2014, '1GCEC19R4VE104912'),
		(184004,5,8,2021, '1GKKVRED7CJ225979'),
		(152881,7,4,2010, '1LNFM82WXXY665820'),
		(66115,5,5, 2020, '1J8FF47W08D704142'),
		(237610,3,5,2019, '2G1FB1E35E9193751'),
		(90358,4,6,2016, '1HGCR2F59EA240846')

insert into client(firstName,secondName,patronymic,age,gender)
values	(N'Воронец', N'Амадей', N'Федорович',43,N'мужчина'),
		(N'Дарьянов', N'Ульян', N'Юрьевич',24,N'боевой вертолет'),
		(N'Белова', N'Елена', N'Федоровна',56,N'мужчина'),
		(N'Лапина', N'Наталия', N'Сергеевна',32,N'бигендер'),
		(N'Добронравов', N'Лонгин', N'Петрович',19,N'транссексуал'),
		(N'Милованов', N'Лазарь', N'Тарасович',27,N'демигендер'),
		(N'Ивлев', N'Викентий', N'Сергеевич',65,N'пагнендер'),
		(N'Толмачева', N'Джульетта', N'Закировна',25,N'андрогин')

insert into cheque(data, clientID,automobileID)
values	(GETDATE(),1,4),
		(GETDATE(),2,4),
		(GETDATE(),3,1),
		(GETDATE(),5,6),
		(GETDATE(),7,7),
		(GETDATE(),3,5),
		(GETDATE(),1,3)

insert into servicesInCheque(servicesID,chequeID)
values	(5,1),
		(4,1),
		(3,1),
		(1,2),
		(2,2),
		(4,2),
		(5,3),
		(1,1),
		(4,3),
		(2,4)


CREATE VIEW Client_Car AS
SELECT client.firstName, client.secondName, client.age, marks.name as 'Mark', models.name as 'Model', automobile.yearOfManufacture, automobile.mileage, automobile.vin
FROM cheque
	inner join automobile
	on cheque.automobileID = automobile.id
		inner join client
		on cheque.clientID = client.id
			inner join marks
			on automobile.markID = marks.id
				inner join models
				on automobile.modelID = models.id;


create view Office_Employee as 
select branchOffice.id as 'OfficeId', branchOffice.adress, employees.id as 'EmployeeId', employees.firstName, employees.secondName, employees.employmentDate, positions.name as 'Position', positions.salary
from employees
	inner join branchOffice
	on employees.shopID = branchOffice.id
		inner join positions
		on employees.positionID = positions.id

create view Employee_Service as
select employees.id as 'EmployeeId', employees.firstName, employees.secondName, allservices.serviceName, allservices.price
from employees
	inner join employeeServices
	on employees.id = employeeServices.employeeID
		inner join allservices
		on employeeServices.serviceID = allservices.id


create view Service_SparePart as
select allservices.id as 'ServiceId', allservices.serviceName, allservices.price as 'ServicePrice', spareParts.id as 'PartId', spareParts.partname, spareParts.number, spareParts.price as 'PartPrice'
from allservices
	inner join serviceSparePart
	on allservices.id = serviceSparePart.serviceID
		inner join spareParts
		on serviceSparePart.sparepartID = spareParts.id
