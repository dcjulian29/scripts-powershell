param
(
  [Parameter(Mandatory = $true,
             ValueFromPipeline = $true)]   
  [array]$Directory
)

$globalScriptsPath = Get-Item "$(Split-Path $profile)\$($Directory)\"

Get-ChildItem -Path $globalScriptsPath -Filter *.ps1 -Recurse | % `
{
    Write-Verbose "Loading Script: $($_.Name)"
    . $_.FullName
}

Get-ChildItem -Path $globalScriptsPath -Filter *.psm1 -Recurse | % `
{
    Write-Verbose "Loading Module: $($_.Name)"
    Import-Module $_.FullName -Force
}
