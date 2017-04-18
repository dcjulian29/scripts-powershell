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
    & "$env:ChocolateyInstall\bin\octo.exe" $args
}

Function Create-OctopusRelease {
    param(
        [Parameter(Mandatory = $true)]
        [String]$Project,
        [String]$Version,
        [String]$PackageVersion
    )

    $profile = Get-OctopusProfileArguments

    $parameters = "--project $Project"

    if ($Version) {
        $parameters += " --version $Version"
    }

    if ($PackageVersion) {
        $parameters += " --packageversion $PackageVersion"
    }

    if ($profile) {
        $parameters += " $profile"
        Invoke-Octopus create-release $parameters
    }
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

    $profile = Get-OctopusProfileArguments

    $parameters = "--project $Project"

    $parameters += " --releaseNumber $Version"

    $parameters += " --deployto $Environment"

    if ($profile) {
        $parameters += " $profile"
        Invoke-Octopus deploy-release --progress $parameters
    }
}

Function Push-OctopusPackage {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ })]
        [String]$Package
    )

    $profile = Get-OctopusProfileArguments

    if ($profile) {
        $parameters = "--package $Package $profile"
        Invoke-Octopus push $parameters
    }
}

###################################################################################################

Export-ModuleMember Clear-OctopusProfile
Export-ModuleMember Load-OctopusProfile
Export-ModuleMember Invoke-Octopus
Export-ModuleMember Create-OctopusRelease
Export-ModuleMember Deploy-OctopusRelease
Export-ModuleMember Push-OctopusPackage

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
