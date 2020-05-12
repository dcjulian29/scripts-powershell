@{
    ModuleVersion = '2020.5.10.1'
    GUID = '563f363a-2b2d-4ae5-b7f0-eddaf6087ca4'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'AzureDevOps.psm1'
    NestedModules = @(
        "AzProjects.psm1"
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Clear-AzureDevOpsProfile"
        "Get-AzProcessTemplate"
        "Get-AzProcessTemplates"
        "Get-AzProject"
        "Get-AzProjectProperties"
        "Get-AzProjects"
        "Import-AzureDevOpsProfile"
        "Invoke-AzureDevOpsApi"
        "New-AzProject"
        "Set-AzureDevOpsProfile"
        "Test-AzureDevOpsProfile"
        "Use-AzureDevOpsProfile"
    )
    AliasesToExport = @(
        "Load-AzureDevOpsProfile"
        "adoapi"
        "azuredevops-api"
        "azuredevops-profile-clear"
        "ado-profile-clear"
        "azuredevops-profile-load"
        "ado-profile-load"
    )
}
