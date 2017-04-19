$script:OctopusUrl = ''
$script:OctopusApi = ''

Function Get-OctopusProfileArguments {
    if ($script:OctopusUrl -eq '') {
        Write-Error "Octopus Profile is not loaded"
        return
    }

    "--server $($script:OctopusUrl) --apiKey $($script:OctopusApi)"
}

Function Clear-OctopusProfile {
    $script:OctopusUrl = ''
    $script:OctopusApi = ''
}

Function Load-OctopusProfile {
    param (
        [string]$ProfileName = $(Read-Host "Enter the Octopus Profile")
    )
    
    $profileFile = Join-Path -Path "$($env:SystemDrive)/etc/octopus" -ChildPath "$ProfileName.json"

    if (-not (Test-Path $profileFile)) {
        Write-Error "Octopus Profile does not exist!"
    } else {
        $json = Get-Content -Raw -Path $profileFile | ConvertFrom-Json

        $script:OctopusUrl = $json.Url
        $script:OctopusApi = $json.Api
    }
}

Function Invoke-Octopus {
    Start-Process -FilePath "$env:ChocolateyInstall\bin\octo.exe" `
        -ArgumentList $args -NoNewWindow -Wait
}

Function Create-OctopusRelease {
    param(
        [Parameter(Mandatory = $true)]
        [String]$Project,
        [String]$Version,
        [String]$PackageVersion
    )

    $parameters = "$(Get-OctopusProfileArguments) --project $Project"

    if ($Version) {
        $parameters += " --version $Version"
    }

    if ($PackageVersion) {
        $parameters += " --packageversion $PackageVersion"
    }

    Invoke-Octopus create-release $parameters
}

Function Deploy-OctopusRelease {
    param(
        [Parameter(Mandatory = $true)]
        [String]$Project,
        [Parameter(Mandatory = $true)]
        [String]$Version,
        [Parameter(Mandatory = $true)]
        [String]$Environment
    )

    $parameters = "$(Get-OctopusProfileArguments) --project $Project"

    $parameters += " --releaseNumber $Version"

    $parameters += " --deployto $Environment"

    Invoke-Octopus deploy-release --progress $parameters
}

Function Push-OctopusPackage {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ })]
        [String]$Package
    )

    $parameters = "push $(Get-OctopusProfileArguments) --package $Package"
    $parameters
    Invoke-Octopus $parameters
}

Function Make-OctopusPackage {
    Param (
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $NuspecFile = "package.nuspec"
    )

    $nuget = "C:\ProgramData\chocolatey\lib\NuGet.CommandLine\tools\nuget.exe"
    $options = "-NoPackageAnalysis -NonInteractive -NoDefaultExcludes"

    Invoke-Expression "$nuget pack ""$NuspecFile"" $options"
}

###################################################################################################

Export-ModuleMember Clear-OctopusProfile
Export-ModuleMember Load-OctopusProfile
Export-ModuleMember Invoke-Octopus
Export-ModuleMember Create-OctopusRelease
Export-ModuleMember Deploy-OctopusRelease
Export-ModuleMember Push-OctopusPackage
Export-ModuleMember Make-OctopusPackage

Set-Alias octopus-profile-clear Clear-OctopusProfile
Export-ModuleMember -Alias octopus-profile-clear

Set-Alias octopus-profile-load Load-OctopusProfile
Export-ModuleMember -Alias octopus-profile-load

Set-Alias octopus Invoke-Octopus
Export-ModuleMember -Alias octopus

Set-Alias octo Invoke-Octopus
Export-ModuleMember -Alias octo

Set-Alias octopus-release-create Create-OctopusRelease
Export-ModuleMember -Alias octopus-release-create

Set-Alias octopus-release-deploy Deploy-OctopusRelease
Export-ModuleMember -Alias octopus-release-deploy

Set-Alias octopus-publish Push-OctopusPackage
Export-ModuleMember -Alias octopus-publish
