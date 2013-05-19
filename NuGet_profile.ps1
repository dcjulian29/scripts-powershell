################################################################################
# This profile is loaded when the 
# nuget.exe Package Manager Console "host" is executed.
################################################################################

$globalScriptsPath = (Get-Item "$(Split-Path $profile)\NuGet\")

Get-ChildItem -Path $globalScriptsPath -Filter *.ps1 -Recurse | % `
{
  "Loading Script: $($_.Name)"
  . $_.FullName
}

Get-ChildItem -Path $globalScriptsPath -Filter *.psm1 -Recurse | % `
{
  "Loading Module: $($_.Name)"
  Import-Module $_.FullName -Force
}

function prompt()
{
	"§->";
}
