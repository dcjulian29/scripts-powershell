function Edit-Profile {
    Start-Notepad $profile
}

Function Get-LastExecutionTime {
    $command = Get-History -Count 1

    return $command.EndExecutionTime - $command.StartExecutionTime
}

function Get-Profile {
    Get-Content $profile
}

function Import-Assembly {
    param (
        [string]$Assembly
    )

    if (Test-Path $Assembly) {
        $assemblyPath = Get-Item $assembly
        [System.Reflection.Assembly]::LoadFrom($assemblyPath)
    } else {
        [System.Reflection.Assembly]::LoadWithPartialName("$assembly") # Load from GAC
    }
}

Set-Alias -Name Load-Assembly -Value Import-Assembly

function Search-Command {
    param (
        [string]$Filter
    )

    Get-Command | Where-Object { $_.Name -like "*$Filter*" } | Sort-Object Name | Format-Table Name,Version, Source
}

Set-Alias -Name Find-PSCommand -Value Search-Command

function Update-Profile {
    . $profile
}

Set-Alias -Name Reload-Profile -Value Update-Profile
