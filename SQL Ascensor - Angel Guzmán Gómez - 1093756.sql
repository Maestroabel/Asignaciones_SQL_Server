create table #line (
id int primary key,
name varchar(255),
weight int,
turn int unique,
check(weight > 0)
)

insert into #line values 
(5,'George Washington',250,1),
(4,'Thomas Jefferson',175,5),
(3,'John Adams',350,2),
(6,'Thomas Jefferson',400,3),
(1,'James Elephant',500,6),
(2,'Will Johnliams',200,4)

WITH T1
     AS (SELECT *,SUM(Weight) OVER (ORDER BY turn ROWS UNBOUNDED PRECEDING) AS cume_weight FROM  #line),
     T2
     AS (SELECT LEAD(cume_weight) OVER (ORDER BY turn) AS next_cume_weight,*FROM   T1)
SELECT TOP 1 name
FROM   T2
WHERE  next_cume_weight > 1000 OR next_cume_weight IS NULL
ORDER  BY turn