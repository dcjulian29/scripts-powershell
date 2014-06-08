param
(
  [Parameter(Mandatory = $true,
             ValueFromPipeline = $true)]   
  [array]$Directory
)

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
