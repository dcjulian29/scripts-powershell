function Get-OctopusEnvironments {
    Invoke-OctopusApi "Environments/all"
}

function Get-OctopusEnvironment {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Name
    )

    $environments = Get-OctopusEnvironments

    return $environments | Where-Object { $_.Name -eq $Name}
}
