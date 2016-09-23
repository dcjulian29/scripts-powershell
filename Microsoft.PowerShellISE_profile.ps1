$path = Get-Item "$(Split-Path $profile)\PowerShellISE"

Get-ChildItem -Path $path -Filter *.ps1 -Recurse | % `
{
    . $_.FullName
}

Get-ChildItem -Path $path -Filter *.psm1 -Recurse | % `
{
    Import-Module $_.FullName -Force -DisableNameChecking
}

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
