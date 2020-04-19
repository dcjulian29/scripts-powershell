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
        Get-Module  | Where-Object { $_.Name -eq $Module } | Remove-Module
        Import-Module -Global "$moduleFolder\$Module\$moduleFile" -Force -Verbose
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
