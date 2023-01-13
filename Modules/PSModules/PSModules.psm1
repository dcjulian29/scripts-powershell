function Get-InstalledModuleReport {
  Write-Output (Get-InstalledModule `
  | Select-Object Name,Version,PublishedDate,RepositorySourceLocation `
  | Sort-Object PublishedDate -Descending `
  | Format-Table | Out-String)
}

function Optimize-InstalledModules {
  [CmdletBinding()]
  [Alias("Remove-OutdatedModules")]
  param ( )

  $latest = Get-InstalledModule
  foreach ($module in $latest) {
    Write-Verbose -Message "Looking for old versions of $($module.Name) $($module.Version)" `
      -Verbose
    Get-InstalledModule -Name $module.Name -AllVersions `
      | Where-Object {$_.Version -ne $module.Version} `
      | Uninstall-Module -Verbose -Force
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

    Get-InstalledModuleReport
  }
}

function Update-PreCompiledAssemblies {
  param (
    [switch] $Full,
    [switch] $Verbose,
    [switch] $DisableNameChecking
  )

  if ($Full) {
    Write-Output "Importing all available modules to make sure assemblies are loaded..."

    Get-Module | Remove-Module -Force -Verbose:$Verbose

    foreach ($module in $(Get-Module -ListAvailable | Where-Object { $_.Name -ne 'GlobalScripts' })) {
      try {
        Import-Module -Name $module -ErrorAction SilentlyContinue -Force `
          -Verbose:$Verbose -DisableNameChecking:$DisableNameChecking
      } catch {}
    }
  }

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
