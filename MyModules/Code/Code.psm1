$script:primaryLogFile = "$(Get-LogFolder)\UpdateCodeFolder.log"

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

function Import-DevelopmentPowerShellModule {
    param (
        [string]$Module,
        [string]$Path = $(Get-DefaultCodeFolder)
    )

    $moduleFolder = (Get-ChildItem -Path $Path -Filter "MyModules" -Recurse).FullName

    if (Test-Path "$moduleFolder\$Module\$Module.psd1") {
        $moduleFile = "$Module.psd1"
    } else {
        if (Test-Path "$moduleFolder\$Module\$Module.psm1") {
            $moduleFile = "$Module.psm1"
        }
    }

    if  ($moduleFile) {
        Import-Module -Global "$moduleFolder\$module\$moduleFile" -Force -Verbose
    }
}

Set-Alias -Name idpsm -Value Import-DevelopmentPowerShellModule

function Import-DevelopmentPowerShellModules {
    param (
        [string]$Path = $(Get-DefaultCodeFolder)
    )

    $ErrorPreviousAction = $ErrorActionPreference

    try {
        $moduleFolder = (Get-ChildItem -Path $Path -Filter "MyModules" -Recurse).FullName
        $modules = (Get-ChildItem -Path $moduleFolder).Name
        $ErrorActionPreference = "Stop"

        foreach ($module in $modules) {
            if ($module -eq "GlobalScripts") {
                continue
            }

            if (Test-Path "$moduleFolder\$module\$module.psd1") {
                $moduleFile = "$module.psd1"
            } else {
                if (Test-Path "$moduleFolder\$module\$module.psm1") {
                    $moduleFile = "$module.psm1"
                }
            }

            if  ($moduleFile) {
                Get-Module -Name $module | ForEach-Object {
                    Remove-Module -Name $_.Name -Force
                }

                Import-Module "$moduleFolder\$module\$moduleFile"
            }
        }
    }
    finally {
        $ErrorActionPreference = $errorPreviousAction
    }

    Get-Module -All | Select-Object Name, Version, Path | `
        Where-Object { $_.Path -like "$moduleFolder*"} | Format-Table
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

            Start-Process -FilePath "git.exe" -ArgumentList "fetch --prune" `
                -NoNewWindow -Wait | Out-Null

            if (-not $FetchOnly) {
                $output = (& git.exe status 2>&1) | Out-String

                if ($output -match "Your branch is up to date") {
                    Write-Log "    ...project is up to date..." -LogFile $script:primaryLogFile
                } else {
                    Write-Log "    ...pulling changes..." -LogFile $script:primaryLogFile
                    $output = (& git.exe merge --verbose --autostash FETCH_HEAD 2>&1) | Out-String

                    Optimize-LogFolder -Filter $Project
                    Write-Log $output -LogFile $(Get-LogFileName -Suffix $project) -NoOutput
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
