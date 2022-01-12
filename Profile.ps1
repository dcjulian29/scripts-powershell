################################################################################
# This profile is loaded when any "host" is executed. AKA. ALWAYS...
################################################################################

$global:CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()

if (-not ($env:PATH).Contains("$env:SYSTEMDRIVE/tools/binaries")) {
  if (Test-Path "${env:SYSTEMDRIVE}/tools/binaries") {
    $env:PATH = "${env:SYSTEMDRIVE}/tools/binaries;$($env:PATH)"
  }
}
if (-not ($env:PATH).Contains("$env:SYSTEMDRIVE/bin")) {
  if (Test-Path "${env:SYSTEMDRIVE}/bin") {
    $env:PATH = "${env:SYSTEMDRIVE}/bin;$($env:PATH)"
  }
}

$docDir = Join-Path -Path $env:UserProfile -ChildPath Documents
$poshDir = Join-Path -Path $docDir -ChildPath WindowsPowerShell
$modulesDir = Join-Path -Path $poshDir -ChildPath Modules

if ((-not ($env:PSModulePath).Contains($modulesDir))) {
  $PSModulePath = "$modulesDir;$([Environment]::GetEnvironmentVariable('PSModulePath', 'User'))"

  $env:PSModulePath = $PSModulePath + [Environment]::GetEnvironmentVariable('PSModulePath', 'Machine')
}
