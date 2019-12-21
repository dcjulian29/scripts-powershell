function Get-LogFolder {
    if (Test-Path "$env:SystemDrive\etc") {
        if (-not (Test-Path "$env:SystemDrive\etc\log")) {
            New-Item -Path "$env:SystemDrive\etc\log" -ItemType Directory | Out-Null
        }

        "$env:SystemDrive\etc\log"
    } else {
        "$env:TEMP"
    }
}

function Get-LogFileName {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Suffix,
        [psobject]$Date = $(Get-Date)
    )

    $(Get-LogFolder) + "\" `
        + $Date.ToString("yyyMMdd_HHmmss") + "-$Suffix.log"
}

function Optimize-LogFolder {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Filter,
        [string]$Path = $(Get-LogFolder),
        [Int32]$NumberToKeep = 5,
        [switch]$Compress
    )

    $files = Get-ChildItem -Path $Path -Filter "*$Filter*.log" | `
        Sort-Object -Property LastWriteTime -Descending | `
        Select-Object -Skip $NumberToKeep

    if ($Compress) {
        $files | ForEach-Object {
            Compress-Archive -Path $_.FullName `
                -DestinationPath "$($_.DirectoryName)\$($_.BaseName).zip" `
                -Force
        }
    }

    $files | ForEach-Object { Remove-Item -Path $_.FullName -Force }
}

function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string] $Message,
        [string] $LogFile = "$(Get-LogFolder)\_default.log",
        [switch] $NoOutput,
        [switch] $Warning,
        [switch] $NoTimestamp
    )

    if (-not (Test-Path $(Split-Path $LogFile))) {
        New-Item -Path $(Split-Path $LogFile) -ItemType Directory | Out-Null
    }

    if ($NoTimestamp) {
        $text = "$Message"
    } else {
        $text = "$(Get-Date -Format "MM/dd/yyyy HH:mm:ss") : $Message"
    }

    if (Test-Path $LogFile) {
        Add-Content -Path $LogFile -Value $text
    } else {
        Set-Content -Path $LogFile -Value $text
    }

    if (-not $NoOutput) {
        if ($Warning) {
            Write-Warning $Message
        } else {
            Write-Output $Message
        }
    }
}
