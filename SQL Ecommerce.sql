Create database Ecommerce_1093756
use Ecommerce_1093756

create table Categorias(
Categoria_ID int not null primary key identity(1,1),
NombreCategoria varchar(25) not null,
Descripcion varchar(200) not null
)

create table Productos(
Producto_ID int not null primary key identity(1,1),
Categoria_ID int not null,
NombreProducto varchar(50) not null unique,
PrecioUnidad money not null,
UnidadesExistentes int not null,
Descontinuado bit not null,
Foreign key (Categoria_ID) references Categorias (Categoria_ID)
)

create table Provincia(
Provincia_ID int not null primary key identity(1,1),
NombreProvincia nvarchar(25) not null
)

create table Sector(
Sector_ID int not null,
Provincia_ID int not null,
NombreSector nvarchar(40) not null,
primary key(Sector_ID, Provincia_ID),
Foreign key (Provincia_ID) references Provincia (Provincia_ID)
)

create table Clientes(
Cliente_ID int not null primary key identity(1,1),
NombresCliente varchar(20) not null,
ApellidosCliente varchar(30) not null,
PuntajeCrediticio int not null,
Provincia_ID int not null,
Sector_ID int not null,
CalleYcasa varchar(10) not null,
Foreign key (Sector_ID, Provincia_ID) references Sector (Sector_ID, Provincia_ID)
)

create table Compras(
Compra_ID int not null primary key identity(1,1),
Cliente_ID int not null,
PrecioBruto money not null,
Impuesto money not null,
Descuento real not null,
PrecioTotal money not null,
FechaCompra datetime not null,
FechaRequerida datetime not null,
FechaEnvio datetime not null,
Provincia_ID int not null,
Sector_ID int not null,
CalleYcasa varchar(10) not null,
Foreign key (Cliente_ID) references Clientes (Cliente_ID)
)

create table DetalleCompras(
Compra_ID int not null,
Producto_ID int not null,
PrecioUnidad money not null,
CantidadProductos smallint not null,
descuento real not null,
primary key(compra_ID, Producto_ID),
Foreign key (Compra_ID) references Compras (Compra_ID),
Foreign key (Producto_ID) references Productos (Producto_ID)
)

insert into dbo.Categorias (NombreCategoria, Descripcion) values 
('Calzado','Tennis, zapatos, chancletas, etc...'),
('Camisas', 'Manga cortas, manga largas, etc...'),
('Blusas','Blusas cortas, blusas largas, etc...'),
('Pantalones','Shorts, Jeans, caquis, etc...'),
('Faldas','Faldas cortas, faldas largas, etc...'),
('Vestidos', 'Vestidos cortos, vestidos largos, etc...'),
('Accesorios','Correas, gafas, anillos, etc...')

insert into Provincia values ('Santo Domingo'),('Santiago Rodriguez'),('Espaillat'),('La Altagracia'),('Puerto Plata')
insert into Sector values (1,1,'Bella Vista'),(2,2,'Sabaneta'),(3,3,'Villa Carolina III'),(4,4,'Residencial Doña Rosa'),(5,5,'Las Caobas')

insert into Clientes values 
('Jose Mario','Martinez Ocasio',0,1,1,'Ca5, #9'),
('Marcos','Jimenez Jerez',0,1,1,'Ca8, #2'),
('Marcela','Diaz Sanchez',0,2,2,'Ca3, #7'),
('Pamela','Colon Espinal',0,2,2,'Ca1, #4'),
('Jose','Gomez Nunez',0,3,3,'Ca5, #9'),
('Roberta','Mirabal',0,3,3,'Ca6, #5'),
('Bianny','Perez',0,4,4,'Ca2, #14'),
('Pablo','Martinez Carvajal',0,4,4,'Ca5, #9'),
('Elias','Lopez Diaz',0,5,5,'Ca7, #1'),
('Emily','Suarez Mendez',0,5,5,'Ca3, #26')

/*
Procedure para insertar un producto en la tabla de productos
*/

create or alter procedure InsertarProducto
(--parametros
	@Categoria_ID int,
	@NombreProducto varchar(50),
	@PrecioUnidad money,
	@UnidadesExistentes int
)
as
begin
	begin try
		if (@PrecioUnidad > 0 and @UnidadesExistentes > 0 and len(@NombreProducto) > 0)
		begin
			insert into dbo.Productos (categoria_ID, NombreProducto, PrecioUnidad, UnidadesExistentes, Descontinuado) 
			values (@Categoria_ID, @NombreProducto, @PrecioUnidad, @UnidadesExistentes, '0')
		end
		else
		begin
			RAISERROR('El precio de la unidad, de las unidades existentes o el tamaño de alguna cadena es menor o igual que 0.', 16, 1)
		end
	end try
	begin catch
		DECLARE @Message varchar(MAX) = ERROR_MESSAGE(),
        @Severity int = ERROR_SEVERITY(),
        @State smallint = ERROR_STATE()
		RAISERROR (@Message, @Severity, @State)
	end catch
end

/*
Procedure para eliminar un producto en la tabla de productos
*/

Create or alter procedure EliminarProducto
(--parametros
	@Producto_ID int
)
as
begin
	update Productos
		Set Descontinuado = '1'
		where Producto_ID = @Producto_ID
end

/*
Procedure para actualizar un producto en la tabla de productos
*/

create or alter procedure UpdateProductos
(--parametros
	@Producto_ID int,
	@CantidadProducto smallint = 0,
	@UnidadesAgregadas int = null
)
as
begin
	if((select Descontinuado from Productos where Producto_ID = @Producto_ID) = 0)
	begin
		if (@UnidadesAgregadas is not null and @UnidadesAgregadas > 0)
		begin
			update Productos
				set UnidadesExistentes += @UnidadesAgregadas
				where Producto_ID = @Producto_ID
		end
		if (@CantidadProducto <> 0)
		begin
			if((select UnidadesExistentes from Productos where Producto_ID = @Producto_ID) > @CantidadProducto)
			begin
				if (@CantidadProducto > 0)
				begin
					update Productos
						set UnidadesExistentes -= @CantidadProducto
						where Producto_ID = @Producto_ID
				end
				else
				begin
					RAISERROR ('No se aceptan parametros negativos', 16, 1)
				end
			end
			else
			begin
				RAISERROR ('El producto no se puede colocar porque no existen suficientes unidades', 16, 1)
			end
		end
	end
	else
	begin
		RAISERROR ('El producto ya no se encuentra disponible en nuestra tienda', 16, 1)
	end
end

/*
Procedure para agregar una orden o compra en la tabla de compra
*/

create or alter procedure AgregarCompra(
	@Cliente_ID int,
	@FechaRequerida nvarchar(10)
)
as
begin
	begin try
		if (Exists (select @Cliente_ID from Clientes where Cliente_ID = @Cliente_ID))
		begin
			if (len(@FechaRequerida) >= 8)
			begin
				insert into Compras (Cliente_ID, PrecioBruto,Impuesto,descuento,PrecioTotal,FechaCompra,FechaRequerida,FechaEnvio, Provincia_ID, Sector_ID, CalleYcasa)
				values (@Cliente_ID,0,0,0,0,GETDATE(),CONVERT(datetime,@FechaRequerida, 103),dateadd(day,7,CONVERT(datetime,@FechaRequerida, 103)), 
				(select Provincia_ID from Clientes where Cliente_ID = @Cliente_ID), 
				(select Sector_ID from Clientes where Cliente_ID = @Cliente_ID),
				(select CalleYcasa from Clientes where Cliente_ID = @Cliente_ID))
			end
			else
			begin
				RAISERROR ('Error: La fecha es muy corta. Introduzca la fecha correctamente. Ejemplo:(15/03/2021)', 16, 1)			
			end
		end
		else
		begin
			RAISERROR ('Error: No existe el cliente introducido', 11, 1)
		end
	end try
	begin catch
		DECLARE @Message varchar(MAX) = ERROR_MESSAGE(),
        @Severity int = ERROR_SEVERITY(),
        @State smallint = ERROR_STATE()
		RAISERROR (@Message, @Severity, @State)
	end catch
end

/*
Procedure para insertar un producto en una compra en la tabla de DetalleCompras. 
También utiliza el procedure "UpdateProductos"
*/

create or alter procedure InsertDetalleCompras(
	@Compra_ID int,
	@Producto_ID int,
	@CantidadProductos smallint
)
as
begin
	begin tran
		begin try
			if (@CantidadProductos > 0)
			begin
				if ((select top 1 cliente_ID from clientes order by PuntajeCrediticio desc) = (select cliente_ID from Compras where Cliente_ID = Cliente_ID and Compra_ID = @Compra_ID))
				begin			
					Insert into DetalleCompras(Compra_ID, Producto_ID, PrecioUnidad, CantidadProductos, descuento)
					values (@Compra_ID, @Producto_ID,(select PrecioUnidad from Productos where Producto_ID = @Producto_ID),@CantidadProductos,0.15)
					exec UpdateProductos @Producto_ID, @cantidadProductos
				end
				else
				begin
					Insert into DetalleCompras(Compra_ID, Producto_ID, PrecioUnidad, CantidadProductos, descuento)
					values (@Compra_ID, @Producto_ID,(select PrecioUnidad from Productos where Producto_ID = @Producto_ID),@CantidadProductos,0)
					exec UpdateProductos @Producto_ID, @cantidadProductos
				end
				commit tran
			end
			else
			begin
				RAISERROR ('Error: La cantidad de productos ingresada es menor que 0.', 16, 1)
			end
		end try
		begin catch
			select Error_message()	
			rollback tran
		end catch
end

/*
Procedure para procesar una compra. Este hace una actualización en la tabla de Compras
y en la tabla clientes para registrarle el puntaje crediticio.
*/

create or alter procedure ProcesarCompra(
	@Compra_ID int
)
as
begin

	declare @descuento money
	select @descuento = (select distinct(descuento) from DetalleCompras where Compra_ID = @Compra_ID)
	begin try
		if (exists (select top 1 * from DetalleCompras where Compra_ID = @Compra_ID))
		begin
			update Compras
				set PrecioBruto = (select sum(PrecioUnidad*CantidadProductos) from DetalleCompras where Compra_ID = @Compra_ID),
				Impuesto = (select sum((PrecioUnidad*CantidadProductos)*0.18) from DetalleCompras where Compra_ID = @Compra_ID),
				PrecioTotal = (select sum((((PrecioUnidad*(1-@descuento)))*CantidadProductos)+((PrecioUnidad*CantidadProductos)*0.18))
				from DetalleCompras where Compra_ID = @Compra_ID),
				Descuento = (select sum((PrecioUnidad*CantidadProductos)*@descuento) from DetalleCompras where Compra_ID = @Compra_ID)
				where Compra_ID = @Compra_ID

			Update Clientes
				set PuntajeCrediticio += (select sum(PrecioUnidad*CantidadProductos) from DetalleCompras where Compra_ID = @Compra_ID)/100
				where Cliente_ID = (select Cliente_ID from Compras where Compra_ID = @Compra_ID)
		end
		else
		begin
			RAISERROR ('Error: La compra no tiene productos agregados', 16, 1)
		end
	end try
	begin catch
		select Error_message()
	end catch
end

/*
PrecioBruto = PrecioUnidad*CantidadProductos
Impuesto que se debe agregar = ((PrecioUnidad*CantidadProductos)*0.18)
Precio con descuento = ((PrecioUnidad*CantidadProductos)*0.85)
PrecioTotal = ((PrecioUnidad*0.85)*CantidadProductos)+((PrecioUnidad*CantidadProductos)*0.18)
*/

--Insertar producto en la tabla Productos
exec InsertarProducto '1', 'Tennis deportivos adidas', '2000.00', '100'
exec InsertarProducto '7', 'Gafas de sol amarilla', '500.00', '100'
exec InsertarProducto '7', 'Gafas de sol negras', '500.00', '100'
exec InsertarProducto '4', 'Jeans negros', '1500.00', '100'
exec InsertarProducto '4', 'Caquis', '1750.00', '100'
exec InsertarProducto '3', 'Blusa corta rosada', '850.00', '100'
exec InsertarProducto '2', 'Camisa manga corta', '1250.00', '100'

--Eliminar un producto de la tabla producto
exec EliminarProducto '1'

--Hacer actualizacion de la tabla producto
exec UpdateProductos @Producto_ID = 1, @CantidadProducto = 5
exec UpdateProductos @Producto_ID = 1, @UnidadesAgregadas = 50

--Agregar una compra en la tabla Compras
exec AgregarCompra 1,'01/03/2021'

--Insertar un producto en detalle compra, junto con update de la tabla producto
exec InsertDetalleCompras 6,7,2

--Actualizar la compra realizada y el cliente
exec ProcesarCompra 6

--Tablas que se utilizan para revisar
select * from Categorias
select * from Productos
select * from DetalleCompras
select * from Compras
select * from Clientes

/*
Cliente con mayor puntaje crediticio
*/

select top 1 * from clientes order by PuntajeCrediticio desc

/*
Productos más vendidos en la tienda.
*/

select top 5 D.Producto_ID,P.NombreProducto, Count(D.Producto_ID)*CantidadProductos [CantidadVentas]
from DetalleCompras D join Productos P on D.Producto_ID = P.Producto_ID
group by CantidadProductos, D.Producto_ID, P.NombreProducto
order by CantidadVentas desc

/*
Mostrar los 5 productos más vendidos a cliente en específico.
*/

select top 5 C.Cliente_ID, P.Producto_ID, P.NombreProducto, Sum(D.CantidadProductos)[CantidadProducto] 
from Compras C join DetalleCompras D on C.Compra_ID = D.Compra_ID
join Productos P on D.Producto_ID = P.Producto_ID
Where cliente_ID = 1
Group by P.Producto_ID, NombreProducto, C.Cliente_ID
order by CantidadProducto desc

/*
Categorias mas vendidas por precio
*/

select C.NombreCategoria, sum(D.PrecioUnidad*CantidadProductos) [CantidadVentas]
from DetalleCompras D join Productos P on D.Producto_ID = P.Producto_ID
join Categorias C on P.Categoria_ID = C.Categoria_ID
group by C.NombreCategoria

/*
Productos mas vendidos por categoria
*/

select * from 
 (select Row_number() over (partition by C.NombreCategoria order by sum(D.PrecioUnidad*CantidadProductos) desc) as Row_ID,
 C.NombreCategoria,P.Producto_ID, sum(D.PrecioUnidad*CantidadProductos) [CantidadVentas]
from DetalleCompras D join Productos P on D.Producto_ID = P.Producto_ID
join Categorias C on P.Categoria_ID = C.Categoria_ID
group by C.NombreCategoria, P.Producto_ID)
_ where Row_ID = 1


/*
Registro para crear productos
*/

create sequence ListaProductosID
start with 1
increment by 1

Declare @ListaProductos table (ID int, Categoria_ID int, NombreProducto varchar(50))
insert into @ListaProductos
	values 
	(next value for ListaProductosID,1,'Tennis deportivos Nike'),
	(next value for ListaProductosID,1,'Tennis deportivos Reebok'),
	(next value for ListaProductosID,1,'Zapatos de vestir negros'),
	(next value for ListaProductosID,1,'Zapatos de vestir marrones'),
	(next value for ListaProductosID,1,'Zapatos de vestir blancos'),
	(next value for ListaProductosID,2,'Camisa manga corta negra'),
	(next value for ListaProductosID,2,'Camisa manga corta blanca'),
	(next value for ListaProductosID,2,'Camisa manga corta Azul'),
	(next value for ListaProductosID,2,'Camisa manga larga'),
	(next value for ListaProductosID,2,'Camisa manga larga negra'),
	(next value for ListaProductosID,2,'Camisa manga larga blanca'),
	(next value for ListaProductosID,2,'Camisa manga larga Azul'),
	(next value for ListaProductosID,3,'Blusa corta Roja'),
	(next value for ListaProductosID,3,'Blusa corta Azul'),
	(next value for ListaProductosID,3,'Blusa corta Verde lima'),
	(next value for ListaProductosID,3,'Blusa larga Roja'),
	(next value for ListaProductosID,3,'Blusa larga Azul'),
	(next value for ListaProductosID,3,'Blusa larga Rosada'),
	(next value for ListaProductosID,3,'Blusa larga Verde lima'),
	(next value for ListaProductosID,4,'Jeans Azul oscuro'),
	(next value for ListaProductosID,4,'Jeans gris'),
	(next value for ListaProductosID,5,'Falda corta Rosada'),
	(next value for ListaProductosID,5,'Falda corta Blanca'),
	(next value for ListaProductosID,5,'Falda corta Roja'),
	(next value for ListaProductosID,5,'Falda larga Rosada'),
	(next value for ListaProductosID,5,'Falda larga Blanca'),
	(next value for ListaProductosID,5,'Falda larga Roja'),
	(next value for ListaProductosID,6,'Vestido corto Rosado'),
	(next value for ListaProductosID,6,'Vestido corto Blanco'),
	(next value for ListaProductosID,6,'Vestido largo Negro'),
	(next value for ListaProductosID,7,'Anillo tamaño mediano'),
	(next value for ListaProductosID,7,'Anillo tamaño pequeño'),
	(next value for ListaProductosID,7,'Correas negras')

	Declare @ListaProductosLen int = (select count(*) from @ListaProductos);
	declare @i int = 1;
	declare @Dinero money, @NombreProducto nvarchar(50), @Categoria_ID int;
	while @i <= @ListaProductosLen
	begin
		set @Dinero = (select ROUND(rand()*(2000)+500,2));
		set @NombreProducto = (select NombreProducto from @ListaProductos where ID = @i);
		set @Categoria_ID = (select Categoria_ID from @ListaProductos where ID = @i);
		exec InsertarProducto @Categoria_ID, @NombreProducto, @Dinero, 300
		set @i += 1
	end

 /*
 Registro de venta para 500 productos
 */

select * from Compras
select * from DetalleCompras

declare @i int = 1
while @i <= 500
begin
	declare @NumeroDetalleCompras int = (select floor(rand()*(4)+1))
	declare @Dia int = floor(rand()*(26)+1), @Mes int = floor(rand()*(11)+1)
	declare @fecha nvarchar(10) = (select cast(@Dia as varchar)+'/'+cast(@Mes as varchar)+'/'+'2022')
	declare @ClienteIDRandom int = (select floor(rand()*(select count(*) from Clientes)+1))
	exec AgregarCompra @ClienteIDRandom,@fecha
	
	declare @j int = 1
	while @j <= @NumeroDetalleCompras
	begin
		declare @ProductoIDRandom int = (select floor(rand()*((select count(*) from Productos))+1))
		if (@ProductoIDRandom in (select Producto_ID from DetalleCompras where Compra_ID = @i))
			continue
		declare @CantidadRandom int = (select floor(rand()*(3)+1))
		exec InsertDetalleCompras @i,@ProductoIDRandom,@CantidadRandom
		set @j += 1
	end
	exec ProcesarCompra @i
	set @i += 1
end
