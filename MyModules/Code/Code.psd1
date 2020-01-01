@{
    ModuleVersion = '2019.12.19.1'
    GUID = '6aa69e5b-f92d-41ba-947b-7840504d31da'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Code.psm1'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Get-DefaultCodeFolder"
        "Import-DevelopmentPowerShellModules"
        "New-CodeFolder"
        "Show-CodeStatus"
        "Update-CodeFolder"
    )
    AliasesToExport = @()
}
