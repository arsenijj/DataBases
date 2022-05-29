
--1.������ � �������������� ���������� �����������
SELECT firstName, secondName FROM employees
	WHERE positionID in (SELECT id FROM positions 
							WHERE salary > (SELECT AVG(salary) FROM positions))

declare @a as float
select @a = AVG(purchase_amount) from cheque

--2.�������� ������� � �������������� ��������������� ����������� � ����������� SELECT � WHERE
SELECT id, purchase_amount, (SELECT AVG(purchase_amount) FROM cheque where ch.purchase_amount > @a)
	FROM cheque as ch
		WHERE ch.automobileID in (SELECT ch.automobileID FROM automobile 
									WHERE yearOfManufacture = 
										(SELECT MIN(yearOfManufacture) FROM automobile))
									
--3.������ � �������������� ��������� ������
SELECT name, salary 
 INTO #currentPositions FROM positions

 SELECT * FROM #currentPositions

 --4.������ � �������������� ���������� ��������� ������
SELECT firstName, secondName, employmentDate, shopID, positionID
	INTO #Employees1
		FROM employees

drop table #Employees1
select * from #Employees1

INSERT INTO #Employees1 
	SELECT firstName, secondName, employmentDate, shopID, positionID FROM employees
			WHERE employees.firstName like N'���%' or employees.secondName like N'��%'

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

--5. ������� ������(INSERT, UPDATE) � ������� ����������� MERGE
INSERT INTO spareParts(partname, price, number)
	VALUES (N'������ �������� ����� ���� 2114 BOSCH', 1000, 10)

merge employees as e
	using (select positionId from employees) as source (emp)
	on (e.id = source.emp)
when not matched
	then insert(firstName, secondName, patronymic, employmentDate, shopID, positionID)
			values(N'����',N'����',N'����', getdate(), 1, 1);

select * from employees

--6. ������ � �������������� ��������� PIVOT
SELECT [avg_],
 [1],[2],[3],[4]
 FROM (SELECT 'average price' AS 'avg_', PositionId, (SELECT salary from positions where positionID = id) as price FROM employees) x
 PIVOT
 (AVG(price)
 FOR positionId
 IN([1],[2],[3],[4])
 ) pvt;

 --7. ������ � �������������� ��������� UNPIVOT
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

--8. ������� � �������������� GROUP_BY � ����������� ROLLUP, CUBE � GROUPING SETS
--	CUBE - ������������ �� ���� ��������� �������
select name, yearOfManufacture
	FROM models
	GROUP BY ROLLUP (yearOfManufacture, name)
	
select name, yearOfManufacture
	FROM models
	GROUP BY CUBE (yearOfManufacture, name)

select name, yearOfManufacture
	FROM models
	GROUP BY GROUPING SETS (yearOfManufacture, name)


--9. ��������������� � �������������� OFFSET FETCH
SELECT * FROM client
	ORDER BY age DESC
	OFFSET 2 ROWS
FETCH FIRST 5 ROWS ONLY

select * from client

--10. ������� � �������������� ����������� ������� �������. ROW_NUMBER() ��������� �����. 
--	  ������������ ��� ��������� ������ �����. RANK(), DENSE_RANK(), NTILE()
SELECT ROW_NUMBER() over (ORDER BY mileage DESC) as [�], RANK() over (ORDER BY mileage DESC ) as [RANK],
       DENSE_RANK() over (ORDER BY mileage DESC) as [DENS_RANK], NTILE(3) over (ORDER BY mileage DESC ) as [NTILE],
      yearOfManufacture, (SELECT name FROM marks where markID = id) as '�����', (SELECT name FROM models where modelID = id) as '������', vin
FROM automobile


--11. ��������������� ������ � TRY/CATCH
BEGIN TRY
    INSERT INTO spareParts1(partname, price, number, availability)
    VALUES (1,'abra-cadabra', 2, 'abra-abra');
END TRY
BEGIN CATCH
    Print 'Something went wrong'
END CATCH

--12. �������� ��������� ��������� ������ � ����� CATCH � �������������� ������� ERROR
BEGIN TRY
    INSERT INTO spareParts1(partname, price, number, availability)
    VALUES (1,'abra-cadabra', 2, 'abra-abra');
END TRY
BEGIN CATCH
    Print 'Something went wrong: ' + ERROR_MESSAGE()
END CATCH

--13. ������������� THROW, ����� �������� ��������� �� ������ �������
BEGIN TRY
    INSERT INTO spareParts1(partname, price, number, availability)
    VALUES (1,'abra-cadabra', 2, 'abra-abra');
END TRY
BEGIN CATCH
    THROW 51000,'Something went wrong', 1;
END CATCH

--14. �������� ���������� � BEGIN � COMMIT
SELECT * FROM employees

BEGIN TRAN
	DELETE FROM employees
		WHERE firstName like N'%���%'
COMMIT TRAN

--15. ������������� XACT_ABORT
SET XACT_ABORT ON;
BEGIN TRANSACTION
DELETE FROM employees
WHERE id=10;
INSERT INTO employees(firstName, secondName, patronymic, employmentDate, shopID, positionID)
VALUES (N'������',N'�����',N'���������',getdate(), 3, 12);
COMMIT TRANSACTION

SET XACT_ABORT OFF;

--16. ���������� ������ ��������� ���������� � ����� CATCH
BEGIN TRANSACTION
BEGIN TRY
	DELETE FROM employees
	WHERE id=10;
	INSERT INTO employees(firstName, secondName, patronymic, employmentDate, shopID, positionID)
	VALUES (N'������',N'�����',N'���������',getdate(), 3, 12);
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    print'Something going wrong'
    ROLLBACK TRANSACTION
END CATCH
