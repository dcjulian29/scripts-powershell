function Write-PrimaryLog {
    param (
        [Parameter(Mandatory=$true)]
        [string] $Message,
        [switch] $NoOutput,
        [switch] $Warning
    )

    $now = Get-Date -Format "MM/dd/yyyy HH:mm:ss"
    $file = "$(Get-DefaultCodeFolder)\_logs\UpdateCodeFolder.log"

    if (-not (Test-Path "$(Get-DefaultCodeFolder)\_logs")) {
        New-Item -Path "$(Get-DefaultCodeFolder)\_logs" -ItemType Directory | Out-Null
    }

    $text = "$now : $Message"

    if (Test-Path $file) {
        Add-Content -Path $file -Value $text
    } else {
        Set-Content -Path $file -Value $text
    }

    if (-not $NoOutput) {
        if ($Warning) {
            Write-Warning $Message
        } else {
            Write-Output $Message
        }
    }
}

function Write-ProjectUpdateLog{
    param (
        [Parameter(Mandatory=$true)]
        [string] $Project,
        [Parameter(Mandatory=$true)]
        [string[]] $Text
    )

    $folder = "$(Get-DefaultCodeFolder)\_logs"
    $file = "$folder\$Project-$(Get-Date -Format 'yyyMMddHHmmss').log"

    # Only Keep Last 5 Logs.
    Get-ChildItem -Path $folder -Filter "$Project-*.log" | `
        Sort-Object -Property LastWriteTime -Descending | `
        Select-Object -Skip 4 | Remove-Item -Force

    if (Test-Path $file) {
        Add-Content -Path $file -Value $Text
    } else {
        Set-Content -Path $file -Value $Text
    }
}

###############################################################################

function Get-DefaultCodeFolder {
    $folder = "$($env:SystemDrive)\code"

    if ($null -ne $env:CodeFolder) {
        $folder = $env:CodeFolder
    }

    if (Test-Path $folder) {
        $folder
    } else {
        "C:\code"
    }
}

function Update-CodeFolder {
    [CmdletBinding()]
    param (
        [Alias("CodeFolder", "Folder")]
        [string]$Path = $(Get-DefaultCodeFolder),
        [switch] $FetchOnly
    )

    Write-PrimaryLog "Starting Update-CodeFolder" -NoOutput

    $projects = (Get-ChildItem -Path $Path -Exclude '_logs' | `
        Where-Object { $_.PSIsContainer } | `
        Select-Object Name).Name

    foreach ($project in $projects) {
        Write-PrimaryLog "Using $Path\$project\.git" -NoOutput
        if (Test-Path "$Path\$project\.git") {
            Write-PrimaryLog "Checking $project..."

            Push-Location "$Path\$project"

            Start-Process -FilePath "git.exe" -ArgumentList "fetch --prune" -NoNewWindow -Wait | Out-Null

            if (-not $FetchOnly) {
                $output = (& git.exe status 2>&1) | Out-String

                if ($output -match "Your branch is up to date") {
                    Write-PrimaryLog "    ...project is up to date..."
                } else {
                    Write-PrimaryLog "    ...pulling changes..."
                    $output = (& git.exe merge --verbose --autostash FETCH_HEAD 2>&1) | Out-String

                    Write-ProjectUpdateLog -Project $project -Text $output
                }
            }

            Pop-Location
        }
    }
}
