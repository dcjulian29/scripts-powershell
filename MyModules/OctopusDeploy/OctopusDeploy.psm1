function getOctoProfileArguments {
    if ($env:OctopusUrl -eq '') {
        Write-Error "Octopus Profile is not loaded"
        return
    }

    "--server $env:OctopusURL --apiKey $env:OctopusAPIKey"
}

###############################################################################

function Clear-OctopusProfile {
    Remove-Item $env:OctopusURL
    Remove-Item $env:OctopusAPIKey
}

Set-Alias octopus-profile-clear Clear-OctopusProfile
Set-Alias octo-profile-clear Clear-OctopusProfile

function Find-Octo {
    $octo = First-Path `
        "$env:ChocolateyInstall\lib\OctopusTools\tools\octo.exe" `
        "$env:ChocolateyInstall\bin\octo.exe"

    if (Test-Path -Path $octo) {
        $octo
    }
}

function Import-OctopusProfile {
    param (
        [string]$ProfileName = $(Read-Host "Enter the Octopus Profile")
    )

    $profileFile = Join-Path -Path "$($env:SystemDrive)/etc/octopus" -ChildPath "$ProfileName.json"

    if (-not (Test-Path $profileFile)) {
        Write-Error "Octopus Profile does not exist!"
    } else {
        $json = Get-Content -Raw -Path $profileFile | ConvertFrom-Json

        $env:OctopusURL = $json.Url
        $env:OctopusAPIKey = $json.Api
    }
}

Set-Alias -Name Load-OctopusProfile -Value Import-OctopusProfile
Set-Alias -Name octo-profile-load -Value Import-OctopusProfile
Set-Alias -Name octopus-profile-load -Value Import-OctopusProfile

function Invoke-DeployOctopusRelease {
    param(
        [Parameter(Mandatory = $true)]
        [String]$Project,
        [Parameter(Mandatory = $true)]
        [String]$Version,
        [Parameter(Mandatory = $true)]
        [String]$Environment
    )

    $parameters = "$(getOctoProfileArguments) --project $Project"

    $parameters += " --releaseNumber $Version"

    $parameters += " --deployto $Environment"

    Invoke-Octo deploy-release --progress $parameters
}

Set-Alias -Name Deploy-OctopusRelease -Value Invoke-DeployOctopusRelease
Set-Alias -Name octo-release-deploy -Value Invoke-DeployOctopusRelease
Set-Alias -Name octopus-release-deploy -Value Invoke-DeployOctopusRelease

function Invoke-Octo {
    Start-Process -FilePath $(Find-Octo) -ArgumentList $args -NoNewWindow -Wait
}

Set-Alias octopus Invoke-Octopus
Set-Alias octo Invoke-Octopus

function Invoke-OctopusApi {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Method,
        [string] $Body,
        [ValidateSet("GET", "POST", "PUT", "DELETE")]
        [string] $HttpMethod = "GET"
    )

    Use-OctopusProfile

    $header = @{
        "X-Octopus-ApiKey" = $env:OctopusAPIKey
        "Accept" = "application/json"
    }

    $uri = "$env:OctopusUrl/api/$Method"

    if ($HttpMethod -ne "GET") {
        $response = Invoke-WebRequest -Uri $uri -Method $HttpMethod -Header $header -Body $Body
    } else {
        $response = Invoke-WebRequest -Uri $uri -Method $HttpMethod -Header $header
    }

    if ($response) {
        $response = $response | ConvertFrom-Json

        return $response
    }
}

Set-Alias octoapi Invoke-OctopusApi
Set-Alias octopusapi Invoke-OctopusApi
Set-Alias octopus-api Invoke-OctopusApi

function New-OctopusPackage {
    Param (
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $NuspecFile = "package.nuspec"
    )

    Invoke-Nuget pack "$NuspecFile" -NoPackageAnalysis `
        -NonInteractive -NoDefaultExcludes -Verbosity detailed
}

function New-OctopusRelease {
    param(
        [Parameter(Mandatory = $true)]
        [String]$Project,
        [String]$Version,
        [String]$PackageVersion
    )

    $parameters = "$(getOctoProfileArguments) --project $Project"

    if ($Version) {
        $parameters += " --version $Version"
    }

    if ($PackageVersion) {
        $parameters += " --packageversion $PackageVersion"
    }

    Invoke-Octo create-release $parameters
}

Set-Alias -Name Create-OctopusRelease -Value New-OctopusRelease
Set-Alias -Name octo-release-create -Value New-OctopusRelease
Set-Alias -Name octopus-release-create -Value New-OctopusRelease

function Push-OctopusPackage {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ })]
        [String]$Package
    )

    $parameters = "push $(getOctoProfileArguments) --package $Package"

    Invoke-Octo $parameters
}

Set-Alias octo-publish Push-OctopusPackage
Set-Alias octopus-publish Push-OctopusPackage

function Set-OctopusProfile {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Url,
        [Parameter(Mandatory = $true)]
        [string] $ApiKey
    )

    $env:OctopusURL = $Url
    $env:OctopusAPIKey = $ApiKey
}

function Test-OctopusProfile {
    return ((Test-Path env:OctopusURL) -and (Test-Path env:OctopusAPIKey))
}

function Use-OctopusProfile {
    if (-not (Test-OctopusProfile)) {
        throw "Octopus Profile is not loaded or set"
    }
}
