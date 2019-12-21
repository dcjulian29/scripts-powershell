$script:primaryLogFile = "$(Get-LogFolder)\UpdateCodeFolder.log"

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

function New-CodeFolder {
    param (
        [Alias("CodeFolder", "Folder")]
        [string]$Path = $(Get-DefaultCodeFolder)
    )

    $icon = "https://www.iconfinder.com/icons/37070/download/ico"

    if (-not (Test-Path $Path)) {
        New-Item -Type Directory -Path $Path | Out-Null
    }

    Download-File $icon $Path\code.ico

    Set-Content $Path\desktop.ini @"
[.ShellClassInfo]
IconResource=$Path\code.ico,0
[ViewState]
Mode=
Vid=
FolderType=Generic
"@

    attrib.exe +S +H $Path\desktop.ini
    attrib.exe +S $Path
}

function Update-CodeFolder {
    [CmdletBinding()]
    param (
        [Alias("CodeFolder", "Folder")]
        [string]$Path = $(Get-DefaultCodeFolder),
        [switch] $FetchOnly
    )

    Write-Log "Starting Update-CodeFolder" -LogFile $script:primaryLogFile -NoOutput

    $projects = (Get-ChildItem -Path $Path -Exclude '_logs' | `
        Where-Object { $_.PSIsContainer } | `
        Select-Object Name).Name

    foreach ($project in $projects) {
        Write-Log "Using $Path\$project\.git" -LogFile $script:primaryLogFile -NoOutput
        if (Test-Path "$Path\$project\.git") {
            Write-Log "Checking $project..." -LogFile $script:primaryLogFile

            Push-Location "$Path\$project"

            Start-Process -FilePath "git.exe" -ArgumentList "fetch --prune" -NoNewWindow -Wait | Out-Null

            if (-not $FetchOnly) {
                $output = (& git.exe status 2>&1) | Out-String

                if ($output -match "Your branch is up to date") {
                    Write-Log "    ...project is up to date..." -LogFile $script:primaryLogFile
                } else {
                    Write-Log "    ...pulling changes..." -LogFile $script:primaryLogFile
                    $output = (& git.exe merge --verbose --autostash FETCH_HEAD 2>&1) | Out-String

                    Write-ProjectUpdateLog -Project $project -Text $output
                }
            }

            Pop-Location
        }
    }
}

function Show-CodeStatus {
    [CmdletBinding()]
    param (
        [Alias("CodeFolder", "Folder")]
        [string]$Path = $(Get-DefaultCodeFolder)
    )

    $projects = (Get-ChildItem -Path $Path -Exclude '_logs' | `
        Where-Object { $_.PSIsContainer } | `
        Select-Object Name).Name

    foreach ($project in $projects) {
        if (Test-Path "$Path\$project\.git") {
            Write-Output "    ....$project..."
            Write-Output " "

            Push-Location "$Path\$project"

            Start-Process -FilePath "git.exe" -ArgumentList "fetch --prune" -NoNewWindow -Wait | Out-Null

            Start-Process -FilePath "git.exe" -ArgumentList "status" -NoNewWindow -Wait

            Pop-Location

            Write-Output " "
        }
    }
}
