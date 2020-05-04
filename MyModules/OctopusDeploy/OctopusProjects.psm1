function Get-OctopusProjects {
    Invoke-OctopusApi "projects/all"
}

function Get-OctopusProject {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Name
    )

    $projects = Get-OctopusProjects

    return $projects | Where-Object { $_.Name -eq $Name}
}
