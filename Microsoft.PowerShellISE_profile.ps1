# PowerShell ISE Profile Script

. "$(Split-Path $profile)\Load-ProfileModulesAndScripts.ps1" PowerShellISE
. "$(Split-Path $profile)\Load-ProfileModulesAndScripts.ps1" GlobalScripts
. "$(Split-Path $profile)\Load-ProfileModulesAndScripts.ps1" MyModules

Set-Location C:\
