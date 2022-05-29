use autorepair

select * from servicesInCheque

create view emplSalary 
as 
select e.id, e.firstName, e.secondName, p.salary
	from employees as e
	inner join positions as p
		on positionID = p.id

drop view emplSalary
select * from emplSalary

--1 
create procedure newYearBonus @id int, @bonus money output 
	as 
		begin 
			declare @stavka money = (0.5 * (select salary from emplSalary where id = @id))
			select @bonus = @stavka * 1.25 + 2022
		end 

declare @m money 
exec newYearBonus 3, @m output
select @m as 'Новогодняя премия'

drop procedure newYearBonus
--2
create procedure ifLessThanMinSalary @id int
	as 
		begin 
			declare @sal money = (select salary from emplSalary where id = @id)
				if @sal < 500 
					return 0
				if @sal < 2000 
					return 1
				if @sal > 5000 
					return 2
		end

declare @res int 
declare @fn nvarchar(50) = (select firstName from emplSalary where id = 2)
declare @sn nvarchar(50) = (select secondName from emplSalary where id = 2)

exec @res = ifLessThanMinSalary 2

if (@res = 0) print ('Cотрудник ' + @fn + ' ' + @sn + ' нуждается в повышении зарплаты')
else if (@res = 1) print ('Cотрудник ' + @fn + ' ' + @sn + ' получает хорошую зарплату')
else print('Cотруднику ' + @fn + ' ' + @sn + ' живется просто прекрасно')

drop proc ifLessThanMinSalary

--3
create view serviceSpareParts 
	as 
		select s.id ,s.serviceName, p.partname, p.number
			from allservices as s
		inner join serviceSparePart as sP 
		on s.id = sP.serviceID
			inner join spareParts as p
			on sP.sparepartID = p.id

drop view serviceSpareParts

select * from serviceSpareParts

create procedure sparePartsCol @id int
as 
	begin 
		declare @col int
		declare @serviceName nvarchar(50)
		declare @partName nvarchar(50)
		declare cur cursor for
			select serviceName, partname, number
				from serviceSpareParts 
			where serviceSpareParts.id = @id 
			
		open cur
		fetch next from cur into @serviceName, @partName, @col
			while(@@FETCH_STATUS = 0)
				begin 
					if @col = 0 print('Деталь ' + @partName +' нуждается в поставке')
					else if @col = 1 print('Деталь ' + @partName + ' присутствует на складе в единичном экземпляре')
					else print('Деталь ' + @partName + ' присутствует на складе в достаточном количестве')
					fetch next from cur into @serviceName, @partName, @col
				end 
			close cur
	end
deallocate cur
drop proc sparePartsCol

exec sparePartsCol 4

--4 
create procedure paramMileage @mileage nvarchar(50)
as 
	begin 
		declare @markName nvarchar(50)
		declare @modelName nvarchar(50)
		declare @vin nvarchar(50)
		declare curs cursor for 
			select marks.name, models.name, a.vin 
				from automobile as a 
				inner join marks
					on a.markID = marks.id 
				inner join models 
					on a.modelID = models.id 
				where mileage > @mileage
		open curs 
		fetch next from curs into @markName, @modelName, @vin
		while(@@FETCH_STATUS = 0)
			begin 
				print('Машина ' + @markName + ' ' + @modelName + ' ' + @vin + ' имеет пробег больше, чем ' + @mileage + ' км.')
				fetch next from curs into @markName, @modelName, @vin
			end 
		close curs

	end
deallocate curs 
drop proc paramMileage
execute paramMileage 20000

--5
create procedure paramMark @mark nvarchar(50)
as 
	begin 
		declare @markName nvarchar(50)
		declare @modelName nvarchar(50)
		declare @vin nvarchar(50)
		declare curs1 cursor for 
			select marks.name, models.name, a.vin 
				from automobile as a 
				inner join marks
					on a.markID = marks.id 
				inner join models 
					on a.modelID = models.id 
				where marks.name = @mark
		open curs1
		fetch next from curs1 into @markName, @modelName, @vin
		while(@@FETCH_STATUS = 0)
			begin 
				print(@markName + ' ' + @modelName + ' ' + @vin)
				fetch next from curs1 into @markName, @modelName, @vin
			end 
		close curs1

	end

exec paramMark ВАЗ
deallocate curs1
drop proc paramMark


create proc clientAge @age int
as 
	begin 
	declare @fn nvarchar(50)
	declare @sn nvarchar(50)

	declare curs2 cursor for
	select client.firstName, client.secondName
		from client  inner join client t2
		ON client.age > @age
	open curs2 
	fetch next from curs2 into @fn, @sn
	while(@@FETCH_STATUS = 0)
			begin 
				print(@fn + ' ' + @sn)
				fetch next from curs2 into @fn, @sn
			end 
	end 
drop proc clientAge
exec clientAge 35