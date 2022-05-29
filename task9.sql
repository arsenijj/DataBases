
--1.Запрос с использованием автономных подзапросов
SELECT firstName, secondName FROM employees
	WHERE positionID in (SELECT id FROM positions 
							WHERE salary > (SELECT AVG(salary) FROM positions))

declare @a as float
select @a = AVG(purchase_amount) from cheque

--2.Создание запроса с использованием коррелированных подзапросов в предложении SELECT и WHERE
SELECT id, purchase_amount, (SELECT AVG(purchase_amount) FROM cheque where ch.purchase_amount > @a)
	FROM cheque as ch
		WHERE ch.automobileID in (SELECT ch.automobileID FROM automobile 
									WHERE yearOfManufacture = 
										(SELECT MIN(yearOfManufacture) FROM automobile))
									
--3.Запрос с использованием временных таблиц
SELECT name, salary 
 INTO #currentPositions FROM positions

 SELECT * FROM #currentPositions

 --4.Запрос с использованием обобщенных табличных данных
SELECT firstName, secondName, employmentDate, shopID, positionID
	INTO #Employees1
		FROM employees

drop table #Employees1
select * from #Employees1

INSERT INTO #Employees1 
	SELECT firstName, secondName, employmentDate, shopID, positionID FROM employees
			WHERE employees.firstName like N'Люб%' or employees.secondName like N'Фе%'

; WITH MyCTE
AS
(
SELECT ROW_NUMBER () OVER (
PARTITION BY firstName
ORDER BY firstName) AS Mark,
*
FROM #Employees1
)
DELETE FROM MyCTE WHERE Mark>1

--5. Слияние данных(INSERT, UPDATE) с помощью конструкции MERGE
INSERT INTO spareParts(partname, price, number)
	VALUES (N'Стекло передней левой фары 2114 BOSCH', 1000, 10)

merge employees as e
	using (select positionId from employees) as source (emp)
	on (e.id = source.emp)
when not matched
	then insert(firstName, secondName, patronymic, employmentDate, shopID, positionID)
			values(N'тест',N'тест',N'тест', getdate(), 1, 1);

select * from employees

--6. Запрос с использованием оператора PIVOT
SELECT [avg_],
 [1],[2],[3],[4]
 FROM (SELECT 'average price' AS 'avg_', PositionId, (SELECT salary from positions where positionID = id) as price FROM employees) x
 PIVOT
 (AVG(price)
 FOR positionId
 IN([1],[2],[3],[4])
 ) pvt;

 --7. Запрос с использованием оператора UNPIVOT
SELECT PositionId
,avg__ AS avg_
FROM(
SELECT [avg_], [1],[2],[3],[4]
FROM (SELECT 'average price' AS 'avg_', PositionId, (SELECT salary from positions where positionID = id) as sal
FROM Employees) x
 PIVOT (AVG(sal) FOR PositionId IN([1],[2],[3],[4]) )
pvt
) pvt
UNPIVOT (avg__
FOR PositionId IN([1],[2],[3],[4])
) unpvt;

--8. Запросы с использованием GROUP_BY с операторами ROLLUP, CUBE и GROUPING SETS
--	CUBE - просчитывает по всем возможным группам
select name, yearOfManufacture
	FROM models
	GROUP BY ROLLUP (yearOfManufacture, name)
	
select name, yearOfManufacture
	FROM models
	GROUP BY CUBE (yearOfManufacture, name)

select name, yearOfManufacture
	FROM models
	GROUP BY GROUPING SETS (yearOfManufacture, name)


--9. Секционирование с использованием OFFSET FETCH
SELECT * FROM client
	ORDER BY age DESC
	OFFSET 2 ROWS
FETCH FIRST 5 ROWS ONLY

select * from client

--10. Запросы с использованием ранжирующих оконных функций. ROW_NUMBER() нумерация строк. 
--	  Использовать для нумерации внутри групп. RANK(), DENSE_RANK(), NTILE()
SELECT ROW_NUMBER() over (ORDER BY mileage DESC) as [№], RANK() over (ORDER BY mileage DESC ) as [RANK],
       DENSE_RANK() over (ORDER BY mileage DESC) as [DENS_RANK], NTILE(3) over (ORDER BY mileage DESC ) as [NTILE],
      yearOfManufacture, (SELECT name FROM marks where markID = id) as 'Марка', (SELECT name FROM models where modelID = id) as 'Модель', vin
FROM automobile


--11. Перенаправление ошибки в TRY/CATCH
BEGIN TRY
    INSERT INTO spareParts1(partname, price, number, availability)
    VALUES (1,'abra-cadabra', 2, 'abra-abra');
END TRY
BEGIN CATCH
    Print 'Something went wrong'
END CATCH

--12. Создание процедуры обработки ошибок в блоке CATCH с использованием функций ERROR
BEGIN TRY
    INSERT INTO spareParts1(partname, price, number, availability)
    VALUES (1,'abra-cadabra', 2, 'abra-abra');
END TRY
BEGIN CATCH
    Print 'Something went wrong: ' + ERROR_MESSAGE()
END CATCH

--13. Использование THROW, чтобы передать сообщение об ошибке клиенту
BEGIN TRY
    INSERT INTO spareParts1(partname, price, number, availability)
    VALUES (1,'abra-cadabra', 2, 'abra-abra');
END TRY
BEGIN CATCH
    THROW 51000,'Something went wrong', 1;
END CATCH

--14. Контроль транзакций с BEGIN и COMMIT
SELECT * FROM employees

BEGIN TRAN
	DELETE FROM employees
		WHERE firstName like N'%ест%'
COMMIT TRAN

--15. Использование XACT_ABORT
SET XACT_ABORT ON;
BEGIN TRANSACTION
DELETE FROM employees
WHERE id=10;
INSERT INTO employees(firstName, secondName, patronymic, employmentDate, shopID, positionID)
VALUES (N'Крутой',N'Игорь',N'Яковлевич',getdate(), 3, 12);
COMMIT TRANSACTION

SET XACT_ABORT OFF;

--16. Добавление логики обработки транзакций в блоке CATCH
BEGIN TRANSACTION
BEGIN TRY
	DELETE FROM employees
	WHERE id=10;
	INSERT INTO employees(firstName, secondName, patronymic, employmentDate, shopID, positionID)
	VALUES (N'Крутой',N'Игорь',N'Яковлевич',getdate(), 3, 12);
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    print'Something going wrong'
    ROLLBACK TRANSACTION
END CATCH
