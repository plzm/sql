DECLARE
	@folder_name		NVARCHAR(50),
	@project_name		NVARCHAR(50),
	@package_name		NVARCHAR(50),
	@use_32bit_runtime	BIT,
	@run_in_scaleout	BIT,
	@use_any_worker		BIT,
	@retry_count		INT,
	@return_value		INT,
	@exe_id				BIGINT,
	@status				INT,
	@err_msg			NVARCHAR(150)
;

SELECT
	@folder_name = N'ADFLab',
	@project_name = N'ADFLab',
	@package_name = N'Module2.dtsx',
	@use_32bit_runtime = 0,
	@run_in_scaleout = 1,
	@use_any_worker = 1,
	@retry_count = 0
;

EXEC @return_value = [SSISDB].[catalog].[create_execution]
	@folder_name = @folder_name,
	@project_name = @project_name,
	@package_name = @package_name,
	@use32bitruntime = @use_32bit_runtime,
	@runinscaleout = @run_in_scaleout,
	@useanyworker = @use_any_worker,
	@execution_id = @exe_id OUTPUT
;

EXEC [SSISDB].[catalog].[set_execution_parameter_value] 
	@exe_id,
	@object_type = 50,
	@parameter_name = N'SYNCHRONIZED',
	@parameter_value = 1
;

EXEC [SSISDB].[catalog].[start_execution]
	@execution_id = @exe_id,
	@retry_count = @retry_count
;

SELECT	@status = [status]
FROM	[SSISDB].[catalog].[executions]
WHERE	execution_id = @exe_id
;

IF	(@status <> 7)
BEGIN
	SET @err_msg = N'Package execution FAILED for execution ID: ' + CAST(@exe_id AS NVARCHAR(20));
	
	RAISERROR(@err_msg, 15, 1)
END
