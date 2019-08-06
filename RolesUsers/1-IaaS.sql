-- Use this for IaaS - i.e. SQL Server - to prep server and database for contained authentication,
-- so that logins are defined only inside the database. NOT at the server level = better portability and compatibility with Azure SQL DB.
-- Do not use this with Azure SQL DB.

-- =======================================
-- Change database name from TestDb to your database name below.
-- =======================================

USE [master];
GO

sp_configure 'contained database authentication', 1;  
GO 
reconfigure;  
GO

use TestDb;
go

alter database [TestDb] set containment = partial;
go
