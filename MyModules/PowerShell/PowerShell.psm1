function Edit-Profile {
    Start-Notepad $profile
}

function Format-FileWithSpaceIndent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $Path,
        [int]$spaces = 4
    )

    $tab = "`t"
    $space = " " * $spaces
    $text = Get-Content -Path $Path

    $newText = ""

    foreach ($line in $text -split [Environment]::NewLine) {
        if ($line -match "\S") {
            $pos = $line.IndexOf($Matches[0])
            $indentation = $line.SubString(0, $pos)
            $remainder = $line.SubString($pos)

            $replaced = $indentation -replace $tab, $space

            $newText += $replaced + $remainder + [Environment]::NewLine
        } else {
            $newText += $line + [Environment]::NewLine
        }

        Set-Content -Path $Path -Value $text
    }
}

function Format-FileWithTabIndent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $Path,
        [int]$Spaces = 4
    )

    $tab = "`t"
    $space = " " * $spaces
    $text = Get-Content -Path $Path

    $newText = ""

    foreach ($line in $text -split [Environment]::NewLine) {
        if ($line -match "\S") {
            $pos = $line.IndexOf($Matches[0])
            $indentation = $line.SubString(0, $pos)
            $remainder = $line.SubString($pos)

            $replaced = $indentation -replace $space, $tab

            $newText += $replaced + $remainder + [Environment]::NewLine
        } else {
            $newText += $line + [Environment]::NewLine
        }

        Set-Content -Path $Path -Value $text
    }
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

function Remove-AliasesFromScript {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $Path
    )

    $aliases = @{}

    Get-Alias | Select-Object Name, Definition | ForEach-Object {
        $aliases.Add($_.Name, $_.Definition)
    }

    $errors = $null
    $text = Get-Content -Path $Path

    [System.Management.Automation.PSParser]::Tokenize($text, [ref]$errors) |
        Where-Object { $_.Type -eq "command" } |
        ForEach-Object {
            if ($aliases.($_.Content)) {
                $text = $text -replace
                    ('(?<=(\W|\b|^))' + [regex]::Escape($_.Content) + '(?=(\W|\b|$))'),
                    $a.($_.Content)
            }
        }

    if ($null -eq $errors) {
        Set-Content -Path $Path -Value $text
    } else {
        Write-Error $errors
    }
}

function Restart-Module {
    param (
        [string] $ModuleName
    )

    if ((Get-Module -list | Where-Object { $_.Name -eq "$ModuleName" } | Measure-Object).Count -gt 0) {
        if ((Get-Module -all | Where-Object { $_.Name -eq "$ModuleName" } | Measure-Object).count -gt 0) {
            Remove-Module -Name $ModuleName -Force -Verbose
        }

        Import-Module $ModuleName -Verbose
    } else {
        throw "Module $ModuleName Doesn't Exist"
    }
}

Set-Alias -Name Reload-Module -Value Restart-Module

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
