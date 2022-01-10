function Clear-LogStashProfile {
    Remove-Item env:LogStashURL
}

Set-Alias logstash-profile-clear Clear-LogStashProfile
Set-Alias ls-profile-clear Clear-LogStashProfile

function Get-LogStashHotThreads {
    param(
        [switch]$Threads
    )

    if ($Threads) {
        (Invoke-LogStashApi -Method "_node/hot_threads").hot_threads.threads
    } else {
        (Invoke-LogStashApi -Method "_node/hot_threads").hot_threads
    }
        (Invoke-LogStashApi -Method "_node/hot_threads").hot_threads
}

function Get-LogStashNode {
    Invoke-LogStashApi -Method "_node"
}

function Get-LogStashPipeline {
    param(
        [string]$Pipeline,
        [switch]$Detailed
    )

    if ($Detailed) {
        if ($Pipeline) {
            (Invoke-LogStashApi -Method "_node/stats/pipelines/$Pipeline").pipelines.$Pipeline
        } else {
            (Invoke-LogStashApi -Method "_node/stats/pipelines").pipelines
        }
    } else {
        if ($Pipeline) {
            (Invoke-LogStashApi -Method "_node/pipelines/$Pipeline").pipelines.$Pipeline
        } else {
            (Invoke-LogStashApi -Method "_node/pipelines").pipelines
        }
    }
}

function Get-LogStashPlugins {
    (Invoke-LogStashApi -Method "_node/plugins").plugins
}

function Get-LogStashServer {
    param (
        [switch]$Detailed,
        [alias("os")]
        [switch]$OperatingSystem,
        [alias("jvm")]
        [switch]$JavaVirtualMachine,
        [switch]$Events
    )

    if ($Detailed -or $Events) {
        if ($JavaVirtualMachine) {
            (Invoke-LogStashApi -Method "_node/stats/jvm").jvm
        } else {
            if ($OperatingSystem) {
                (Invoke-LogStashApi -Method "_node/stats/os").os
            } else {
                if ($Events) {
                    (Invoke-LogStashApi -Method "_node/stats/os").os
                } else {
                    Invoke-LogStashApi -Method "_node/stats"
                }
            }
        }
    } else {
        if ($OperatingSystem) {
            (Invoke-LogStashApi -Method "_node/os").os
        } else {
            if ($JavaVirtualMachine) {
                (Invoke-LogStashApi -Method "_node/jvm").jvm
            } else {
                Invoke-LogStashApi -Method "?pretty"
            }
        }
    }
}

function Import-LogStashProfile {
    param (
        [string]$ProfileName = $(Read-Host "Enter the LogStash Profile")
    )

    $profileFile = Join-Path -Path "$($env:SystemDrive)/etc/logstash" -ChildPath "$ProfileName.json"

    if (-not (Test-Path $profileFile)) {
        Write-Error "LogStash Profile does not exist!"
    } else {
        $json = Get-Content -Raw -Path $profileFile | ConvertFrom-Json

        $env:LogStashURL = $json.Url
    }
}

Set-Alias -Name Load-LogStashProfile -Value Import-LogStashProfile
Set-Alias -Name logstash-profile-load -Value Import-LogStashProfile
Set-Alias -Name ls-profile-load -Value Import-LogStashProfile

function Invoke-LogStashApi {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Method,
        [string] $Body,
        [ValidateSet("GET", "POST", "PUT", "DELETE")]
        [string] $HttpMethod = "GET",
        [string] $BodyType = "application/json",
        [switch] $Raw
    )

    Use-LogStashProfile

    $header = @{
        "Accept" = "application/json"
    }

    $uri = "$env:LogStashUrl/$Method"

    try {
        if ($HttpMethod -ne "GET") {
            $header.Add("Content-Type", $BodyType)
            $response = Invoke-WebRequest -Uri $uri -Method $HttpMethod -Header $header -Body $Body -ErrorAction Stop
        } else {
            $response = Invoke-WebRequest -Uri $uri -Method $HttpMethod -Header $header -ErrorAction Stop
        }

        if ( -not $Raw) {
            $response = $response.Content | ConvertFrom-Json
        } else {
            $response = $response.Content
        }
    } catch [System.Net.WebException] {
        $response = $_.ErrorDetails.Message

        if (-not $Raw) {
            $response = $response | ConvertFrom-Json
        }
    }

    return $response
}

Set-Alias ls-api Invoke-LogStashApi
Set-Alias logstash-api Invoke-LogStashApi

function New-LogStashProfile {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Name,
        [Parameter(Mandatory = $true)]
        [string] $Url
    )

    if (Test-Path "$env:SystemDrive\etc\logstash\$Name.json") {
        throw "LogStash '$Name' profile already exist!"
    }

    $json = New-Object PSObject
    $json | Add-Member -Type NoteProperty -Name 'Url' -Value $Url
    $json = $json | ConvertTo-Json

    Set-Content -Path "$env:SystemDrive\etc\logstash\$Name.json" -Value $json -Encoding ASCII
}

function Set-LogStashProfile {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Url
    )

    $env:LogStashURL = $Url
}

function Test-LogStashProfile {
    return Test-Path env:LogStashURL
}

function Use-LogStashProfile {
    if (-not (Test-LogStashProfile)) {
        throw "LogStash Profile is not loaded or set"
    }
}
