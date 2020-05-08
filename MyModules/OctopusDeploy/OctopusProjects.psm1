function Get-OctopusProject {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Name
    )

    $projects = Get-OctopusProjects

    return $projects | Where-Object { $_.Name -eq $Name}
}

function Get-OctopusProjectById {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    Invoke-OctopusApi "projects/$Id"
}

function Get-OctopusProjects {
    Invoke-OctopusApi "projects/all"
}
