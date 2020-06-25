function Clear-ElasticSearchProfile {
    Remove-Item env:ElasticSearchURL
}

Set-Alias elasticsearch-profile-clear Clear-ElasticSearchProfile
Set-Alias es-profile-clear Clear-ElasticSearchProfile

function Import-ElasticSearchProfile {
    param (
        [string]$ProfileName = $(Read-Host "Enter the ElasticSearch Profile")
    )

    $profileFile = Join-Path -Path "$($env:SystemDrive)/etc/elasticsearch" -ChildPath "$ProfileName.json"

    if (-not (Test-Path $profileFile)) {
        Write-Error "ElasticSearch Profile does not exist!"
    } else {
        $json = Get-Content -Raw -Path $profileFile | ConvertFrom-Json

        $env:ElasticSearchURL = $json.Url
    }
}

Set-Alias -Name Load-ElasticSearchProfile -Value Import-ElasticSearchProfile
Set-Alias -Name elasticsearch-profile-load -Value Import-ElasticSearchProfile
Set-Alias -Name es-profile-load -Value Import-ElasticSearchProfile

function Invoke-ElasticSearchApi {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Method,
        [string] $Body,
        [ValidateSet("GET", "POST", "PUT", "DELETE")]
        [string] $HttpMethod = "GET",
        [string] $BodyType = "application/xml"
    )

    Use-ElasticSearchProfile

    $header = @{
        "Accept" = "application/json"
    }

    $uri = "$env:ElasticSearchUrl/$Method"

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

Set-Alias es-api Invoke-ElasticSearchApi
Set-Alias elasticsearch-api Invoke-ElasticSearchApi

function New-ElasticSearchProfile {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Name,
        [Parameter(Mandatory = $true)]
        [string] $Url
    )

    if (Test-Path "$env:SystemDrive\etc\elasticsearch\$Name.json") {
        throw "ElasticSearch '$Name' profile already exist!"
    }

    $json = New-Object PSObject
    $json | Add-Member -Type NoteProperty -Name 'Url' -Value $Url
    $json = $json | ConvertTo-Json

    Set-Content -Path "$env:SystemDrive\etc\elasticsearch\$Name.json" -Value $json -Encoding ASCII
}

function Set-ElasticSearchProfile {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Url
    )

    $env:ElasticSearchURL = $Url
}

function Test-ElasticSearchProfile {
    return Test-Path env:ElasticSearchURL
}

function Use-ElasticSearchProfile {
    if (-not (Test-ElasticSearchProfile)) {
        throw "ElasticSearch Profile is not loaded or set"
    }
}
