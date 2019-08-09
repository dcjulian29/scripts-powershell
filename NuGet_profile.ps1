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

function prompt() {
    $realLASTEXITCODE = $LASTEXITCODE
    $Host.UI.RawUI.BackgroundColor = $(Get-Host).UI.RawUI.BackgroundColor
    $originalColor = $Host.UI.RawUI.ForegroundColor

    Write-Host('§') -nonewline -foregroundcolor Yellow
    Write-Host('-') -nonewline -foregroundcolor Green
    Write-Host(">") -foregroundcolor $originalColor

    $Host.UI.RawUI.ForegroundColor = $originalColor

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "  `b"
}
