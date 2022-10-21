/*
Angel Daniel Guzmán Gómez - 1093756 - SQL Parte 2

ADVERTENCIA: En la linea 115, el programa detecta un error porque utilizo un "CTR With". 
Si ejecuta el script completo, dará error en esta linea. Para revisar ese ejercicio en concreto,
Tendrá que seleccionar solo esa consulta.

Utilizando la DB TSQL2012:
1- Realizar una consulta mostrando los productos y su respectiva categoría (categoryName)
*/

use TSQL2012;

select P.productname, C.categoryname
from Production.Products P 
inner Join Production.Categories C on P.categoryid = C.categoryid

/*
2- mostrar el top de los 15 últimos productos creados mostrando el orderDate, requireddate y shippeddate 
utilizando un formato de fecha distinto para cada uno.
*/

select top 15 P.productname,
convert(varchar, orderdate, 3) [orderdate], 
convert(varchar, requireddate, 6) [requireddate],
convert(varchar, shippeddate, 101) [shippeddate]
from sales.Orders O join sales.OrderDetails D on O.orderid = D.orderid
inner join Production.Products P on P.productid = D.productid
order by O.orderdate desc

/*
3- tomando en cuenta que tenemos la tabla sales.orders y sales.orderdetails usted debe hacer lo necesario para poder 
mostrar el total de las ventas realizadas, agrupándolas de la siguiente forma:
*/

select datepart(year,orderdate) [añoOrden], datepart(month,orderdate) [mesOrden], 
sum(unitprice*qty - (unitprice*qty*discount)) [Total]
from sales.OrderDetails D join sales.Orders O on D.orderid = O.orderid
group by datepart(year,orderdate), datepart(month,orderdate)
order by datepart(year,orderdate)

/*
4- Dado los siguientes querys usted debe ejecutar cada uno si existe alguna diferencia entre los resultados debe 
explicarla:
*/

--1
select Emp.empid,
Emp.firstname+' '+Emp.lastname as Empleado,
cust.contactname,
o.orderid,
O.orderdate
from hr.Employees Emp inner join sales.Orders O
on emp.empid = o.empid
left join sales.Customers Cust
on Cust.custid = o.custid
order by empid desc

--2
select Emp.empid,
Emp.firstname+' '+Emp.lastname as Empleado,
cust.contactname,
o.orderid,
O.orderdate
from hr.Employees Emp inner join sales.Orders O
on emp.empid = o.empid
right join sales.Customers Cust
on o.custid = Cust.custid
order by empid asc

/*
RESPUESTA:

La diferencia entre el primer query y el segundo es que en el primero se realiza un left join entre el join de hr.Employees 
y sales.Orders. Esto hace que se encuentren todos los registros de la tabla de la izquierda que tengan el mismo custid de la
tabla de la derecha, con prioridad en la tabla de la izquierda, mientras que el segundo query lo realiza con prioridad en la
tabla de la derecha. El caso es que el primer query devuelve 830 registros, mientras que el segundo devuelve 832, ya que 
existen 2 contactname que no contienen ningun empid.

*/

/*
5- Dada la tabla stats.score realizar lo siguiente:
a-Mostrar cada examen. 
b-Mostrar la cantidad de estudiantes que hay por cada examen. 
c-Mostrar la cantidad de estudiantes que aprobaron el examen. Logica:(si el score es mayor o igual a 70 )
*/

select testid, count(studentid) [CantidadEstudiantes], sum(case when (score >= 70) then convert(int,'1')
else convert(int,'0') end) [EstudiantesAprobados]
from stats.Scores
group by testid

/*
6- Mostrar la cantidad de meses que han pasado de enero a la fecha
*/

select DATEDIFF(month,CAST('2021-01-01' AS datetime),getdate()) [MesesPasados]

/*
7- Mostrar en un resultado los campos empid, FullName empleado (HR.EMPLOYEES) mostrando la primera y ultima
orden este empleado creo. Los empleados no deben salir duplicados.
*/

select empid, concat(firstname,' ',lastname) [FullName],
PrimeraOrder = (select top 1 orderid from sales.Orders O where O.empid = E.empid order by orderdate asc),
UltimaOrder = (select top 1 orderid from sales.Orders O where O.empid = E.empid order by orderdate desc)
from hr.Employees E

/*
8- Mostrar en un resultado los campos empid, FullName empleado (HR.EMPLOYEES) mostrando el producto con el 
precio mínimo y el producto con el precio máximo para la primera orden el empleado creo.
*/

with tabl as(
select empid, concat(firstname,' ',lastname) [FullName],
PrimeraOrder = (select top 1 orderid from sales.Orders O where O.empid = E.empid order by orderdate asc)
from hr.Employees E)
select empid, FullName,
PrecioMinimo = (select min(unitprice) from sales.OrderDetails where orderid = PrimeraOrder),
PrecioMaximo = (select max(unitprice) from sales.OrderDetails where orderid = PrimeraOrder)
from tabl order by empid

/*
9- Mostrar los suplidores (Production.suppliers) cuando el campo contacttitle Contenga la literal
'Manag'
*/

select * from Production.Suppliers 
where contacttitle like '%Manag%'

/*
10- tomando la tabla suppliers nos fijamos el companyName viene bajo el patron supplier Codigo, tomando esto en 
cuenta separar el companany name mostrando en una columna el Supplier y en otra el literal restante sin espacio.
*/

select left(companyname,8) [Supplier], right(companyname,5) [Supplier Codigo] 
from Production.Suppliers

/*
11- tomando la tabla products y Suppliers mostrar los campos supplierid, contactname, el producto con el precio mayor 
para cada suplidor, la cantidad de productos total de ese suplidor y la cantidad de productos que poseen orden creada.
*/

select supplierid, contactname,
CantidadTotalProductos = (select count(productname) from Production.Products P where P.supplierid = S.supplierid),
ProductoPrecioMayor = (select max(unitprice) from Production.Products P where P.supplierid = S.supplierid),
ProductosEnOrden = (select count(productname) from Production.Products P where P.supplierid = S.supplierid and 
(select count(productid) from sales.OrderDetails where productid = P.supplierid group by productid) != 0)
from Production.Suppliers S

/*
12- Mostrar una consulta la cantidad de empleados que hay por país usar tabla employees, 
country
*/

select Country,count(Country) [Cantidad]
from hr.Employees
group by Country

/*
13- Mostrar los países de las ordenes (tabla orders shipcountry) y la cantidad de clientes Que ha creado 
ordenes. usar shipcountry
*/

select shipcountry, count(distinct custid)  [CantidadClientes] 
from sales.orders
group by shipcountry

/*
14- la cantidad de órdenes por país. usar shipcountry 
*/

select shipcountry, count(distinct orderid) [CantidadOrdenes]
from sales.orders
group by shipcountry

/*
15- Mostrar los empleados id, nombre y la cantidad de órdenes que ha creado.
usar employees y orders.
*/

select E.empid, Concat(E.firstname,' ',E.lastname) [FullName], count(distinct O.orderid) [CantidadOrdenes]
from hr.Employees E join sales.Orders O on E.empid = O.empid
group by E.empid, E.firstname, E.lastname

/*
16- combinar el resultado del query 14 y 15: shipcountry, cantidad(clientes),
Cantidad(Ordenes)
*/

select shipcountry, count(distinct custid) [CantidadClientes], count(distinct orderid) [CantidadOrdenes]
from sales.orders
group by shipcountry

/*
17- Al query 5, anadirle el min(unitprice), max(unitprice),total
Nota: La imagen del ejercicio no presenta el total, pero lo coloqué por si acaso
*/

select shipcountry, count(distinct custid) [CantidadClientes], count(distinct O.orderid) [CantidadOrdenes],
min(unitprice) [PrecioMinimo],max(unitprice) [PrecioMaximo], sum(unitprice*qty - (unitprice*qty*discount)) [Total]
from sales.orders O join sales.OrderDetails D on O.orderid = D.orderid
group by shipcountry