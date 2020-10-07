function Edit-Profile {
    Start-Notepad $profile
}

Function Get-LastExecutionTime {
    $command = Get-History -Count 1

    return $command.EndExecutionTime - $command.StartExecutionTime
}

function Get-PowerShellVerb {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Verb
   )

   Get-Verb | Where-Object { $_.Verb -eq $Verb }
}

function Get-PowerShellVerbs {
    Get-Verb | Sort-Object -Property Verb
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

function Test-IsNonInteractive {
    return (Get-WmiObject Win32_Process -filter "ProcessID=$pid").CommandLine -match "-NonInteractive"
}

function Test-PowerShellVerb {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Verb
   )

    if (Get-PowerShellVerb $Verb) {
        return $true
    }

    return $false
}

function Update-Profile {
    . $profile
}

Set-Alias -Name Reload-Profile -Value Update-Profile
