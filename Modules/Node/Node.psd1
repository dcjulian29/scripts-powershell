@{
    ModuleVersion = '2204.19.1'
    GUID = '2c8d7516-d46b-4b08-b9a0-ab87448b8f13'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Node.psm1'
    NestedModules = @()
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
      "Get-NodeVersion"
      "Start-NodePackageManager"
      "Start-Node"
      "Test-Node"
    )
    AliasesToExport = @(
      "npm"
      "node"
    )
}
