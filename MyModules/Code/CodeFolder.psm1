function Get-DefaultCodeFolder {
    $folder = "$($env:SystemDrive)\code"

    if ($null -ne $env:CodeFolder) {
        $folder = $env:CodeFolder
    }

    return $folder
}

function New-CodeFolder {
    param (
        [ValidateScript({ -not (Test-Path $(Resolve-Path $_)) })]
        [Alias("CodeFolder", "Folder")]
        [string]$Path = $(Get-DefaultCodeFolder)
    )

    if (-not (Test-Path $Path)) {
        New-Item -Type Directory -Path $Path | Out-Null
    }

    Set-CodeFolder -Path $Path
}

function Set-CodeFolder {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [Alias("CodeFolder", "Folder")]
        [string]$Path
    )

    $icon = "https://www.iconfinder.com/icons/37070/download/ico"

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

function Set-DefaultCodeFolder {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path
    )

    Set-EnvironmentVariable -Name "CodeFolder" -Value $Path
}

function Show-CodeStatus {
    [CmdletBinding()]
    param (
        [Alias("CodeFolder", "Folder")]
        [string]$Path = $(Get-DefaultCodeFolder)
    )

    $projects = (Get-ChildItem -Path $Path | `
        Where-Object { $_.PSIsContainer } | `
        Select-Object Name).Name

    foreach ($project in $projects) {
        if (Test-Path "$Path\$project\.git") {
            Write-Output "`n    ....$project...`n"

            Push-Location "$Path\$project"

            Invoke-FetchGitRepository 2>&1 | Out-Null
            Get-GitRepositoryStatus

            Pop-Location
        }
    }
}

function Test-DefaultCodeFolder {
    return Test-Path $(Get-DefaultCodeFolder)
}

function Update-CodeFolder {
    [CmdletBinding()]
    param (
        [Alias("CodeFolder", "Folder")]
        [string]$Path = $(Get-DefaultCodeFolder),
        [switch] $FetchOnly
    )

    $logFile = Get-LogFileName -Suffix "UpdateCodeFolder"

    Write-Log "Starting Update-CodeFolder" -LogFile $logFile -NoOutput

    $projects = (Get-ChildItem -Path $Path | `
        Where-Object { $_.PSIsContainer } | `
        Select-Object Name).Name

    foreach ($project in $projects) {
        Write-Log "Using $Path\$project\.git" -LogFile $logFile -NoOutput

        if (Test-Path "$Path\$project\.git") {
            Write-Log "Checking $project..." -LogFile $logFile

            Push-Location "$Path\$project"

            $output = Invoke-FetchGitRepository | Out-String

            Write-Log $output -LogFile $logFile -NoOutput

            if (-not $FetchOnly) {
                $output = (& "$(Find-Git)" status 2>&1) | Out-String

                if ($output -match "Your branch is up to date") {
                    Write-Log "    ...project is up to date..." -LogFile $logFile
                } else {
                    Write-Log "    ...pulling changes..." -LogFile $logFile

                    $output = (& "$(Find-Git)" merge --verbose --autostash FETCH_HEAD 2>&1) | Out-String

                    Optimize-LogFolder -Filter $Project

                    Write-Log $output -LogFile $(Get-LogFileName -Suffix $project) -NoOutput
                }
            }

            Pop-Location
        }
    }
}
