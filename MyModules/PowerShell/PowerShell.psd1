@{
    RootModule = 'PowerShell.psm1'
    ModuleVersion = '2020.7.5.1'
    GUID = 'f7824b54-f08e-415c-b661-c4605dda0603'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Edit-Profile"
        "Get-LastExecutionTime"
        "Get-PowerShellVerbs"
        "Get-PowerShellVerbs"
        "Get-Profile"
        "Import-Assembly"
        "Search-Command"
        "Test-IsNonInteractive"
        "Test-PowerShellVerb"
        "Update-Profile"
    )
    AliasesToExport = @(
        "Find-PSCommand"
        "Load-Assembly"
        "Reload-Profile"
    )
}
