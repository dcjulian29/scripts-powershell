Function Find-SqlBinaries {
    $paths = @(
        "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Binn"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            $path
            return
        }
    }

}

Function Invoke-SqlCommand {
    & $(Find-SqlBinaries) $args
}

##############################################################################

Export-ModuleMember Invoke-SqlCommand

Set-Alias sqlcmd Invoke-SqlCommand

Export-ModuleMember -Alias sqlcmd
