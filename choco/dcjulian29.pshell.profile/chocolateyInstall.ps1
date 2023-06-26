$srcDir = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath content
$docDir = Join-Path -Path $env:UserProfile -ChildPath Documents
$poshDir = Join-Path -Path $docDir -ChildPath WindowsPowerShell
$binDir = Join-Path -Path $env:SYSTEMDRIVE -ChildPath bin

if (-not (Test-Path $binDir)) {
  New-Item -Type Directory -Path $binDir | Out-Null
}

if (-not (Test-Path $poshDir)) {
  New-Item -Path $poshDir -ItemType Directory | Out-Null
}

#------------------------------------------------------------------------------

Write-Output "`nUpdating Execution Policies for 32-bit PowerShell..."

& ${env:SystemRoot}\SysWOW64\WindowsPowerShell\v1.0\powershell.exe `
  "Set-ExecutionPolicy RemoteSigned" | Out-Null
& ${env:SystemRoot}\SysWOW64\WindowsPowerShell\v1.0\powershell.exe `
  "Set-ExecutionPolicy RemoteSigned" | Out-Null
& ${env:SystemRoot}\SysWOW64\WindowsPowerShell\v1.0\powershell.exe `
  "Set-ExecutionPolicy RemoteSigned" | Out-Null

Write-Output "`nUpdating Execution Policies for 64-bit PowerShell..."
  # 64-bit
& ${env:SystemRoot}\System32\WindowsPowerShell\v1.0\powershell.exe `
  "Set-ExecutionPolicy RemoteSigned" | Out-Null
& ${env:SystemRoot}\System32\WindowsPowerShell\v1.0\powershell.exe `
  "Set-ExecutionPolicy RemoteSigned" | Out-Null
& ${env:SystemRoot}\System32\WindowsPowerShell\v1.0\powershell.exe `
  "Set-ExecutionPolicy RemoteSigned" | Out-Null


#------------------------------------------------------------------------------

Write-Output "`nInstalling binary scripts to '$binDir' ..."

Copy-Item -Path "$srcDir/_IsElevated.cmd" -Destination $binDir -Force
Copy-Item -Path "$srcDir/elevate.bat" -Destination $binDir -Force
Copy-Item -Path "$srcDir/elevate.js" -Destination $binDir -Force
Copy-Item -Path "$srcDir/invis.js" -Destination $binDir -Force

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

if (-not (Test-Path -Path $poshDir)) {
  New-Item -Path $poshDir -ItemType Directory -Force | Out-Null
}

Write-Output "Installing profile to '$poshDir' ..."

@(
  "$srcDir/Microsoft.PowerShell_profile.ps1"
  "$srcDir/Microsoft.VSCode_profile.ps1"
  "$srcDir/profile.ps1"
) | ForEach-Object {
  Copy-Item -Path $_ -Destination $poshDir -Recurse -Force
}

if (Test-Path "$poshDir\installed.txt") {
  Add-Content -Path "$poshDir\installed.txt" `
    -Value "$(Get-Date): profile-${env:ChocolateyPackageVersion}"
} else {
  Set-Content -Path "$poshDir\installed.txt" `
    -Value "$(Get-Date): profile-${env:ChocolateyPackageVersion}"
}
