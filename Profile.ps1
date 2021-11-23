################################################################################
# This profile is loaded when any "host" is executed. AKA. ALWAYS...
################################################################################

$Global:CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()

if (($env:Home).Length -eq 0) {
  $env:Home = $env:UserProfile
}

$env:HomeDrive = ($env:Home).Split(":")[0] + ":"
$env:HomePath = ($env:Home).Split(":")[1]

$binarydirectory = "$env:SYSTEMDRIVE\Tools\binaries"

if (-not ($env:PATH).Contains($binarydirectory)) {
  $env:PATH = "$binarydirectory;$($env:PATH)"
}

if (Test-Path alias:wget) {
  Remove-Item alias:wget
}

if (Test-Path alias:curl) {
  Remove-Item alias:curl
}

# Make sure my custom PowerShell modules are available.
if ((-not ($env:PSModulePath).Contains("$(Split-Path $profile)\MyModules"))) {
    $PSModulePath = "$(Split-Path $profile)\MyModules;$($env:PSModulePath)"

    $env:PSModulePath = $PSModulePath

    Get-Module -ListAvailable | Out-Null

    Invoke-Expression "[Environment]::SetEnvironmentVariable('PSModulePath', '$PSModulePath', 'User')"
}
