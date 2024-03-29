use [TestDb];
go

-- Reset internal change batch tracking
truncate table evt.Lsns;
go

-- OrderLines Changes
declare @OrderGuid uniqueidentifier,
		@ProductGuid uniqueidentifier;

select	@OrderGuid = OrderGuid from data.Orders;
set		@ProductGuid = newid();

exec data.CreateOrderLine @OrderGuid, @ProductGuid, 10, 1.23;

delete from data.OrderLines where ProductQty = 90 and UnitCost = 10;

update data.OrderLines set UnitCost = 3.33 where UnitCost = 3;

-- Orders Changes
update	data.Orders
set		SalesRep = 'FooPerson'
where	OrderName = 'OrderName_1_1';

exec data.CreateOrder @UserGuid = '081224A9-31AD-4817-9DC3-2910E7730668', @OrderName = 'FooOrder', @OrderDate = '12/2/2018', @SalesRep = 'FooPerson', @CreditCardNumber = '4000123412341115', @CreditCardExp = '12/2025', @CreditCardSecCode = 'ABCD';

delete from data.Orders
where	OrderName = 'OrderName_10_5';

-- Users Changes
update data.Users
set FirstName = FirstName + '_v2',
	LastName = LastName + '_v2'
where UserName = 'UserName10'
;

update data.Users
set MiddleName = 'Foo'
where UserName = 'UserName3'
;

delete from data.Users
where UserName = 'UserName2';
go

insert into data.Users(UserName, FirstName, MiddleName, LastName, EMail, SSN, DoB)
values('FooUser', 'FooFy', 'F', 'Foofer', 'foo@foo.info', '123-45-noyb', '1/2/2003');
go

-- Get the changes! Only changes not yet retrieved will be returned (hence resetting internal change batch tracking up above)
exec [evt].[GetChanges];
go

-- Reset internal change batch tracking
truncate table evt.Lsns;
go

-- Debug flag set so all changes are retrieved without regard to batching/tracking
exec [evt].[GetChanges] 1;
go
