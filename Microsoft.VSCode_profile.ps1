################################################################################
# This profile is loaded with the Visual Studio Code "host" is executed.
################################################################################

$principal = new-object System.Security.principal.windowsprincipal($CurrentUser)
if ($principal.IsInRole("Administrators")) {
    ColorTool.exe Treehouse.itermcolors
        $host.UI.RawUI.BackgroundColor = "DarkGray"
        $host.UI.RawUI.ForegroundColor = "Yello"
  } else {
    ColorTool.exe purplepeter.itermcolors
  }

# On domain joined machines, the home variable gets written with the "Home Directory" value
# from Active Directory.
Set-Variable -Name Home -Value $env:UserProfile -Force

################################################################################

Function prompt {
  $realLASTEXITCODE = $LASTEXITCODE
  $Host.UI.RawUI.BackgroundColor = $(Get-Host).UI.RawUI.BackgroundColor
  $originalColor = $Host.UI.RawUI.ForegroundColor

  Write-Host($pwd) -foregroundcolor Red

  Write-Host('>') -nonewline -foregroundcolor Cyan

  $Host.UI.RawUI.ForegroundColor = $originalColor

  $global:LASTEXITCODE = $realLASTEXITCODE
  return "  `b"
}
