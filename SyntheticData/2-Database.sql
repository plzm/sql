USE [master];
GO

drop database if exists [TestDb];
go

CREATE DATABASE [TestDb]
	CONTAINMENT = NONE
	ON PRIMARY 
( NAME = N'TestDb', FILENAME = N'G:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\TestDb.mdf', SIZE = 128MB , MAXSIZE = UNLIMITED, FILEGROWTH = 128MB )
 LOG ON 
( NAME = N'TestDb_log', FILENAME = N'H:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\TestDb_log.ldf', SIZE = 64MB , MAXSIZE = 2048GB , FILEGROWTH = 64MB )
;
GO

ALTER DATABASE [TestDb] SET COMPATIBILITY_LEVEL = 140
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
	EXEC [TestDb].[dbo].[sp_fulltext_database] @action = 'enable';
end
GO

ALTER DATABASE [TestDb] SET CONTAINMENT = PARTIAL;
go
ALTER DATABASE [TestDb] SET RECOVERY SIMPLE;
GO
ALTER DATABASE [TestDb] SET  MULTI_USER;
GO
ALTER DATABASE [TestDb] SET READ_WRITE;
GO
ALTER DATABASE [TestDb] SET QUERY_STORE = ON;
GO

USE [TestDb];
go

