. "$(Split-Path $profile)\Load-ProfileModulesAndScripts.ps1" PowerShellISE
. "$(Split-Path $profile)\Load-ProfileModulesAndScripts.ps1" GlobalScripts
. "$(Split-Path $profile)\Load-ProfileModulesAndScripts.ps1" MyModules

Set-Location $env:USERPROFILE

$principal = new-object System.Security.principal.windowsprincipal($CurrentUser)

if ($principal.IsInRole("Administrators")) {
    $PromptAdmin = "#"
} else {
    $PromptAdmin = "$"
}

function prompt()
{
	"$PromptAdmin "
}
