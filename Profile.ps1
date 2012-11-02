################################################################################
# This profile is loaded when any "host" is executed. AKA. ALWAYS...
################################################################################

$Global:CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()

$env:Home = $env:UserProfile
$env:HomeDrive = $env:UserProfile.Split(":")[0] + ":"
$env:HomePath = $env:UserProfile.Split(":")[1]
$env:Path = "c:\bin;$env:Path"
