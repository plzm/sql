USE [master];
GO

CREATE LOGIN [eventGetter] WITH PASSWORD=N'P@ssword2018', DEFAULT_DATABASE=[TestDb], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
GO

-- ==================================================
use TestDb;
go

-- ==================================================

CREATE USER [eventGetter] FOR LOGIN [eventGetter] WITH DEFAULT_SCHEMA=[evt]
GO

-- ==================================================

create schema [evt];
go

grant execute, select on schema :: [cdc] to [eventGetter];
go
grant execute, select on schema :: [data] to [eventGetter];
go
grant execute, select on schema :: [evt] to [eventGetter];
go

create table [evt].[Lsns]
(
	[Entity] [nvarchar](300) constraint [PK_evt_Lsns_Entity] primary key clustered not null,
	[Lsn] [binary](10) not null
)
on [primary];
go

create proc [evt].[SaveLsn]
	@entity		sysname,
	@lsn		binary(10)
as
begin
	if exists (select Entity from evt.Lsns where Entity = @entity)
		begin
			update	evt.Lsns
			set		Lsn = @lsn
			where	Entity = @entity;
		end
	else
		begin
			insert into	evt.Lsns (Entity, Lsn)
			values	(@entity, @Lsn);
		end
end
go

create proc [evt].[GetLsn]
	@entity		sysname,
	@lsn		binary(10) output
as
begin
	declare	@lsnStored	binary(10),
			@lsnCdc		binary(10);

	-- Get latest one stored
	select	@lsnStored = Lsn
	from	evt.Lsns
	where	Entity = @entity;

	-- Get latest one tracked
	select	@lsnCdc = sys.fn_cdc_get_min_lsn(@entity);

	-- Use stored unless tracked is higher - cannot call get changes function with LSNs outside available range
	select @lsn = case
		when @lsnStored is null or @lsnStored < @lsnCdc then @lsnCdc
		else @lsnStored
	end;
end
go

/*
Eventually make GetChanges generic by making the SQL dynamic and building the column projection using something like this...
select FirstNameOrdinal = sys.fn_cdc_get_column_ordinal ('data_Users','FirstName');
select LastNameOrdinal = sys.fn_cdc_get_column_ordinal ('data_Users','LastName');

SELECT *,
	sys.fn_cdc_is_bit_set(@FirstNameOrdinal, __$update_mask) as 'FirstName',
	sys.fn_cdc_is_bit_set(@LastNameOrdinal, __$update_mask) as 'LastName'
FROM [cdc].[fn_cdc_get_all_changes_data_Users](@from_lsn, @to_lsn, 'all');
*/
create proc [evt].[GetChanges]
	@isDebug	bit = 0
as
begin
	set nocount on;

	-- ----------
	-- Generic
	declare	@scopeAll				varchar(20),
			@scopeAllOld			varchar(20),
			@eventTypeDelete		varchar(20),
			@eventTypeCreate		varchar(20),
			@eventTypeUpdate		varchar(20),
			@eventTypeNA			varchar(20),
			@to_lsn					binary(10);

	set		@scopeAll = 'all';
	set		@scopeAllOld = 'all update old';
	set		@eventTypeDelete = 'DELETE';
	set		@eventTypeCreate = 'CREATE';
	set		@eventTypeUpdate = 'UPDATE';
	set		@eventTypeNA = 'N/A';
	-- ----------
	-- Per entity
	declare	@lsn_OrderLines			binary(10),
			@lsn_Orders				binary(10),
			@lsn_Users				binary(10),
			@src_OrderLines			sysname,
			@src_Orders				sysname,
			@src_Users				sysname;

	set		@src_OrderLines = N'data_OrderLines';
	set		@src_Orders = N'data_Orders';
	set		@src_Users = N'data_Users';
	-- ----------

	begin transaction;

	begin try
		if	(@isDebug = 0)
			begin
				exec	evt.GetLsn @src_OrderLines, @lsn_OrderLines output;
				exec	evt.GetLsn @src_Orders, @lsn_Orders output;
				exec	evt.GetLsn @src_Users, @lsn_Users output;
			end
		else
			begin
				set		@lsn_OrderLines = sys.fn_cdc_get_min_lsn(@src_OrderLines);
				set		@lsn_Orders = sys.fn_cdc_get_min_lsn(@src_Orders);
				set		@lsn_Users = sys.fn_cdc_get_min_lsn(@src_Users);
			end

		-- Get upper LSN
		select	@to_lsn = sys.fn_cdc_get_max_lsn();


		select
			[EventData] = JSON_QUERY
			(
				(
					select
						@src_OrderLines as 'Event.Source',
						cast(sys.fn_cdc_map_lsn_to_time(orderlines_current.__$start_lsn) as datetime2) as 'Event.DateTime',
						case
							when orderlines_current.__$operation = 1 then @eventTypeDelete
							when orderlines_current.__$operation = 2 then @eventTypeCreate
							when orderlines_current.__$operation = 3 then @eventTypeUpdate
							when orderlines_current.__$operation =  4 then @eventTypeUpdate
							else @eventTypeNA
						end as 'Event.Type',
						orderlines_current.OrderLineGuid as 'Record.OrderLineGuid',
						orderlines_current.OrderGuid as 'Record.OrderGuid',
						orderlines_current.ProductGuid as 'Record.ProductGuid',
						orderlines_current.ProductQty as 'Record.ProductQty',
						orderlines_current.UnitCost as 'Record.UnitCost',
						orderlines_current.DateCreated as 'Record.DateCreated',
						orderlines_current.DateUpdated as 'Record.DateUpdated',
						case
							when orderlines_prev.OrderLineGuid is not null and orderlines_prev.OrderLineGuid <> orderlines_current.OrderLineGuid then orderlines_prev.OrderLineGuid
							else null
						end as 'Previous.OrderLineGuid',
						case
							when orderlines_prev.OrderGuid is not null and orderlines_prev.OrderGuid <> orderlines_current.OrderGuid then orderlines_prev.OrderGuid
							else null
						end as 'Previous.OrderGuid',
						case
							when orderlines_prev.ProductGuid is not null and orderlines_prev.ProductGuid <> orderlines_current.ProductGuid then orderlines_prev.ProductGuid
							else null
						end as 'Previous.ProductGuid',
						case
							when orderlines_prev.ProductQty is not null and orderlines_prev.ProductQty <> orderlines_current.ProductQty then orderlines_prev.ProductQty
							else null
						end as 'Previous.ProductQty',
						case
							when orderlines_prev.UnitCost is not null and orderlines_prev.UnitCost <> orderlines_current.UnitCost then orderlines_prev.UnitCost
							else null
						end as 'Previous.UnitCost',
						case
							when orderlines_prev.DateCreated is not null and orderlines_prev.DateCreated <> orderlines_current.DateCreated then orderlines_prev.DateCreated
							else null
						end as 'Previous.DateCreated',
						case
							when orderlines_prev.DateUpdated is not null and orderlines_prev.DateUpdated <> orderlines_current.DateUpdated then orderlines_prev.DateUpdated
							else null
						end as 'Previous.DateUpdated'
					for json path,
					without_array_wrapper
				)
			)
		from
			cdc.fn_cdc_get_all_changes_data_OrderLines(@lsn_OrderLines, @to_lsn, @scopeAll) orderlines_current
			left outer join cdc.fn_cdc_get_all_changes_data_OrderLines(@lsn_OrderLines, @to_lsn, @scopeAllOld) orderlines_prev on
				orderlines_current.__$start_lsn = orderlines_prev.__$start_lsn and
				orderlines_current.__$seqval = orderlines_prev.__$seqval and
				orderlines_current.__$operation = 4 and
				orderlines_prev.__$operation = 3

		union all

		select
			[EventData] = JSON_QUERY
			(
				(
					select
						@src_Orders as 'Event.Source',
						cast(sys.fn_cdc_map_lsn_to_time(orders_current.__$start_lsn) as datetime2) as 'Event.DateTime',
						case
							when orders_current.__$operation = 1 then @eventTypeDelete
							when orders_current.__$operation = 2 then @eventTypeCreate
							when orders_current.__$operation = 3 then @eventTypeUpdate
							when orders_current.__$operation =  4 then @eventTypeUpdate
							else @eventTypeNA
						end as 'Event.Type',
						orders_current.OrderGuid as 'Record.OrderGuid',
						orders_current.UserGuid as 'Record.UserGuid',
						orders_current.OrderName as 'Record.OrderName',
						orders_current.OrderDate as 'Record.OrderDate',
						orders_current.SalesRep as 'Record.SalesRep',
						orders_current.CreditCardNumber as 'Record.CreditCardNumber',
						orders_current.CreditCardExp as 'Record.CreditCardExp',
						orders_current.CreditCardSecCode as 'Record.CreditCardSecCode',
						orders_current.DateCreated as 'Record.DateCreated',
						orders_current.DateUpdated as 'Record.DateUpdated',
						case
							when orders_prev.OrderGuid is not null and orders_prev.OrderGuid <> orders_current.OrderGuid then orders_prev.OrderGuid
							else null
						end as 'Previous.OrderGuid',
						case
							when orders_prev.UserGuid is not null and orders_prev.UserGuid <> orders_current.UserGuid then orders_prev.UserGuid
							else null
						end as 'Previous.UserGuid',
						case
							when orders_prev.OrderName is not null and orders_prev.OrderName <> orders_current.OrderName then orders_prev.OrderName
							else null
						end as 'Previous.OrderName',
						case
							when orders_prev.OrderDate is not null and orders_prev.OrderDate <> orders_current.OrderDate then orders_prev.OrderDate
							else null
						end as 'Previous.OrderDate',
						case
							when orders_prev.SalesRep is not null and orders_prev.SalesRep <> orders_current.SalesRep then orders_prev.SalesRep
							else null
						end as 'Previous.SalesRep',
						case
							when orders_prev.CreditCardNumber is not null and orders_prev.CreditCardNumber <> orders_current.CreditCardNumber then orders_prev.CreditCardNumber
							else null
						end as 'Previous.CreditCardNumber',
						case
							when orders_prev.CreditCardExp is not null and orders_prev.CreditCardExp <> orders_current.CreditCardExp then orders_prev.CreditCardExp
							else null
						end as 'Previous.CreditCardExp',
						case
							when orders_prev.CreditCardSecCode is not null and orders_prev.CreditCardSecCode <> orders_current.CreditCardSecCode then orders_prev.CreditCardSecCode
							else null
						end as 'Previous.CreditCardSecCode',
						case
							when orders_prev.DateCreated is not null and orders_prev.DateCreated <> orders_current.DateCreated then orders_prev.DateCreated
							else null
						end as 'Previous.DateCreated',
						case
							when orders_prev.DateUpdated is not null and orders_prev.DateUpdated <> orders_current.DateUpdated then orders_prev.DateUpdated
							else null
						end as 'Previous.DateUpdated'
					for json path,
					without_array_wrapper
				)
			)
		from
			cdc.fn_cdc_get_all_changes_data_Orders(@lsn_Orders, @to_lsn, @scopeAll) orders_current
			left outer join cdc.fn_cdc_get_all_changes_data_Orders(@lsn_Orders, @to_lsn, @scopeAllOld) orders_prev on
				orders_current.__$start_lsn = orders_prev.__$start_lsn and
				orders_current.__$seqval = orders_prev.__$seqval and
				orders_current.__$operation = 4 and
				orders_prev.__$operation = 3

		union all

		select
			[EventData] = JSON_QUERY
			(
				(
					select
						@src_Users as 'Event.Source',
						cast(sys.fn_cdc_map_lsn_to_time(users_current.__$start_lsn) as datetime2) as 'Event.DateTime',
						case
							when users_current.__$operation = 1 then @eventTypeDelete
							when users_current.__$operation = 2 then @eventTypeCreate
							when users_current.__$operation = 3 then @eventTypeUpdate
							when users_current.__$operation =  4 then @eventTypeUpdate
							else @eventTypeNA
						end as 'Event.Type',
						users_current.UserGuid as 'Record.UserGuid',
						users_current.UserName as 'Record.UserName',
						users_current.FirstName as 'Record.FirstName',
						users_current.MiddleName as 'Record.MiddleName',
						users_current.LastName as 'Record.LastName',
						users_current.EMail as 'Record.EMail',
						users_current.SSN as 'Record.SSN',
						users_current.DoB as 'Record.DoB',
						users_current.DateCreated as 'Record.DateCreated',
						users_current.DateUpdated as 'Record.DateUpdated',
						case
							when users_prev.UserGuid is not null and users_prev.UserGuid <> users_current.UserGuid then users_prev.UserGuid
							else null
						end as 'Previous.UserGuid',
						case
							when users_prev.UserName is not null and users_prev.UserName <> users_current.UserName then users_prev.UserName
							else null
						end as 'Previous.UserName',
						case
							when users_prev.FirstName is not null and users_prev.FirstName <> users_current.FirstName then users_prev.FirstName
							else null
						end as 'Previous.FirstName',
						case
							when users_prev.MiddleName is not null and users_prev.MiddleName <> users_current.MiddleName then users_prev.MiddleName
							else null
						end as 'Previous.MiddleName',
						case
							when users_prev.LastName is not null and users_prev.LastName <> users_current.LastName then users_prev.LastName
							else null
						end as 'Previous.LastName',
						case
							when users_prev.EMail is not null and users_prev.EMail <> users_current.EMail then users_prev.EMail
							else null
						end as 'Previous.EMail',
						case
							when users_prev.SSN is not null and users_prev.SSN <> users_current.SSN then users_prev.SSN
							else null
						end as 'Previous.SSN',
						case
							when users_prev.DoB is not null and users_prev.DoB <> users_current.DoB then users_prev.DoB
							else null
						end as 'Previous.DoB',
						case
							when users_prev.DateCreated is not null and users_prev.DateCreated <> users_current.DateCreated then users_prev.DateCreated
							else null
						end as 'Previous.DateCreated',
						case
							when users_prev.DateUpdated is not null and users_prev.DateUpdated <> users_current.DateUpdated then users_prev.DateUpdated
							else null
						end as 'Previous.DateUpdated'
					for json path,
					without_array_wrapper
				)
			)
		from
			cdc.fn_cdc_get_all_changes_data_Users(@lsn_Users, @to_lsn, @scopeAll) users_current
			left outer join cdc.fn_cdc_get_all_changes_data_Users(@lsn_Users, @to_lsn, @scopeAllOld) users_prev on
				users_current.__$start_lsn = users_prev.__$start_lsn and
				users_current.__$seqval = users_prev.__$seqval and
				users_current.__$operation = 4 and
				users_prev.__$operation = 3
		;

		 -- Update upper LSN used for next batch retrieval
		 exec	evt.SaveLsn @src_OrderLines, @to_lsn;
		 exec	evt.SaveLsn @src_Orders, @to_lsn;
		 exec	evt.SaveLsn @src_Users, @to_lsn;
	end try
	begin catch
		if	@@trancount > 0
			rollback transaction;
	end catch

	if	@@trancount > 0
		commit transaction;
end
go
