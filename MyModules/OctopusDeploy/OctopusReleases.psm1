function Get-OctopusRelease {
    param (
        [Parameter(Mandatory = $true)]
        [string] $ProjectName,
        [Parameter(Mandatory = $true)]
        [string] $Version
    )

    $releases = Get-OctopusReleases -ProjectName $ProjectName

    return $releases | Where-Object { $_.Version -eq $Version}
}

function Get-OctopusReleaseById {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    Invoke-OctopusApi "releases/$Id"
}

function Get-OctopusReleases {
    param (
        [Parameter(Mandatory = $true)]
        [string] $ProjectName,
        [int] $Skip = 0,
        [int] $Take
    )

    $project = Get-OctopusProject -Name $ProjectName

    if (-not $project) {
        throw "Octopus project '$ProjectName' doesn't exist"
    }

    $projectId = $project.Id

    if ($Take) {
        (Invoke-OctopusApi "projects/$projectId/releases?skip=$Skip&take=$Take").Items
    }

    $releases = Invoke-OctopusApi "projects/$projectId/releases"

    if (-not $releases) {
        throw "Octopus project '$ProjectName' doesn't contain any releases"
    }

    $total = $releases.TotalResults

    (Invoke-OctopusApi "projects/$projectId/releases?skip=$Skip&take=$total").Items
}

function Get-OctopusReleasesForProjectInEnvironment {
    param (
        [Parameter(Mandatory = $true)]
        [string] $ProjectName,
        [Parameter(Mandatory = $true)]
        [string] $Environment
    )

    $projectId = (Get-OctopusProject -ProjectName $ProjectName).Id
    $environmentId = (Get-OctopusEnvironment -Name $Environment).Id

    $deployments = (Invoke-OctopusApi "deployments?environments=$environmentId&skip=0&take=100000").Items

    $deployments = $deployments | Where-Object { $_.ProjectId -eq $projectId }

    return $deployments
}
