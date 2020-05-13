function Clear-AzureDevOpsDefaultProject {
    Remove-Item env:AzureDevOpsProject
}

function Clear-AzureDevOpsProfile {
    Remove-Item env:AzureDevOpsURL
    Remove-Item env:AzureDevOpsToken
    Clear-AzureDevOpsDefaultProject
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

        if ($json.DefaultProject) {
            Set-AzureDevOpsDefaultProject $json.DefaultProject
        }
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
        [string] $Project,
        [ValidateSet("GET", "POST", "PUT", "DELETE")]
        [string] $HttpMethod = "GET",
        [string] $BodyType = "application/json",
        [string] $Version = "5.1",
        [switch] $PrefixProject
    )

    Use-AzureDevOpsProfile

    $token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($env:AzureDevOpsToken)"))
    $header = @{
        "Authorization" = "Basic $token"
        "Accept" = "application/json"
    }

    if ($PrefixProject) {
        if ($Project) {
            $uri = "$env:AzureDevOpsUrl/$Project/_apis/$($Method)?api-version=$Version"
        } else {
            if (Test-Path env:AzureDevOpsProject) {
                $uri = "$env:AzureDevOpsUrl/$env:AzureDevOpsProject/_apis/$($Method)?api-version=$Version"
            } else {
                throw "This Azure DevOps functions requires a project and one was not provided"
            }
        }
    } else {
        $uri = "$env:AzureDevOpsUrl/_apis/$($Method)?api-version=$Version"
    }

    if ($HttpMethod -ne "GET") {
        $header.Add("Content-Type", $BodyType)
        $response = Invoke-WebRequest -Uri $uri -Method $HttpMethod -Header $header -Body $Body
    } else {
        $response = Invoke-WebRequest -Uri $uri -Method $HttpMethod -Header $header
    }

    if ($response) {
        $response = $response -replace '""', '"Unknown"' | ConvertFrom-Json

        return $response
    }
}

Set-Alias adoapi Invoke-AzureDevOpsApi
Set-Alias azuredevops-api Invoke-AzureDevOpsApi

function Set-AzureDevOpsDefaultProject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ProjectName
    )

    $env:AzureDevOpsProject = $ProjectName
}

function Set-AzureDevOpsProfile {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Url,
        [Parameter(Mandatory = $true)]
        [string] $Token,
        [string] $DefaultProject
    )

    $env:AzureDevOpsURL = $Url
    $env:AzureDevOpsToken = $Token

    if ($DefaultProject) {
        Set-AzureDevOpsDefaultProject $DefaultProject
    }
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
