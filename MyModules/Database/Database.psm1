function Find-MongoDbPath {
    First-Path `
        (Find-ProgramFiles 'MongoDB\Server\4.0\bin') `
        (Find-ProgramFiles 'MongoDB\Server\3.6\bin') `
        (Find-ProgramFiles 'MongoDB\Server\3.4\bin') `
        (Find-ProgramFiles 'MongoDB\Server\3.2\bin')
}

function Find-MySqlBinaries {
    First-Path `
        (Find-ProgramFiles 'MySQL\MySQL Server 8.0\bin') `
        (Find-ProgramFiles 'MySQL\MySQL Server 5.7\bin') `
        (Find-ProgramFiles 'MySQL\MySQL Server 5.6\bin') `
        (Find-ProgramFiles 'MySQL\MySQL Server 5.5\bin')
}

function Find-MSSqlBinaries {
    First-Path `
        (Find-ProgramFiles 'Microsoft SQL Server\ClientSDK\ODBC\140\Tool\Binn') `
        (Find-ProgramFiles 'Microsoft SQL Server\ClientSDK\ODBC\130\Tool\Binn') `
        (Find-ProgramFiles 'Microsoft SQL Server\120\Tools\Binn') `
        (Find-ProgramFiles 'Microsoft SQL Server\110\Tools\Binn')
}

function Find-PostgreSqlPath {
    First-Path `
        (Find-ProgramFiles 'PostgreSQL\10\pgAdmin 4\bin') `
        (Find-ProgramFiles 'PostgreSQL\9.6\pgAdmin 4\bin') `
        (Find-ProgramFiles 'PostgreSQL\9.5\pgAdmin 4\bin') 
}

##############################################################################

function Start-MongoDBClient {
    & "$(Find-MongoDbPath)\mongo.exe"
}

function Export-MongoCollection {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$JsonFile,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Database,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Collection
    )

    $parameters = "--db $Database --collection $Collection --out $JsonFile"
 
    & "$(Find-MongoDbPath)\mongoexport.exe $parameters"
}

function Import-MongoCollectionFromCsv {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ })]
        [String]$CsvFile,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Database,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Collection

    )

    $parameters = "--type csv --headerline $CsvFile -d $Database -c $Collection"
 
    & "$(Find-MongoDbPath)\mongoimport.exe $parameters"
}

function Import-MongoCollectionFromDump {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ })]
        [String]$DumpFile,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Database,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Collection
    )

    $parameters = "--headerline $CsvFile -d $Database -c $Collection"
 
    & "$(Find-MongoDbPath)\mongoimport.exe $parameters"
}

function Invoke-MSSqlCommand {
    Start-Process -FilePath "$(Find-MSSqlBinaries)\sqlcmd.exe" `
        -ArgumentList $args -NoNewWindow -Wait
}

function Start-MongoDBServer {
    & sc.exe start MongoDB
}

function Start-MySqlClient {
    $mysqlPath = Find-MySqlBinaries

    & "$mysqlPath\mysql.exe" "--defaults-file=$mysqlPath\my.ini" "-uroot" "-p"
}

function Start-MySqlServer()
{
    $mysqlPath = Find-MySqlBinaries
    
    & "$mysqlPath\mysql.exe" Start
}

function Start-MSSqlServer {
    & sc.exe start MSSQLSERVER
}

function Start-PostgreSQLClient {
    Start-Process "$(Find-PostgreSqlPath)\pgAdmin4.exe"
}

function Start-PostgreSQLServer {
    $service = Get-Service | Where-Object { $_.Name -like "postgresql*" }
    & sc.exe start $service
}

function Stop-MongoDBServer {
    & sc.exe stop MongoDB
}

function Stop-MySqlServer()
{
    $mysqlPath = Find-MySqlBinaries
    
    & "$mysqlPath\mysql.exe" Stop
}

function Stop-MSSqlServer {
    & sc.exe stop MSSQLSERVER
}

function Stop-PostgreSQLServer {
    $service = Get-Service | Where-Object { $_.Name -like "postgresql*" }
    & sc.exe stop $service
}

##############################################################################

Export-ModuleMember Export-MongoCollection

Export-ModuleMember Import-MongoCollectionFromCsv
Export-ModuleMember Import-MongoCollectionFromDump

Export-ModuleMember Invoke-MSSqlCommand

Export-ModuleMember Start-MongoDBServer
Export-ModuleMember Start-MySqlServer
Export-ModuleMember Start-MSSqlServer
Export-ModuleMember Start-PostgreSQLClient
Export-ModuleMember Start-PostgreSQLServer

Export-ModuleMember Stop-MongoDBServer
Export-ModuleMember Stop-MySqlServer
Export-ModuleMember Stop-MSSqlServer
Export-ModuleMember Stop-PostgreSQLServer

Set-Alias mongodb-client Start-MongoDBClient
Set-Alias mongodb-start Start-MongoDBServer
Set-Alias mongodb-stop Stop-MongoDBServer

Set-Alias mssql-start Start-MSSqlServer
Set-Alias mssql-stop Stop-MSSqlServer

Set-Alias mysql-client Start-MySqlClient
Set-Alias mysql-start Start-MySqlServer
Set-Alias mysql-stop Stop-MySqlServer

Set-Alias pgadmin Start-PostgreSQLClient
Set-Alias postgresql-start Start-PostgreSQLServer
Set-Alias postgresql-stop Stop-PostgreSQLServer

Export-ModuleMember -Alias mongodb-client
Export-ModuleMember -Alias mongodb-start
Export-ModuleMember -Alias mongodb-stopy

Export-ModuleMember -Alias mssql-start
Export-ModuleMember -Alias mssql-stop

Export-ModuleMember -Alias mysql-client
Export-ModuleMember -Alias mysql-start
Export-ModuleMember -Alias msql-stop

Export-ModuleMember -Alias pgadmin
Export-ModuleMember -Alias postgresql-start
Export-ModuleMember -Alias postgresql-stop
