$srcDir = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath content
$docDir = Join-Path -Path $env:UserProfile -ChildPath Documents
$pwshDir = Join-Path -Path $docDir -ChildPath PowerShell
$modulesDir = Join-Path -Path $pwshDir -ChildPath Modules

if (-not (Test-Path $pwshDir)) {
  New-Item -Path $pwshDir -ItemType Directory | Out-Null
}

if (-not (Test-Path $modulesDir)) {
  New-Item -Path $modulesDir -ItemType Directory | Out-Null
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

(Get-Content "$srcDir/remove.json" | ConvertFrom-Json) | ForEach-Object {
  if (Get-Module -Name $_ -ListAvailable -ErrorAction SilentlyContinue) {
    Uninstall-Module -Name $_ -AllVersions -Force -Confirm:$false -Verbose
  }
}

Write-Output "`n`n>>>-------->  Third-Party Modules...`n`n"

(Get-Content "$srcDir/thirdparty.json" | ConvertFrom-Json) | ForEach-Object {
  if (Get-Module -Name $_ -ListAvailable -ErrorAction SilentlyContinue) {
    Write-Output "`n`n>> Updating third-party '$_' module...`n`n"
    Update-Module -Name $_ -Confirm:$false -Verbose
  } else {
    Write-Output "`n`n>> Installing third-party '$_' module..."
    Install-Module -Name $_ -AllowClobber -Verbose
  }
}

Write-Output "`n`n>>>-------->  My modules...`n`n"

(Get-Content "$srcDir/mine.json" | ConvertFrom-Json) | ForEach-Object {
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

if (Test-Path "$pwshDir\installed.txt") {
  Add-Content -Path "$pwshDir\installed.txt" `
    -Value "$(Get-Date): modules-${env:ChocolateyPackageVersion}"
} else {
  Set-Content -Path "$pwshDir\installed.txt" `
    -Value "$(Get-Date): modules-${env:ChocolateyPackageVersion}"
}
