@{
    RootModule = 'PowerShell.psm1'
    ModuleVersion = '2020.1.21.1'
    GUID = 'f7824b54-f08e-415c-b661-c4605dda0603'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Edit-Profile"
        "Get-LastExecutionTime"
        "Get-Profile"
        "Import-Assembly"
        "Search-Command"
        "Update-Profile"
    )
    AliasesToExport = @(
        "Find-PSCommand"
        "Load-Assembly"
        "Reload-Profile"
    )
}
