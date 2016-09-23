################################################################################
# This profile is loaded when the 
# nuget.exe Package Manager Console "host" is executed.
################################################################################

$path = Get-Item "$(Split-Path $profile)\NuGet"

Get-ChildItem -Path $path -Filter *.ps1 -Recurse | % `
{
    . $_.FullName
}

Get-ChildItem -Path $path -Filter *.psm1 -Recurse | % `
{
    Import-Module $_.FullName -Force -DisableNameChecking
}

function prompt()
{
	"§->";
}
