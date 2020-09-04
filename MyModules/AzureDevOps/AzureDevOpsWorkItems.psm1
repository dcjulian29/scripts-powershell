function Add-AdoWorkItemComment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int] $Id,
        [Parameter(Mandatory = $true)]
        [string] $Comment,
        [string] $Project
    )

    if (-not $Project) {
        if (Test-AzureDevOpsDefaultProject) {
            $Project = $env:AzureDevOpsProject
        } else {
            throw "Azure DevOps project was not provided and a default one is not set!"
        }
    }

    $json = @"
[
  {
    "op": "add",
    "path": "/fields/System.History",
    "value": "$Comment"
  }
]
"@

    Invoke-AzureDevOpsApi "wit/workitems/$Id" -PrefixProject -Project $Project `
        -HttpMethod PATCH -Body $json -BodyType "application/json-patch+json"
}

Set-Alias -Name ado-comment -Value Add-WorkItemComment

function Get-AdoWorkItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int] $Id,
        [string] $Project
    )

    if (-not $Project) {
        if (Test-AzureDevOpsDefaultProject) {
            $Project = $env:AzureDevOpsProject
        } else {
            throw "Azure DevOps project was not provided and a default one is not set!"
        }
    }

    Invoke-AzureDevOpsApi "wit/workitems/$Id" -PrefixProject -Project $Project
}

function Join-AdoWorkItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int] $Id,
        [Parameter(Mandatory = $true)]
        [int] $LinkedId,
        [ValidateSet("Parent", "Child", "Related")]
        [string] $LinkType = "Related",
        [string] $Project
    )

    if (-not $Project) {
        if (Test-AzureDevOpsDefaultProject) {
            $Project = $env:AzureDevOpsProject
        } else {
            throw "Azure DevOps project was not provided and a default one is not set!"
        }
    }

    switch ($LinkType) {
        "Parent" { $link = "System.LinkTypes.Hierarchy-Forward" }
        "Child" { $link = "System.LinkTypes.Hierarchy-Reverse" }
        Default { $link = "System.LinkTypes.Related" }
    }

    $json = @"
[
  {
    "op": "add",
    "path": "/relations/-",
    "value": {
      "rel": "$link",
      "url": "https://dev.azure.com/$Project/_apis/wit/workItems/$LinkedId"
    }
  }
]
"@

    Invoke-AzureDevOpsApi "wit/workitems/$Id" -PrefixProject -Project $Project `
        -HttpMethod PATCH -Body $json -BodyType "application/json-patch+json"
}

function Join-AdoWorkItemAsChild {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [int] $Id,
        [Parameter(Mandatory = $true, Position = 1)]
        [int] $ParentId,
        [string] $Project
    )

    Join-AdoWorkItem -Id $Id -LinkedId $ParentId -LinkType Child -Project $Project
}

function Join-AdoWorkItemAsParent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [int] $Id,
        [Parameter(Mandatory = $true, Position = 1)]
        [int] $ChildId,
        [string] $Project
    )

    Join-AdoWorkItem -Id $Id -LinkedId $ChildId -LinkType Parent -Project $Project
}

function New-AdoBug {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Title,
        [string] $Description,
        [string] $AssignedTo,
        [string] $AreaPath,
        [string] $Project
    )

    New-AdoWorkItem @PsBoundParameters -WorkItemType "Bug"
}

Set-Alias -Name ado-bug -Value New-AdoBug

function New-AdoIssue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Title,
        [string] $Description,
        [string] $AssignedTo,
        [string] $AreaPath,
        [string] $Project
    )

    New-AdoWorkItem @PsBoundParameters -WorkItemType "Issue"
}

Set-Alias -Name ado-issue -Value New-AdoIssue

function New-AdoTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Title,
        [string] $Description,
        [string] $AssignedTo,
        [string] $AreaPath,
        [string] $Project
    )

    New-AdoWorkItem @PsBoundParameters -WorkItemType "Task"
}

Set-Alias -Name ado-task -Value New-AdoTask

function New-AdoWorkItem {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Title,
        [string] $Description,
        [string] $AssignedTo,
        [string] $AreaPath,
        [string] $Project,
        [Parameter(Mandatory = $true)]
        [string] $WorkItemType
    )

    if (-not $Project) {
        if (Test-AzureDevOpsDefaultProject) {
            $Project = $env:AzureDevOpsProject
        } else {
            throw "Azure DevOps project was not provided and a default one is not set!"
        }
    }

    $type = (Invoke-AzureDevOpsApi "wit/workitemtypes" -PrefixProject -Project $Project).value.name `
        | Where-Object { $_ -eq $WorkItemType }

    if (-not $type) {
        throw "$WorkItemType doesn't exist for the project "
    }


    $json = "["
    $json += "{`"op`": `"add`", `"path`": `"/fields/System.Title`", `"from`": null, `"value`": `"$Title`"}"

    if ($Description) {
        $json += ",{`"op`": `"add`", `"path`": `"/fields/System.Description`", " `
            + "`"from`": null, `"value`": `"$Description`"}"
    }

    if ($AssignedTo) {
        $json += ",{`"op`": `"add`", `"path`": `"/fields/System.AssignedTo`", " `
            + "`"from`": null, `"value`": `"$AssignedTo`"}"
    }

    if ($AreaPath) {
        $path = $AreaPath.Replace("\", "\\")
        $json += ",{`"op`": `"add`", `"path`": `"/fields/System.AreaPath`", " `
            + "`"from`": null, `"value`": `"$path`"}"
    }

    $json += "]"

    Invoke-AzureDevOpsApi "wit/workitems/`$$type" -PrefixProject -Project $Project `
        -HttpMethod POST -Body $json -BodyType "application/json-patch+json"
}

function New-AdoUserStory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Title,
        [string] $Description,
        [string] $AssignedTo,
        [string] $AreaPath,
        [string] $Project
    )

    New-AdoWorkItem @PsBoundParameters -WorkItemType "UserStory"
}

Set-Alias -Name ado-userstory -Value New-AdoUserStory

function Set-AdoWorkItemState {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Id,
        [Parameter(Mandatory = $true)]
        [string] $State,
        [string] $Project
    )

    if (-not $Project) {
        if (Test-AzureDevOpsDefaultProject) {
            $Project = $env:AzureDevOpsProject
        } else {
            throw "Azure DevOps project was not provided and a default one is not set!"
        }
    }

    $item = Get-AdoWorkItem -Id $Id -Project $Project
    $type = $item.fields.'System.WorkItemType'

    $stateName = (Invoke-AzureDevOpsApi "wit/workitemtypes/$type/states" `
        -PrefixProject -Project $Project -Version "5.1-preview.1").value.name `
        | Where-Object { $_ -eq $State }

    if (-not $stateName) {
        throw "$State is not a valid state for this work item."
    }

    $json = @"
[
  {
    "op": "add",
    "path": "/fields/System.State",
    "from": null,
    "value": "$State"
  }
]
"@

    Invoke-AzureDevOpsApi "wit/workitems/$Id" -PrefixProject -Project $Project `
        -HttpMethod PATCH -Body $json -BodyType "application/json-patch+json"
}
