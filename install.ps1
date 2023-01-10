function removeDownloads() {
  @(
    "${env:TEMP}\scripts-powershell-main.zip"
    "${env:TEMP}\scripts-powershell-main"
  ) | ForEach-Object {
    if (Test-Path $_) {
        Remove-Item $_ -Recurse -Force
    }
  }
}

$docDir = Join-Path -Path $env:UserProfile -ChildPath Documents
$poshDir = Join-Path -Path $docDir -ChildPath WindowsPowerShell
$pwshDir = Join-Path -Path $docDir -ChildPath PowerShell
$modulesDir = Join-Path -Path $poshDir -ChildPath Modules
$binDir = Join-Path -Path $env:SYSTEMDRIVE -ChildPath bin
$url = "https://github.com/dcjulian29/scripts-powershell/archive/refs/heads/main.zip"

removeDownloads

Invoke-WebRequest -Uri $url -UseBasicParsing `
  -OutFile "${env:TEMP}\scripts-powershell-main.zip"

Microsoft.PowerShell.Archive\Expand-Archive -Path "${env:TEMP}\scripts-powershell-main.zip" `
  -DestinationPath "${env:TEMP}\" -Force

if (-not (Test-Path $binDir)) {
  New-Item -Type Directory -Path $binDir | Out-Null
}

if (-not (Test-Path $poshDir)) {
  New-Item -Path $poshDir -ItemType Directory | Out-Null
}

if (-not (Test-Path $pwshDir)) {
  New-Item -ItemType SymbolicLink -Path $docDir -Name PowerShell -Target $poshDir
}

if (-not (Test-Path $modulesDir)) {
  New-Item -Path $modulesDir -ItemType Directory | Out-Null
}

#------------------------------------------------------------------------------

Write-Output "Installing binary scripts to '$binDir' ..."

Copy-Item -Path "${env:TEMP}\scripts-powershell-main\bin\*" -Destination $binDir -Recurse -Force

if (Test-Path "${env:SYSTEMDRIVE}\tools\binaries") {
  Remove-Item -Path "${env:SYSTEMDRIVE}\tools\binaries" -Recurse -Force
}

#------------------------------------------------------------------------------

if (Test-Path "$poshDir\Profile.ps1") {
  Write-Output "Removing previous installed profile..."

  @(
    "$poshDir\Microsoft.PowerShell_profile.ps1"
    "$poshDir\Microsoft.VSCode_profile.ps1"
    "$poshDir\profile.ps1"
  ) | ForEach-Object {
    if (Test-Path $_) {
      Remove-Item -Path $_ -Force -ErrorAction SilentlyContinue
    }
  }
}

Write-Output "Installing profile to '$poshDir' ..."

@(
  "${env:TEMP}\scripts-powershell-main\Microsoft.PowerShell_profile.ps1"
  "${env:TEMP}\scripts-powershell-main\Microsoft.VSCode_profile.ps1"
  "${env:TEMP}\scripts-powershell-main\profile.ps1"
) | ForEach-Object {
  Copy-Item -Path $_ -Destination $poshDir -Recurse -Force
}

Write-Output "Checking modules path for '$modulesDir' ..."

if ((-not ($env:PSModulePath).Contains($modulesDir))) {
  Write-Output "Adding '$modulesDir' to modules path..."

  $userPath = $modulesDir + ";" `
    + [Environment]::GetEnvironmentVariable('PSModulePath', 'User')
  $machinePath = [Environment]::GetEnvironmentVariable('PSModulePath', 'Machine')

  $env:PSModulePath = $userPath + ";" + $machinePath

  Get-Module -ListAvailable | Out-Null

  Invoke-Expression "[Environment]::SetEnvironmentVariable('PSModulePath', '$userPath', 'User')"
}

#------------------------------------------------------------------------------

Write-Output "`n`n>>>-------->  Configuring Package Repositories...`n`n"

Import-Module PackageManagement

if (-not (Get-PackageProvider -Name NuGet)) {
  Install-PackageProvider -Name NuGet
}

Import-Module PowerShellGet

Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

if (-not (Get-PSRepository -Name "dcjulian29-powershell" -ErrorAction SilentlyContinue)) {
  Register-PSRepository -Name "dcjulian29-powershell" `
    -SourceLocation "https://www.myget.org/F/dcjulian29-powershell/api/v2"
} else {
  Set-PSRepository -Name "dcjulian29-powershell" `
    -SourceLocation "https://www.myget.org/F/dcjulian29-powershell/api/v2"
}

Set-PSRepository -Name "dcjulian29-powershell" -InstallationPolicy Trusted

Get-PSRepository

#------------------------------------------------------------------------------

Write-Output "`n`n>>>-------->  Remove Modules...`n`n"

(Get-Content "remove.json" | ConvertFrom-Json) | ForEach-Object {
  if (Get-Module -Name $_ -ListAvailable -ErrorAction SilentlyContinue) {
    Uninstall-Module -Name $_ -AllVersions -Force -Confirm:$false -Verbose
  }
}

Write-Output "`n`n>>>-------->  Third-Party Modules...`n`n"

Push-Location "${env:TEMP}\scripts-powershell-main"

(Get-Content "thirdparty.json" | ConvertFrom-Json) | ForEach-Object {
  if (Get-Module -Name $_ -ListAvailable -ErrorAction SilentlyContinue) {
    Write-Output "`n`n>> Updating third-party '$_' module...`n`n"
    Update-Module -Name $_ -Confirm:$false -Verbose
  } else {
    Write-Output "`n`n>> Installing third-party '$_' module..."
    Install-Module -Name $_ -AllowClobber -Verbose
  }
}

Write-Output "`n`n>>>-------->  My modules...`n`n"

(Get-Content "mine.json" | ConvertFrom-Json) | ForEach-Object {
  if (Get-Module -Name $_ -ListAvailable -ErrorAction SilentlyContinue) {
    Write-Output "`n`n>> Updating my '$_' module...`n`n"
    Update-Module -Name $_ -Confirm:$false -Verbose
  } else {
    Write-Output "`n`n>> Installing my '$_' module...`n`n"
    Install-Module -Name $_ -Repository "dcjulian29-powershell" -AllowClobber -Verbose
  }
}

Pop-Location

Write-Output "`n`n`nRefreshing the list of available modules..."

Get-Module -ListAvailable | Out-Null

Write-Output "============================================================================"

Write-Output (Get-InstalledModule `
  | Select-Object Name,Version,PublishedDate,RepositorySourceLocation `
  | Sort-Object PublishedDate -Descending `
  | Format-Table | Out-String)

Write-Output "============================================================================"

#------------------------------------------------------------------------------

Write-Output "Importing all available modules to make sure assemblies are loaded..."
Write-Warning "You can ignore any errors until the next divider."

Get-Module -ListAvailable | Import-Module -ErrorAction SilentlyContinue | Out-Null

Write-Output "============================================================================"

Write-Output "Making sure all runtime assemblies are pre-compiled if necessary..."

$env:PATH = "$([Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory());${env:PATH}"

[AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object {
  $path = $_.Location
  if ($path) {
    $name = Split-Path $path -Leaf
    Write-Output "Running ngen.exe on '$name'..."
    ngen.exe install $path /nologo | Out-Null
  }
}

removeDownloads

if (Test-Path "$poshDir\installed.txt") {
  Add-Content -Path "$poshDir\installed.txt" -Value "$(Get-Date)"
} else {
  Set-Content -Path "$poshDir\installed.txt" -Value "$(Get-Date)"
}
