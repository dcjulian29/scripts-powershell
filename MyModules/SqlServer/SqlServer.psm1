Function Find-SqlBinaries {
    First-Path `
        (Find-ProgramFiles 'Microsoft SQL Server\ClientSDK\ODBC\130\Tool\Binn') `
        (Find-ProgramFiles 'Microsoft SQL Server\120\Tools\Binn') `
        (Find-ProgramFiles 'Microsoft SQL Server\110\Tools\Binn')
}

Function Invoke-SqlCommand {
    Start-Process -FilePath "$(Find-SqlBinaries)\sqlcmd.exe" `
        -ArgumentList $args -NoNewWindow -Wait
}

Function Start-MSSqlServer {
    & sc.exe start MSSQLSERVER
}

Function Stop-MSSqlServer {
    & sc.exe stop MSSQLSERVER
}

##############################################################################

Export-ModuleMember Invoke-SqlCommand
Export-ModuleMember Start-MSSqlServer
Export-ModuleMember Stop-MSSqlServer

Set-Alias sqlcmd Invoke-SqlCommand
Set-Alias mssql-start Start-MSSqlServer
Set-Alias mssql-stop Stop-MSSqlServer

Export-ModuleMember -Alias sqlcmd
Export-ModuleMember -Alias mssql-start
Export-ModuleMember -Alias mssql-stop
