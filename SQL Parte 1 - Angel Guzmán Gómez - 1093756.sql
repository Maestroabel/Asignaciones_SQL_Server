/*
Angel Daniel Guzmán Gómez - 1093756 - SQL Parte 1

Databases - TSQL2012 y Northwind

1- Mostrar todas las ordenes (sales.orders) presentando los campos: OrderId, OrderDate 
formato (dd/mm/yyyy), fecha requerida (dd/mm/yyyy), custId.
*/
use TSQL2012

select OrderID, FORMAT (OrderDate, 'dd/MM/yyyy') as OrderDate, FORMAT (requireddate, 'dd/MM/yyyy') as RequiredDate, CustID 
from Sales.Orders

/*
2- Mostrar todas las órdenes (sales.orders) presentando los campos OrderId, OrderDate 
formato (dd/mm/yyyy), fecha requerida (dd/mm/yyyy), custId, cuando (where) el país de la 
orden sea Germany.
*/

select OrderID, FORMAT (OrderDate, 'dd/MM/yyyy') as OrderDate, FORMAT (requireddate, 'dd/MM/yyyy') as RequiredDate, CustID, shipcountry
from Sales.Orders
Where shipcountry = 'Germany'

/*
3- Realizar una consulta mostrando las ordenes (sales.orders) cuando (where) el campo 
shipaddress contenga Sh.
*/

select * 
from Sales.Orders
where shipaddress like '%sh%'

/*
4- Realizar una consulta mostrando las ordenes (sales.orders) cuando el campo shipaddress 
inicie con la palabra Sh.
*/

select * 
from Sales.Orders
where shipaddress like 'sh %'

/*
5- Realizar una consulta mostrando las órdenes (sales.orders) cuando el freight sea mayor a 30 
y menor 40.
Operador (AND) para poder tener dos filtros en el where.
*/

select * 
from Sales.Orders
where freight > 30 and 
freight < 40

/*
6- Realizar una consulta mostrando la cantidad de órdenes (sales.orders) con freight mayor a 
40 y shipperId a 1 o 2 o 3
*/

select count(*)
from Sales.Orders
where freight > 40 and 
shipperId in (1,2,3)

/*
7- Realizar una consulta mostrando las órdenes (sales.orders) con freight Mayor a 30 y 
shipperid 1 y 2

7-1 Mostrar una consulta de órdenes (sales.orders) con freight menor a 20 y shipperid 
igual a 3.
(Nota: tienes punto adicional si puedes combinar en 1 solo query las consultas 7 y 7-1).

*/

SELECT * FROM Sales.Orders where (freight > 30 and (shipperId in (1,2)))
or (freight < 20 and shipperid = 3)
ORDER BY freight ASC;

/*
8- Realizar una consulta de las ordenes tabla Sales.Orders mostrando el OrderId,orderdate 
formato (mm/dd/yyyy), fecha actual formato (mm/dd/yyyy) y a su vez un campo donde se 
visualice la cantidad de días que paso desde el orderdate hasta la fecha de hoy, y un campo que 
muestre la cantidad de días que paso desde el orderDate hasta el shippedDate., Mostrar en un 
campo lo siguiente: si el shippedDate es mayor al requiredDate devolver ‘No puntual’ de lo 
contrario ‘Puntual’.
*/

select OrderID, format(Orderdate, 'MM/dd/yyyy') as orderdate, format(getdate(), 'MM/dd/yyyy') as Currentdate, 
DATEDIFF(Day,orderdate,getdate()) as Dias_Orderdate_Hoy, DATEDIFF(Day,orderdate,shippedDate) as Dias_Orderdate_shippedDate,
format(ShippedDate, 'MM/dd/yyyy') as ShippedDate, format(requireddate, 'MM/dd/yyyy') as requiredDate,
	case when (shippedDate > requiredDate) then 'No puntual'
		 else 'Puntual' end as Entrega	
from Sales.Orders

/*
9- Realizar una consulta mostrando el orderdate de la tabla sales.orders separado (una columna 
para Dias, una para Meses, una para anos)
*/

select orderID,
datepart(day,orderdate) as Dia, 
datepart(month,orderdate) as Mes,
datepart(year,orderdate) as Año
from Sales.Orders

/*
10-Mostrar la cantidad de sales.customers cuando el contacttitle sea Owner
*/

select count(*)
from sales.Customers
where contacttitle = 'Owner'

/*
11- Mostrar de la tabla sales.customers en una sola columna la unión del contacttitle, y del contact 
name el nombre que esta después de la ‘,’. Ejemplo: Contacttitle = Owner, ContactName=Allen, Michael
Resultado= Owner Michael
*/
select (contacttitle + SUBSTRING(contactname,CHARINDEX(',',contactname)+1,15)) as Contact_title_and_Name 
from sales.Customers

/*
12- Mostrar de la tabla sales.customers su campo custid,CompanyName sin el texto Customer, y del 
campo phone: Reemplazar los puntos por guiones. Con un 1 – delante ejemplo (1- (5) 456-7890), del 
campo Fax: si el valor es nulo mostrar el texto ‘N/A’.
*/

select CustID, SUBSTRING(CompanyName,CHARINDEX(' ',CompanyName)+1,10) as CompanyName, 
('1 - ' + replace(phone,'.','-')) as Phone, isnull(fax,'N/A') as Fax
from sales.customers

/*
13- De la tabla Sales.OrderDetails mostrar los campos orderid, productId, unitPrice,qty, discount, 
Calcular un nuevo campo llamado total que será el resultado de unitPrice*qty – (unitPrice*qty* 
Discount).

Mostrar un nuevo campo que sea igual a, si Qty < 10 entonces mostrar ‘’ de lo 
contrario ‘’.

Mostrar un nuevo campo que sea llamado nuevo descuento igual a: si el código del productID <= 51 
calcular el nuevo descuento en base al 20% (unitprice * 0.20) de lo contrario 35% (unitprice * 0.35).
*/

select orderid, productid, unitprice, qty, discount, 
(unitPrice*qty - (unitPrice*qty*Discount)) as total,
case when (Qty < 10) then 'Producto Agotado'
		 else 'Producto en existencia' end as Disponibilidad,
case when (productID <= 51) then unitprice * 0.20
		 else unitprice * 0.35 end as Descuento
from Sales.OrderDetails

/*
14- Mostrar la columna productID de Production.Products añadiendo 8 ceros delante, tomando en 
cuenta el siguiente patrón vimos en clase:
00000000
00000001
00000010
00000100
*/

select format(productID,'d8') from Production.Products

/*
15- Utilizando la columna shipRegion de la tabla sales.orders mostrar la cantidad de órdenes en la tabla.
*/

select count(shipregion) from sales.Orders

/*
16- Realizar una consulta a la tabla orders mostrando el orderid,custid,empid, orderdate, requireddate y shippeddate.
adicional a esto usted debe hacer lo necesario para poder mostrar lo siguiente:

 Si la diferencia de días que existe entre el orderdate y required date es igual a 28 o 29 entonces mostrar 'SLA DE 
3 SEMANAS', si es igual a 14 o 15 mostrar 'SLA 2 SEMANAS', 
Si es igual a 42 mostrar 'SLA DE 4 SEMANAS' y si no cumple con ninguna de las anteriores mostrar 'N/A'
*/

select orderid, custid, empid, orderdate, requireddate, shippeddate,
case when 
(DATEDIFF(day,orderdate,requireddate) = 28) or (DATEDIFF(day,orderdate,requireddate) = 29) then 'SLA DE 3 SEMANAS'
	 when
(DATEDIFF(day,orderdate,requireddate) = 14) or (DATEDIFF(day,orderdate,requireddate) = 15) then 'SLA DE 2 SEMANAS'
		when 
(DATEDIFF(day,orderdate,requireddate) = 42) then 'SLA DE 4 SEMANAS'
		else 'N/A' end as [Diferencia de días]
from sales.Orders

/*
17- Crear un query que muestre la cantidad de productos de la tabla products : 1 columna para la cantidad con precio 
menor o igual a 18, otra columna con los precios mayor a 18 y menor o igual a 30., otra columna con los precios mayor a 
30
*/

select qtyMenor18 = (select count(*) from Production.Products where unitprice <= 18), 
qtyMayor18Menor30 = (select count(*) from Production.Products where unitprice > 18 and unitprice <= 30),
qtyMayor30 = (select count(*) from Production.Products where unitprice > 30)
