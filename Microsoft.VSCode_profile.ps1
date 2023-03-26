################################################################################
# This profile is loaded with the Visual Studio Code "host" is executed.
################################################################################

Function prompt {
    $realLASTEXITCODE = $LASTEXITCODE
    $Host.UI.RawUI.BackgroundColor = $(Get-Host).UI.RawUI.BackgroundColor
    $originalColor = $Host.UI.RawUI.ForegroundColor

    Write-Host('§ ') -nonewline -foregroundcolor Yellow
    Write-Host($pwd) -foregroundcolor Green
    Write-Host(">") -nonewline -foregroundcolor $originalColor

    $Host.UI.RawUI.ForegroundColor = $originalColor

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "  `b"
}
