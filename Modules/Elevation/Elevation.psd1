@{
    ModuleVersion = '2204.19.1'
    GUID = 'd4e9a80b-2239-4d7a-a552-b46e17a47863'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Elevation.psm1'
    NestedModules = @()
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
      "Assert-Elevation"
      "Test-Elevation"
      "Invoke-ElevatedCommand"
      "Invoke-ElevatedCommandAs"
      "Invoke-ElevatedScript"
      "Invoke-ElevatedExpression"
      "Start-RemoteProcess"
    )
    AliasesToExport = @(
      "sudo"
      "runas"
    )
}
