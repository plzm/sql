-- Create a SQL login within database - nothing at the server level
-- Substitute your user name for TestUser1 below

-- Drop user if currently exists
if exists (select [name] from sys.sysusers where [name] = 'TestUser1' and (islogin = 1 or issqluser = 1))
	drop user TestUser1;
go

-- Create user - replace username and password below, plus optionally schema if you use other than dbo (good idea!)
create user TestUser1 with password = N'P@ssw0rd2018!', DEFAULT_SCHEMA=[dbo];
go
