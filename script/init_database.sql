/*

- creating the database and schemas 
- this script will make new database DataWarehouse after checking if it exists.	If it does, then the db is dropped and recreated
- the script also makes 3 schemas named bronze, silver and gold. 
- warning: running this script will drop the database and all data in it wil be gone. 
*/

use master; 

if exists (select 1 from sys.databases where name = 'DataWarehouse')
begin 
	alter database DataWarehouse set single_user with rollback immediate
	drop database DataWarehouse
end 
go; 

--single user: changes access mode of database form multi to single user, all other users are locked out and only u have access atm 
--rollback immediate: instantly terminate all active connections to database 

create database DataWarehouse; 
use DataWarehouse; 
create schema bronze; 
go;                        --go means the stmt before it will be fully executed first 
create schema silver; 
go;
create schema gold;

