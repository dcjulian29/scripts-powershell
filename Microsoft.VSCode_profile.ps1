################################################################################
# This profile is loaded with the Visual Studio Code "host" is executed.
################################################################################

$principal = new-object System.Security.principal.windowsprincipal($CurrentUser)
if ($principal.IsInRole("Administrators")) {
    $host.UI.RawUI.WindowTitle = "Administrator: PowerShell Prompt"
    $PromptAdmin="#"
    ColorTool.exe Treehouse.itermcolors
    $host.UI.RawUI.BackgroundColor = "DarkGray"
    $host.UI.RawUI.ForegroundColor = "Yellow"
} else {
    $host.UI.RawUI.WindowTitle = "PowerShell Prompt"
    ColorTool.exe purplepeter.itermcolors
}

################################################################################

Function prompt {
    $realLASTEXITCODE = $LASTEXITCODE
    $Host.UI.RawUI.BackgroundColor = $(Get-Host).UI.RawUI.BackgroundColor
    $originalColor = $Host.UI.RawUI.ForegroundColor

    Write-Host('§ ') -nonewline -foregroundcolor Yellow
    Write-Host($pwd) -nonewline -foregroundcolor Green
    Write-Host(" >") -foregroundcolor $originalColor

    $Host.UI.RawUI.ForegroundColor = $originalColor

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "  `b"
}
