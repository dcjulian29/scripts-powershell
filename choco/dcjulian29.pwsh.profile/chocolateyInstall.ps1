$srcDir = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath content
$docDir = Join-Path -Path $env:UserProfile -ChildPath Documents
$pwshDir = Join-Path -Path $docDir -ChildPath PowerShell

#------------------------------------------------------------------------------

if (Test-Path "$pwshDir\Profile.ps1") {
  Write-Output "Removing previous installed profile..."

  @(
    "$pwshDir\Microsoft.PowerShell_profile.ps1"
    "$pwshDir\Microsoft.VSCode_profile.ps1"
    "$pwshDir\profile.ps1"
  ) | ForEach-Object {
    if (Test-Path $_) {
      Remove-Item -Path $_ -Force -ErrorAction SilentlyContinue
    }
  }
}

Write-Output "Installing profile to '$pwshDir' ..."

@(
  "$srcDir/Microsoft.PowerShell_profile.ps1"
  "$srcDir/Microsoft.VSCode_profile.ps1"
  "$srcDir/profile.ps1"
) | ForEach-Object {
  Copy-Item -Path $_ -Destination $pwshDir -Recurse -Force
}

if (Test-Path "$pwshDir\installed.txt") {
  Add-Content -Path "$pwshDir\installed.txt" `
    -Value "Updated: ${env:ChocolateyPackageVersion} on $(Get-Date)"
} else {
  Set-Content -Path "$pwshDir\installed.txt" `
    -Value "Installed: ${env:ChocolateyPackageVersion} on $(Get-Date)"
}
