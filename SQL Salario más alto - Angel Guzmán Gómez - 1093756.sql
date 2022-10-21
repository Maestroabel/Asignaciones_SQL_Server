CREATE TABLE #EMP
( ID varchar(255), Name varchar(255), AnnualSalary varchar(255), ManagerId varchar(255)
);
INSERT INTO #EMP ( ID, Name, AnnualSalary, ManagerId ) VALUES (1,'Lisa Smith', 150000,
NULL), (2,'Dan Bradley', 110000, 1),
(3,'Oliver Queen', 180000, 1),
(4,'Dave Dakota', 100000, 1),
(5,'Steve Carr', 200000, NULL),
(6,'Alice Johnson', 205000, 5),
(7,'Damian Luther', 100000, 5),
(8,'Avery Montgomery', 210000, 5),
(9,'Mark Spencer', 140000, 5),
(10,'Melanie Thorthon', 200000, NULL),
(11,'Dana Parker', 100000, 10),
(12,'Antonio Maker', 120000, 10),
(13,'Lucille Alvarez', 140000, 10) ;

;WITH Temp AS
(
SELECT ID, Name, AnnualSalary,Isnull(ManagerId,ID) as ManagerId
FROM #EMP
)
SELECT *
FROM (select *, DENSE_RANK() OVER (PARTITION BY ManagerId ORDER BY AnnualSalary Desc) AS Rnk FROM Temp) T
where Rnk = 2

