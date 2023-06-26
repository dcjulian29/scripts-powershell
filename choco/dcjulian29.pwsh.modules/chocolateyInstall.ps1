$srcDir = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath content
$docDir = Join-Path -Path $env:UserProfile -ChildPath Documents
$pwshDir = Join-Path -Path $docDir -ChildPath PowerShell

if (-not (Test-Path $pwshDir)) {
  New-Item -Path $pwshDir -ItemType Directory | Out-Null
}

Write-Output ">>>-------->  Configuring Package Repositories..."

Import-Module PackageManagement

Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

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

Write-Output " `n-------->  Remove Modules..."

(Get-Content "$srcDir/remove.json" | ConvertFrom-Json) | ForEach-Object {
  if (Get-Module -Name $_ -ListAvailable -ErrorAction SilentlyContinue) {
    Write-Output "   -->  Removing '$_' module..."
    Uninstall-Module -Name $_ -AllVersions -Force -Confirm:$false
  }
}

Write-Output " `n-------->  Third-Party Modules..."

(Get-Content "$srcDir/thirdparty.json" | ConvertFrom-Json) | ForEach-Object {
  if (Get-Module -Name $_ -ListAvailable -ErrorAction SilentlyContinue) {
    Write-Output "   -->  Updating third-party '$_' module..."
    Update-Module -Name $_ -Confirm:$false
  } else {
    Write-Output "   -->  Installing third-party '$_' module..."
    Install-Module -Name $_ -AllowClobber
  }
}

Write-Output " `n-------->  My Modules..."

(Get-Content "$srcDir/mine.json" | ConvertFrom-Json) | ForEach-Object {
  if (Get-Module -Name $_ -ListAvailable -ErrorAction SilentlyContinue) {
    Write-Output "   -->  Updating my '$_' module..."
    Update-Module -Name $_ -Confirm:$false
  } else {
    Write-Output "   -->  Installing my '$_' module..."
    Install-Module -Name $_ -Repository "dcjulian29-powershell" -AllowClobber -Verbose
  }
}

Pop-Location

Write-Output " `nRefreshing the list of available modules..."

Get-Module -ListAvailable | Out-Null

Write-Output "============================================================================"

Write-Output (Get-InstalledModule `
  | Select-Object Name,Version,PublishedDate,RepositorySourceLocation `
  | Sort-Object PublishedDate -Descending `
  | Format-Table | Out-String)

Write-Output "============================================================================"

if (Test-Path "$pwshDir\installed.txt") {
  Add-Content -Path "$pwshDir\installed.txt" `
    -Value "$(Get-Date): modules-${env:ChocolateyPackageVersion}"
} else {
  Set-Content -Path "$pwshDir\installed.txt" `
    -Value "$(Get-Date): modules-${env:ChocolateyPackageVersion}"
}
