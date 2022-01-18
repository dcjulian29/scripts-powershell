function clearRepoDownloads {
  @(
    "${env:TEMP}\scripts-powershell-main.zip"
    "${env:TEMP}\scripts-powershell-main"
    "${env:TEMP}\posh-go.zip"
    "${env:TEMP}\Go-Shell-master"
  ) | ForEach-Object {
    if (Test-Path $_) {
        Remove-Item $_ -Recurse -Force
    }
  }
}

#------------------------------------------------------------------------------

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

function Get-AvailableExceptionsList {
  $exceptions = @()

  foreach ($assembly in [AppDomain]::CurrentDomain.GetAssemblies()) {
    foreach ($className in ($assembly.ExportedTypes -match '.*Exception$')) {
      if ($null -ne $className.DeclaredConstructors) {
        $exceptions += $className.FullName
      }
    }
  }

  return $exceptions | Sort-Object -Unique
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

function Initialize-PSGallery {
    Import-Module PackageManagement -RequiredVersion 1.0.0.1
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
}

function New-ErrorRecord {
  [CmdletBinding(DefaultParameterSetName="Message")]
  param(
    [Parameter(Mandatory=$True, Position=0, ParameterSetName="Message")]
    [string] $Message,

    [Parameter(Mandatory=$True, Position=1, ParameterSetName="Message")]
    [string] $ExceptionType,

    [Parameter(Mandatory=$True, Position=2, ParameterSetName="Message")]
    [Parameter(Mandatory=$True, Position=1, ParameterSetName="Exception")]
    [Alias("Id")]
    [string] $ErrorId,

    [Parameter(Mandatory=$True, Position=3, ParameterSetName="Message")]
    [Parameter(Mandatory=$True, Position=2, ParameterSetName="Exception")]
    [Alias('Category')]
    [ValidateSet('NotSpecified', 'OpenError', 'CloseError', 'DeviceError',
                 'DeadlockDetected', 'InvalidArgument', 'InvalidData',
                 'InvalidOperation', 'InvalidResult', 'InvalidType',
                 'MetadataError', 'NotImplemented', 'NotInstalled',
                 'ObjectNotFound', 'OperationStopped', 'OperationTimeout',
                 'SyntaxError', 'ParserError', 'PermissionDenied', 'ResourceBusy',
                 'ResourceExists', 'ResourceUnavailable', 'ReadError',
                 'WriteError', 'FromStdErr', 'SecurityError')]
    [System.Management.Automation.ErrorCategory] $ErrorCategory,

    [Parameter(Mandatory=$False, Position=4, ParameterSetName="Message")]
    [Parameter(Mandatory=$False, Position=3, ParameterSetName="Exception")]
    [object] $TargetObject,

    [Parameter(Mandatory=$True, Position = 0, ParameterSetName="Exception")]
    [Exception] $Exception,

    [Parameter(Mandatory=$False, ParameterSetName="Message")]
    [Exception] $InnerException
  )

  BEGIN {
    $exceptions = Get-AvailableExceptionsList
  }

  PROCESS {
    # trap for any of the "exceptional" Exception objects.
    trap [Microsoft.PowerShell.Commands.NewObjectCommand] {
      $PSCmdlet.ThrowTerminatingError($_)
    }

    if ($PSCmdlet.ParameterSetName -eq 'Message') {
      if ($exceptions -match "^(System\.)?$ExceptionType$") {
        $Exception = if ($Message -and $InnerException) {
            New-Object $ExceptionType $Message, $InnerException
        } elseif ($Message) {
            New-Object $ExceptionType $Message
        } else {
            New-Object $ExceptionType
        }
      } else {
        $PSCmdlet.ThrowTerminatingError((New-Object Management.Automation.ErrorRecord `
          (New-Object System.InvalidOperationException "Exception '$ExceptionType' is not available."), `
          'UnknownException', 'InvalidOperation', 'Get-AvailableExceptionsList'))
      }
    }

    New-Object Management.Automation.ErrorRecord $Exception, $ErrorID,
      $ErrorCategory, $TargetObject
  }
}

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

function Update-AllPowershellModules {
  Write-Host "Updating third-party Powershell modules...`n" -ForegroundColor Magenta
  Update-PowershellModules

  Write-Host "`n`nUpdating my Powershell modules...`n" -ForegroundColor Cyan
  Update-MyPowershellModules
}

function Update-MyPowershellModules {
  $docDir = Join-Path -Path $env:UserProfile -ChildPath Documents
  $poshDir = Join-Path -Path $docDir -ChildPath WindowsPowerShell
  $modulesDir = Join-Path -Path $poshDir -ChildPath Modules

  clearRepoDownloads

  Download-File "https://github.com/dcjulian29/scripts-powershell/archive/refs/heads/main.zip" `
    "${env:TEMP}\scripts-powershell-main.zip"

  Unzip-File "${env:TEMP}\scripts-powershell-main.zip" "${env:TEMP}\"

  Download-File "https://github.com/cameronharp/Go-Shell/archive/master.zip" `
    "${env:TEMP}\posh-go.zip"

  Unzip-File "${env:TEMP}\posh-go.zip" "${env:TEMP}\"

  if (-not (Test-Path "$modulesDir\go")) {
    New-Item -Type Directory -Path "$modulesDir\go" | Out-Null
  }

  Copy-Item -Path "${env:TEMP}\Go-Shell-master\*" -Destination "$modulesDir\go" -Force

  (Get-ChildItem -Directory -Path "${env:TEMP}\scripts-powershell-main\Modules").FullName |
    Copy-Item -Force -Destination { $_ -replace [regex]::Escape("${env:TEMP}\scripts-powershell-main\modules"), $modulesDir } -Recurse

  $modules = (Get-InstalledModule).Name

  foreach ($module in $modules) {
    if (Test-Path "$modulesDir\$module") {
      if (Get-Module $module) {
        Remove-Module $module -Force
      }

      Remove-Item -Path "$modulesDir\$module" -Recurse -Force
    }
  }

  Get-Module -ListAvailable | Out-Null

  clearRepoDownloads
}

function Update-PowershellModules {
  $modules = (Get-InstalledModule).Name
  $first = $true

  foreach ($module in $modules) {
    if (-not $first) {
      Write-Output "`n--------------------------------------`n"
    }

    Update-Module -Name $module -Confirm:$false -Verbose

    $first = $false
  }

  Get-Module -ListAvailable | Out-Null
}

function Update-PreCompiledAssemblies {
  Write-Output "Ensuring all currrently loaded runtime assemblies are pre-compiled..."

  $originalPath = $env:PATH
  $env:PATH = "$([Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory());${env:PATH}"

  [AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object {
    $path = $_.Location
    if ($path) {
      $name = Split-Path $path -Leaf
      Write-Output "`n`nRunning ngen.exe on '$name'..."
      ngen.exe install $path /nologo
    }
  }

  $env:PATH = $originalPath
}

function Update-Profile {
    . $profile
}

Set-Alias -Name Reload-Profile -Value Update-Profile