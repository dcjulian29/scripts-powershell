@{
    ModuleVersion = '2020.5.19.1'
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
        "Add-AdoWorkItemComment"
        "Clear-AzureDevOpsDefaultProject"
        "Clear-AzureDevOpsProfile"
        "Get-AdoProcessTemplate"
        "Get-AdoProcessTemplates"
        "Get-AdoProject"
        "Get-AdoProjectProperties"
        "Get-AdoProjects"
        "Get-AdoWorkItem"
        "Get-AzureDevOpsDefaultProject"
        "Get-AzureDevOpsProfile"
        "Get-AzureDevOpsProjectProcess"
        "Import-AzureDevOpsProfile"
        "Invoke-AzureDevOpsApi"
        "Join-AdoWorkItem"
        "Join-AdoWorkItemAsChild"
        "Join-AdoWorkItemAsParent"
        "New-AdoBug"
        "New-AdoIssue"
        "New-AdoProject"
        "New-AdoTask"
        "New-AdoWorkItem"
        "New-AdoUserStory"
        "Set-AzureDevOpsDefaultProject"
        "Set-AzureDevOpsProfile"
        "Set-AdoWorkItemState"
        "Test-AzureDevOpsDefaultProject"
        "Test-AzureDevOpsProfile"
        "Use-AzureDevOpsProfile"
    )
    AliasesToExport = @(
        "adoapi"
        "ado-bug"
        "ado-comment"
        "ado-issue"
        "ado-profile-clear"
        "ado-profile-load"
        "ado-task"
        "ado-userstory"
        "azuredevops-api"
        "azuredevops-profile-clear"
        "azuredevops-profile-load"
        "Load-AzureDevOpsProfile"
    )
}
