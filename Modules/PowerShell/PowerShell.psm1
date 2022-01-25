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

function Get-LastExecutionTime {
  $command = Get-History -Count 1

  return $command.EndExecutionTime - $command.StartExecutionTime
}

function Get-PowershellVerbs {
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
        Write-Output "Replacing '$($_.Content)' with '$($aliases.($_.Content))'..."
        $text = $text `
          -replace ('(?<=(\W|\b|^))' + [regex]::Escape($_.Content) + '(?=(\W|\b|$))'), $aliases.($_.Content)
      }
    }

  if ($null -eq $errors) {
    Set-Content -Path $Path -Value $text
  } else {
    Write-Error $errors
  }
}

function Reset-Module {
  param (
    [Parameter(Mandatory = $true)]
    [Alias("ModuleName")]
    [string] $Name
  )

  if ((Get-Module -list | Where-Object { $_.Name -eq "$Name" } | Measure-Object).Count -gt 0) {
    if ((Get-Module -all | Where-Object { $_.Name -eq "$Name" } | Measure-Object).count -gt 0) {
      Remove-Module -Name $Name -Force -Verbose
    }
  }
}

Set-Alias -Name "Unload-Module" -Value Reset-Module

function Restart-Module {
  param (
    [Parameter(Mandatory = $true)]
    [Alias("ModuleName")]
    [string] $Name
  )

  if ((Get-Module -list | Where-Object { $_.Name -eq "$ModuleName" } | Measure-Object).Count -gt 0) {
    Reset-Module $Name
    Import-Module $ModuleName -Verbose
  }
}

Set-Alias -Name Reload-Module -Value Restart-Module

function Search-Command {
  param (
    [Parameter(Mandatory = $true)]
    [string]$Filter
  )

  Get-Command | Where-Object { $_.Name -like "*$Filter*" } `
    | Sort-Object Name | Format-Table Name,Version, Source
}

Set-Alias -Name Find-PSCommand -Value Search-Command

function Test-IsNonInteractive {
  return (Get-WmiObject Win32_Process -filter "ProcessID=$pid").CommandLine `
    -match "-NonInteractive"
}

function Test-PowershellVerb {
  param (
    [Parameter(Mandatory = $true)]
    [string] $Verb
 )

  if (Get-Verb $Verb) {
    return $true
  }

  return $false
}

function Update-AllModules {
  Write-Host "Updating third-party Powershell modules..." -ForegroundColor Magenta
  Update-InstalledModules

  Write-Host "`nUpdating my Powershell modules..." -ForegroundColor Cyan
  Update-MyModules
}

function Update-InstalledModules {
  param (
    [switch] $Verbose
  )

  $modules = (Get-InstalledModule).Name
  $first = $true

  foreach ($module in $modules) {
    if ($Verbose -and (-not $first)) {
      Write-Output "`n--------------------------------------`n"
    }

    Update-Module -Name $module -Confirm:$false -Verbose:$Verbose

    $first = $false
  }

  if ($Verbose -and (-not $first)) {
    Write-Output "`n--------------------------------------`n"

    Write-Output (Get-InstalledModule `
      | Select-Object Name,Version,PublishedDate,RepositorySourceLocation `
      | Sort-Object PublishedDate -Descending `
      | Format-Table | Out-String)
  }
}

function Update-MyModules {
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

function Update-MyProfile {
  $docDir = Join-Path -Path $env:UserProfile -ChildPath Documents
  $poshDir = Join-Path -Path $docDir -ChildPath WindowsPowerShell

  clearRepoDownloads

  Download-File "https://github.com/dcjulian29/scripts-powershell/archive/refs/heads/main.zip" `
    "${env:TEMP}\scripts-powershell-main.zip"

  Unzip-File "${env:TEMP}\scripts-powershell-main.zip" "${env:TEMP}\"

  Copy-Item -Path "${env:TEMP}\scripts-powershell-main\profile.ps1" -Destination $poshDir -Force
  Copy-Item -Path "${env:TEMP}\scripts-powershell-main\Microsoft.PowerShell_profile.ps1" `
    -Destination $poshDir -Force
  Copy-Item -Path "${env:TEMP}\scripts-powershell-main\Microsoft.VSCode_profile.ps1" `
    -Destination $poshDir -Force

  clearRepoDownloads

  Reload-Profile
}

function Update-MyPublishedModules {
  param (
    [switch] $Verbose
  )

  $docDir = Join-Path -Path $env:UserProfile -ChildPath Documents
  $poshDir = Join-Path -Path $docDir -ChildPath WindowsPowerShell
  $modulesDir = Join-Path -Path $poshDir -ChildPath Modules

  Download-File "https://raw.githubusercontent.com/dcjulian29/choco-packages/main/mypowershell/tools/mine.json" "${env:TEMP}\mymodules.json"

  (Get-Content "${env:TEMP}\mymodules.json" | ConvertFrom-Json) | ForEach-Object {
    if (Test-Path "$modulesDir\$_") {
      Remove-Item "$modulesDir\$_" -Recurse -Force
    }

    if (Get-InstalledModule -Name $_ -ErrorAction SilentlyContinue) {
      Write-Output "Updating my '$_' module..."
      Update-Module -Name $_ -Verbose:$Verbose -Confirm:$false
    } else {
      Write-Output "Installing my '$_' module..."
      Install-Module -Name $_ -Repository "dcjulian29-powershell" -Verbose:$Verbose -AllowClobber
    }

    Write-Output " "
  }

  Get-Module -ListAvailable | Out-Null

  if ($Verbose) {
    Write-Output (Get-InstalledModule `
      | Select-Object Name,Version,PublishedDate,RepositorySourceLocation `
      | Sort-Object PublishedDate -Descending `
      | Format-Table | Out-String)
  }
}

function Update-PreCompiledAssemblies {
  Write-Output "Ensuring all currently loaded runtime assemblies are pre-compiled..."

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
