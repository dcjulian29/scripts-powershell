Function Find-SqlBinaries {
    First-Path `
        (Find-ProgramFiles 'Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Binn') `
        (Find-ProgramFiles 'Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Binn')
}

Function Invoke-SqlCommand {
    & $(Find-SqlBinaries) $args
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
