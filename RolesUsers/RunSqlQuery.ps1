# Reference
# https://docs.microsoft.com/en-us/powershell/module/sqlserver/invoke-sqlcmd?view=sqlserver-ps

#Install SQL components
Install-Module -Name SqlServer -Scope CurrentUser

# Replace server, username, password in connection string
$connString = 'Server=tcp:YOURSERVER.database.windows.net,1433;Initial Catalog=YOURDATABASE;Persist Security Info=False;User ID=YOURUSERNAME;Password=YOURPASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

# Local path where these files are - instead of a file, you can also pass a query string with the -Query parameter
$localPath = 'c:\someplace'

# File names
$sqlQueryFile = 'myqueryfile.sql'
$resultFile = 'myoutoutfile.txt'

Set-Location $localPath

# Run the SQL command and write any output (there may not be any)
Invoke-SqlCmd -ConnectionString $connString -InputFile $sqlQueryFile -Verbose | Out-File -FilePath $resultFile
