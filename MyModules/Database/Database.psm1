function Find-MSSqlBinaries {
    First-Path `
        (Find-ProgramFiles 'Microsoft SQL Server\ClientSDK\ODBC\140\Tool\Binn') `
        (Find-ProgramFiles 'Microsoft SQL Server\ClientSDK\ODBC\130\Tool\Binn') `
        (Find-ProgramFiles 'Microsoft SQL Server\120\Tools\Binn') `
        (Find-ProgramFiles 'Microsoft SQL Server\110\Tools\Binn')
}

##############################################################################

function Invoke-MSSqlCommand {
    Start-Process -FilePath "$(Find-MSSqlBinaries)\sqlcmd.exe" `
        -ArgumentList $args -NoNewWindow -Wait
}

function Start-MSSqlServer {
    & sc.exe start MSSQLSERVER
}

function Stop-MSSqlServer {
    & sc.exe stop MSSQLSERVER
}

##############################################################################

Export-ModuleMember Invoke-MSSqlCommand

Export-ModuleMember Start-MSSqlServer

Export-ModuleMember Stop-MSSqlServer

Set-Alias mssql-start Start-MSSqlServer
Set-Alias mssql-stop Stop-MSSqlServer

Export-ModuleMember -Alias mssql-start
Export-ModuleMember -Alias mssql-stop
