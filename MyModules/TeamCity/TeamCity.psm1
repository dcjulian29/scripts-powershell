function Clear-TeamCityProfile {
    Remove-Item $env:TeamCityURL
    Remove-Item $env:TeamCityToken
}

Set-Alias teamcity-profile-clear Clear-TeamCityProfile

function Get-TeamCityServerUptime {
    $info = Invoke-TeamCityApi "server"

    if ($info) {

        $currentTime = [DateTime]::ParseExact($info.currentTime, 'yyyyMMddTHHmmssK', $null)
        $startTime = [DateTime]::ParseExact($info.startTime, 'yyyyMMddTHHmmssK', $null)

        return ($currentTime - $startTime).ToString()
    }
}

function Get-TeamCityServerVersion {
    $info = Invoke-TeamCityApi "server"

    if ($info) {
        return $info.Version
    }
}

function Import-TeamCityProfile {
    param (
        [string]$ProfileName = $(Read-Host "Enter the TeamCity Profile")
    )

    $profileFile = Join-Path -Path "$($env:SystemDrive)/etc/teamcity" -ChildPath "$ProfileName.json"

    if (-not (Test-Path $profileFile)) {
        Write-Error "TeamCity Profile does not exist!"
    } else {
        $json = Get-Content -Raw -Path $profileFile | ConvertFrom-Json

        $env:TeamCityURL = $json.Url
        $env:TeamCityToken = $json.Token
    }
}

Set-Alias -Name Load-TeamCityProfile -Value Import-TeamCityProfile
Set-Alias -Name teamcity-profile-load -Value Import-TeamCityProfile

function Invoke-TeamCityApi {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Method,
        [string] $Body,
        [ValidateSet("GET", "POST", "PUT", "DELETE")]
        [string] $HttpMethod = "GET"
    )

    Use-TeamCityProfile

    $header = @{
        "Authorization" = "Bearer $env:TeamCityToken"
        "Accept" = "application/json"
    }

    $uri = "$env:TeamCityUrl/app/rest/$Method"

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

Set-Alias teamcityapi Invoke-TeamCityApi
Set-Alias teamcity-api Invoke-TeamCityApi

function Set-TeamCityProfile {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Url,
        [Parameter(Mandatory = $true)]
        [string] $ApiKey
    )

    $env:TeamCityURL = $Url
    $env:TeamCityToken = $ApiKey
}

function Test-TeamCityProfile {
    return ((Test-Path env:TeamCityURL) -and (Test-Path env:TeamCityToken))
}

function Use-TeamCityProfile {
    if (-not (Test-TeamCityProfile)) {
        throw "TeamCity Profile is not loaded or set"
    }
}
