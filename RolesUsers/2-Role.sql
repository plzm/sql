-- Create a role within database

-- Substitute your role name for TestRole1 below

-- Create role
if not exists (select [name] from sys.sysusers where [name] = 'TestRole1' and issqlrole = 1)
	create role TestRole1;
go
