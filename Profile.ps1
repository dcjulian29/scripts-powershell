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

Set-Alias -Name go -Value gd
