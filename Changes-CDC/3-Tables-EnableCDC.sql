USE [TestDb];
GO

declare	@supports_net_changes bit;

set		@supports_net_changes = 0;

EXEC sys.sp_cdc_enable_table
	@source_schema = N'data',
	@source_name   = N'Orders',
	@role_name     = NULL,
	@supports_net_changes = @supports_net_changes;

EXEC sys.sp_cdc_enable_table
	@source_schema = N'data',
	@source_name   = N'OrderLines',
	@role_name     = NULL,
	@supports_net_changes = @supports_net_changes;

EXEC sys.sp_cdc_enable_table
	@source_schema = N'data',
	@source_name   = N'Users',
	@role_name     = NULL,
	@supports_net_changes = @supports_net_changes;

GO
