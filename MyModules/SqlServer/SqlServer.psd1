@{
    RootModule = 'SqlServer.psm1'
    ModuleVersion = '2020.1.2.1'
    GUID = 'd55983c8-b268-42a7-b59a-d4396054f223'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Find-SqlCmd"
        "Invoke-SqlCmd"
        "Invoke-SqlFile"
        "Register-SqlCmdSqlCredentials"
    )
}
