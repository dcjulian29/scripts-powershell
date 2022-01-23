@{
    RootModule = 'PowerShell.psm1'
    ModuleVersion = '2201.17.1'
    GUID = 'f7824b54-f08e-415c-b661-c4605dda0603'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Edit-Profile"
        "Get-AvailableExceptionsList"
        "Get-LastExecutionTime"
        "Get-PowerShellVerbs"
        "Get-PowerShellVerbs"
        "Get-Profile"
        "Import-Assembly"
        "Initialize-PSGallery"
        "New-ErrorRecord"
        "Remove-AliasesFromScript"
        "Restart-Module"
        "Search-Command"
        "Test-IsNonInteractive"
        "Test-PowerShellVerb"
        "Update-AllPowershellModules"
        "Update-MyPowershellModules"
        "Update-PowershellModules"
        "Update-PreCompiledAssemblies"
        "Update-Profile"
    )
    AliasesToExport = @(
        "Find-PSCommand"
        "Load-Assembly"
        "Reload-Module"
        "Reload-Profile"
    )
}
