function Get-AdoProcessTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    Invoke-AzureDevOpsApi "process/processes/$Id"
}

function Get-AdoProcessTemplates {
    (Invoke-AzureDevOpsApi "process/processes").value
}

function Get-AdoProject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    Invoke-AzureDevOpsApi "projects/$Id"
}

function Get-AdoProjectProperties {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    (Invoke-AzureDevOpsApi "projects/$Id/properties" -Version "5.1-preview.1").value
}

function Get-AdoProjects {
    (Invoke-AzureDevOpsApi "projects/$Id").value
}

function New-AdoProject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Name,
        [Parameter(Mandatory = $true)]
        [string] $ProcessId,
        [string] $Description
    )

    $configuration = @{
            "name" = "$Name"
            "description" = "$Description"
            "ProjectVisibility" = "private"
            "capabilities" = @{
                "versioncontrol" = @{
                    "sourceControlType" = "Git"
                }
                "processTemplate" = @{
                    "templateTypeId" = "$ProcessId"
                }
            }
    }  | ConvertTo-Json -Depth 5

    Invoke-AzureDevOpsApi "projects" -HttpMethod "POST" -Body $configuration
}
