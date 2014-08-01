param
(
  [Parameter(Mandatory = $true,
             ValueFromPipeline = $true)]   
  [array]$Directory
)

# On some systems, modules will not load because they "can't be found";
#  so, let's explicitly add the modules path to the search path...
$PSModules = "$(Split-Path $profile)\Modules"

if (-not ($env:PSModulePath -split ';' -contains $PSModules)) {
    $env:PSModulePath = "$PSModules;$($env:PSModulePath)"
}

$modulesPath = Get-Item "$(Split-Path $profile)\$($Directory)\"

Get-ChildItem -Path $modulesPath -Filter *.ps1 -Recurse | % `
{
    Write-Verbose "Loading Script: $($_.Name)"
    . $_.FullName
}

Get-ChildItem -Path $modulesPath -Filter *.psm1 -Recurse | % `
{
    Write-Verbose "Loading Module: $($_.Name)"
    Import-Module $_.FullName -Force -DisableNameChecking
}
