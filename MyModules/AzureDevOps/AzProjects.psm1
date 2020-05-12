function Get-AzProcessTemplate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    Invoke-AzureDevOpsApi "process/processes/$Id"
}

function Get-AzProcessTemplates {
    (Invoke-AzureDevOpsApi "process/processes").value
}

function Get-AzProject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    Invoke-AzureDevOpsApi "projects/$Id"
}

function Get-AzProjectProperties {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    (Invoke-AzureDevOpsApi "projects/$Id/properties" -Version "5.1-preview.1").value
}

function Get-AzProjects {
    (Invoke-AzureDevOpsApi "projects/$Id").value
}

function New-AzProject {
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
