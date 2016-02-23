$chefdk_bin = "C:\opscode\chefdk\bin"

if (Test-Path $chefdk_bin) {
    $env:Path = "$chefdk_bin;$env:PATH"
    $env:CHEFDK_ENV_FIX = 1
    & chef shell-init powershell | out-string | iex
    Import-Module chef -DisableNameChecking
}
    