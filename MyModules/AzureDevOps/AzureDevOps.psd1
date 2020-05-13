@{
    ModuleVersion = '2020.5.10.1'
    GUID = '563f363a-2b2d-4ae5-b7f0-eddaf6087ca4'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'AzureDevOps.psm1'
    NestedModules = @(
        "AzureDevOpsProjects.psm1"
        "AzureDevOpsWorkItems.psm1"
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Clear-AzureDevOpsDefaultProject"
        "Clear-AzureDevOpsProfile"
        "Get-AdoProcessTemplate"
        "Get-AdoProcessTemplates"
        "Get-AdoProject"
        "Get-AdoProjectProperties"
        "Get-AdoProjects"
        "Get-AdoWorkItem"
        "Import-AzureDevOpsProfile"
        "Invoke-AzureDevOpsApi"
        "New-AdoBug"
        "New-AdoProject"
        "New-AdoTask"
        "New-AdoWorkItem"
        "New-AdoUserStory"
        "Set-AzureDevOpsDefaultProject"
        "Set-AzureDevOpsProfile"
        "Test-AzureDevOpsProfile"
        "Test-AzureDevOpsDefaultProject"
        "Use-AzureDevOpsProfile"
    )
    AliasesToExport = @(
        "Load-AzureDevOpsProfile"
        "adoapi"
        "ado-bug"
        "ado-profile-clear"
        "ado-profile-load"
        "ado-task"
        "ado-userstory"
        "azuredevops-api"
        "azuredevops-profile-clear"
        "azuredevops-profile-load"
    )
}
