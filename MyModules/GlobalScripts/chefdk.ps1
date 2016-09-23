$chefdk_root = "C:\opscode\chefdk"

if (Test-Path "$chefdk_root\bin") {
    & "$chefdk_root\bin\chef.bat" shell-init powershell | Out-String | Invoke-Expression
    Import-Module "$chefdk_root\modules\chef\chef.psm1" -DisableNameChecking
}
    