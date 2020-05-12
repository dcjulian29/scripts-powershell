function Clear-AzureDevOpsProfile {
    Remove-Item env:AzureDevOpsURL
    Remove-Item env:AzureDevOpsToken
}

Set-Alias azuredevops-profile-clear Clear-AzureDevOpsProfile
Set-Alias ado-profile-clear Clear-AzureDevOpsProfile

function Import-AzureDevOpsProfile {
    param (
        [string]$ProfileName = $(Read-Host "Enter the AzureDevOps Profile")
    )

    $profileFile = Join-Path -Path "$($env:SystemDrive)/etc/azuredevops" -ChildPath "$ProfileName.json"

    if (-not (Test-Path $profileFile)) {
        Write-Error "AzureDevOps Profile does not exist!"
    } else {
        $json = Get-Content -Raw -Path $profileFile | ConvertFrom-Json

        $env:AzureDevOpsURL = $json.Url
        $env:AzureDevOpsToken = $json.Token
    }
}

Set-Alias -Name Load-AzureDevOpsProfile -Value Import-AzureDevOpsProfile
Set-Alias -Name azuredevops-profile-load -Value Import-AzureDevOpsProfile
Set-Alias -Name ado-profile-load -Value Import-AzureDevOpsProfile

function Invoke-AzureDevOpsApi {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Method,
        [string] $Body,
        [ValidateSet("GET", "POST", "PUT", "DELETE")]
        [string] $HttpMethod = "GET",
        [string] $BodyType = "application/json",
        [string] $Version = "5.1"
    )

    Use-AzureDevOpsProfile

    $token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($env:AzureDevOpsToken)"))
    $header = @{
        "Authorization" = "Basic $token"
        "Accept" = "application/json"
    }

    $uri = "$env:AzureDevOpsUrl/_apis/$($Method)?api-version=$Version"

    if ($HttpMethod -ne "GET") {
        $header.Add("Content-Type", $BodyType)
        $response = Invoke-WebRequest -Uri $uri -Method $HttpMethod -Header $header -Body $Body
    } else {
        $response = Invoke-WebRequest -Uri $uri -Method $HttpMethod -Header $header
    }

    if ($response) {
        $response = $response | ConvertFrom-Json

        return $response
    }
}

Set-Alias adoapi Invoke-AzureDevOpsApi
Set-Alias azuredevops-api Invoke-AzureDevOpsApi

function Set-AzureDevOpsProfile {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Url,
        [Parameter(Mandatory = $true)]
        [string] $Token
    )

    $env:AzureDevOpsURL = $Url
    $env:AzureDevOpsToken = $Token
}

function Test-AzureDevOpsProfile {
    return ((Test-Path env:AzureDevOpsURL) `
        -and (Test-Path env:AzureDevOpsToken))
}

function Use-AzureDevOpsProfile {
    if (-not (Test-AzureDevOpsProfile)) {
        throw "AzureDevOps Profile is not loaded or set"
    }
}
