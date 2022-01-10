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

if ((-not ($env:PSModulePath).Contains("$(Split-Path $profile)\MyModules"))) {
  if (Test-Path "$(Split-Path $profile)\MyModules") {
    $PSModulePath = "$(Split-Path $profile)\MyModules;$($env:PSModulePath)"

    $env:PSModulePath = $PSModulePath

    Get-Module -ListAvailable | Out-Null
  }
}
