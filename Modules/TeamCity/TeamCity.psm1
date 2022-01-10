function Clear-TeamCityProfile {
    Remove-Item env:TeamCityURL
    Remove-Item env:TeamCityToken
}

Set-Alias teamcity-profile-clear Clear-TeamCityProfile

function Get-TeamCityBackup {
    Invoke-TeamCityApi "server/backup" -AcceptType "text/plain"
}

function Get-TeamCityServerLicense {
    $info = Invoke-TeamCityApi "server/licensingData"

    if ($info) {
        $detail = New-Object PSObject
        $detail | Add-Member -Type NoteProperty -Name 'MaximumAgents' -Value $info.maxAgents
        $detail | Add-Member -Type NoteProperty -Name 'AvailableAgents' -Value $info.agentsLeft

        if ($info.unlimitedBuildTypes) {
            $detail | Add-Member -Type NoteProperty -Name 'MaximumBuildConfigurations' `
                -Value "unlimited"
        } else {
            $detail | Add-Member -Type NoteProperty -Name 'MaximumBuildConfigurations' `
                -Value $info.maxBuildTypes
            $detail | Add-Member -Type NoteProperty -Name 'AvailableBuildConfigurations' `
                -Value $info.buildTypesLeft
        }

        $detail | Add-Member -Type NoteProperty -Name 'LicenseType' -Value $info.serverLicenseType

        return $detail
    }
}

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
        [string] $HttpMethod = "GET",
        [string] $BodyType = "application/xml",
        [string] $AcceptType = "application/json"
    )

    Use-TeamCityProfile

    $header = @{
        "Authorization" = "Bearer $env:TeamCityToken"
        "Accept" = $AcceptType
    }

    $uri = "$env:TeamCityUrl/app/rest/$Method"

    if ($HttpMethod -ne "GET") {
        $header.Add("Content-Type", $BodyType)
        $response = Invoke-WebRequest -Uri $uri -Method $HttpMethod -Header $header -Body $Body
    } else {
        $response = Invoke-WebRequest -Uri $uri -Method $HttpMethod -Header $header
    }

    if ($response) {
        switch ($AcceptType) {
            "application/json" { $response = $response | ConvertFrom-Json }
            default { $response = $response.Content }
        }

        return $response
    }
}

Set-Alias teamcityapi Invoke-TeamCityApi
Set-Alias teamcity-api Invoke-TeamCityApi

function Invoke-TeamCityBackup {
    [CmdletBinding()]
    param (
        [string] $FileName = "TeamCity_Backup",
        [string] $AddTimestamp = $true,
        [string] $IncludeConfigs = $true,
        [string] $IncludeDatabase = $true,
        [string] $IncludeBuildLogs = $false,
        [string] $IncludePersonalChanges = $false
    )

    $param = ("addTimestamp={1}&includeConfigs={2}&includeDatabase={3}" `
        + "&includeBuildLogs={4}&includePersonalChanges={5}&fileName={0}") `
        -f `
            $FileName,
            $AddTimestamp,
            $IncludeConfigs,
            $IncludeDatabase,
            $IncludeBuildLogs,
            $IncludePersonalChanges

    Invoke-TeamCityApi -Method "server/backup?$param" -HttpMethod POST -AcceptType "text/plain"
}

Set-Alias -Name Backup-TeamCity -Value Invoke-TeamCityBackup

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
