CREATE TABLE #Servidores(
ServerName nvarchar(100),
)

insert into #Servidores
values ('webServer001_web.intec.com.backend'),
('webServer002_ssl.google.com_443.backend'),
('webServer003_ftp.intec.com_2021.backend'),
('webServer004_sql.claro.com_888.backend'),
('webServer005_smptp.altice.com_9594.backend'),
('webServer005_ftp.intec.com_9594.backend'),
('webServer005_ftp.intec.com.backend')


/*
Angel Daniel Guzmán Gómez - 1093756 - SQL Parte 2

1- Generar un query que sea capaz de extraer la información 
que se encuentra dentro del fullName y separarla en partes.

2- Usted debe agregar una nueva columna llamada FlatName, esta estará compuesta del hostName sin el 
tipo de servidor (por ejemplo webServer001_web y intec.com seria WebServer001.intec.com)
combinado con el dominio.
*/

select ServerName,
--El primer comando
left(ServerName,CHARINDEX('.',ServerName)-1) [HostName],
--El segundo comando
left(substring(ServerName,CHARINDEX('.',ServerName)+1,10),CHARINDEX('.',substring(ServerName,CHARINDEX('.',ServerName)+1,10))+3) [Domain],
--El tercer comando
isnull(try_CAST(replace(replace(substring(right(ServerName,12),CHARINDEX('_',right(ServerName,12))+1,5),'.',''),'b','') as int),88) [PortNumber],
--El cuarto comando
substring(
left(ServerName,CHARINDEX('.',ServerName)-1),
CHARINDEX('_',left(ServerName,CHARINDEX('.',ServerName)+1))+1,
len(left(ServerName,CHARINDEX('.',ServerName)+1))-CHARINDEX('_',left(ServerName,CHARINDEX('.',ServerName)-1))) [TipoServidor],
concat(
left(ServerName,CHARINDEX('_',ServerName)-1),
'.',
left(substring(ServerName,CHARINDEX('.',ServerName)+1,10),CHARINDEX('.',substring(ServerName,CHARINDEX('.',ServerName)+1,10))+3)) [FlatName]

from #Servidores

/*
3- Debe retornar un query que devuelva la cantidad de servidores por cada tipo
*/

select substring(
left(ServerName,CHARINDEX('.',ServerName)-1),
CHARINDEX('_',left(ServerName,CHARINDEX('.',ServerName)+1))+1,
len(left(ServerName,CHARINDEX('.',ServerName)+1))-CHARINDEX('_',left(ServerName,CHARINDEX('.',ServerName)-1))) [TipoServidor],
count(substring(
left(ServerName,CHARINDEX('.',ServerName)-1),
CHARINDEX('_',left(ServerName,CHARINDEX('.',ServerName)+1))+1,
len(left(ServerName,CHARINDEX('.',ServerName)+1))-CHARINDEX('_',left(ServerName,CHARINDEX('.',ServerName)-1)))) [Cantidad]
from #Servidores
group by substring(
left(ServerName,CHARINDEX('.',ServerName)-1),
CHARINDEX('_',left(ServerName,CHARINDEX('.',ServerName)+1))+1,
len(left(ServerName,CHARINDEX('.',ServerName)+1))-CHARINDEX('_',left(ServerName,CHARINDEX('.',ServerName)-1)))


/*
4. Debe retornar la cantidad de servidores por cada puerto
*/

select 
isnull(
try_CAST(replace(replace(substring(right(ServerName,12),
CHARINDEX('_',right(ServerName,12))+1,5),'.',''),'b','') as int),88) [PortNumber],
count(isnull(
try_CAST(replace(replace(substring(right(ServerName,12),
CHARINDEX('_',right(ServerName,12))+1,5),'.',''),'b','') as int),88)) [Cantidad]
from #Servidores
group by isnull(try_CAST(replace(replace(substring(right(ServerName,12),CHARINDEX('_',right(ServerName,12))+1,5),'.',''),'b','') as int),88)