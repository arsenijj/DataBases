use autorepair;

create table spareParts1 (
	id int, 
	partname nvarchar(50),
	price money,
	number int,
	[availability] nvarchar(50)
)
insert into spareparts1 values(1,N'Генератор', 50, 20,''),(2,N'Шрус', 150, 20,''),(3,N'Кольца 82мм', 20, 20,''),(4,N'Поршня 80мм', 40, 20,''),(5,N'ГРМ', 80, 20,'')

select * from cheque

select * from servicesInCheque

--------after insert--------
create trigger trigger_after_insert on servicesInCheque 
after insert 
	as 
		declare @id int
		declare @price money 
		begin 
			select @id = servicesID from inserted
			select @price = price from allservices where @id = id 
			update cheque
			set purchase_amount = @price + purchase_amount
		end

drop trigger trigger_after_insert

insert into servicesInCheque([servicesID],[chequeID]) 
values (1,2),(2,2)

--------after delete--------
create trigger trigger_after_delete on marks
after delete 
	as
		declare @id int
		begin 
			select @id = id from deleted
			delete from automobile where id = @id
		end

delete 
	from marks
		where id = 1

select * from marks
select * from automobile
 
drop trigger trigger_after_delete
--------after update--------
create trigger trigger_after_update on spareParts1
after update
	as
		declare @an int
		begin
			select @an = number from deleted
			update spareParts1 
			set [availability] = 'товара нет в наличии' 
				where number = 0
		end

update spareParts1 set number = 0 where id = 1

select * from spareParts1

drop trigger trigger_after_update

--------instead of insert--------
create trigger trigger_instead_of_insert on spareparts1
instead of insert 
	as
		begin
			declare @col int
			select @col = number from inserted
			if (exists (select * from spareparts1 where number = @col))
			begin
				if (@col = '0')
				begin
					raiserror('Запчасть отсутствует на складе', 4, 2)
					return
				end
			end
		end


insert into spareParts1 values (1,N'Генератор', 50, 0,'')

insert into spareParts1 values (5,N'ГРМ', 80, 20,'')

select * from spareParts1                                                                                                                                                                                                                                    

drop trigger trigger_instead_of_insert

--------instead of с delete--------
use simpledb1

create view client_automobile 
	as
		select am.vin,
			   am.registrationNumber,
			   client.id 
		from automobile as am
		inner join client 
		on clientID = id 

select * from client_automobile

drop view client_automobile

create trigger trigger_instead_of_delete on client_automobile
instead of delete 
	as
		begin
			declare @id_cl int, @id_regnum nvarchar(10), @id_vin nvarchar(17)
			select @id_vin = vin from deleted
			select @id_regnum = registrationNumber from deleted
			select @id_cl = id from deleted

			if (@id_cl is null) or (@id_regnum is null)
			begin
				raiserror('Такого клиента не существует', 4, 6)
				return
			end
			delete from automobile where clientID = @id_cl and vin = @id_vin and registrationNumber = @id_regnum
			delete from client where id = @id_cl
		end

delete from client_automobile where id = 0 --не существует
delete from client_automobile where id = 247

drop trigger trigger_instead_of_delete

select * from client where id = 0

--------триггер instead of с update для каскадного изменения данных--------

USE autorepair;  
GO  
ALTER TABLE dbo.employees  
DROP CONSTRAINT FK__employees__shopI__4222D4EF;   
GO  

ALTER TABLE dbo.branchOffice ADD colEmpl int NULL

ALTER TABLE [employees] ADD FOREIGN KEY ([shopID]) REFERENCES [branchOffice] ([id])

create view empl_branchoffice 
	as
		select e.shopID as officeID,
			   e.id as ID,
			   b.colEmpl,
			   e.firstName, e.secondName 
		from branchOffice as b
		inner join employees as e 
		on b.id = e.shopID

select * from empl_branchoffice

drop view empl_branchoffice 

create trigger transition
	on empl_branchoffice 
	instead of update
	as
		begin
			declare @q int = (select officeID from deleted);
			declare @q1 int = (select ID from inserted);
			update employees set shopID = 3 where @q = ID;
			update branchOffice set colEmpl = colEmpl - 1 where id = 2;
			update branchOffice set colEmpl = colEmpl + 1 where id = 3;
		end

drop trigger transition
update empl_branchoffice set shopID = 3 where id = 2

select * from empl_branchoffice 
select * from branchOffice

drop trigger Translation