################################################################################
# This profile is loaded with the PowerShell.exe "host" is executed.
################################################################################

$Global:PromptAdmin="$"

$batch = (Get-WmiObject Win32_Process -filter "ProcessID=$pid").CommandLine -match "-NonInteractive"
if (-not $batch)
{
  $principal = new-object System.Security.principal.windowsprincipal($CurrentUser)
  if ($principal.IsInRole("Administrators"))
  {
    $host.UI.RawUI.BackgroundColor = "DarkRed"
    $host.UI.RawUI.ForegroundColor = "Yellow"

    Set-Location C:\
    $host.UI.RawUI.WindowTitle = "Administrator: PowerShell Prompt"
    $PromptAdmin="#"
  }
  else
  {
    $host.UI.RawUI.WindowTitle = "PowerShell Prompt"
    $host.UI.RawUI.BackgroundColor = "Black"
    $host.UI.RawUI.ForegroundColor = "Green"
  }

  # Something keeps changing the PowerShell Console font and size from my preference, so
  # we'll enforce the defaults for all console windows.
  Remove-Item HKCU:\Console\* -Force
  
  # Changing the color of the console window doesn't take effect unless you clear the screen
  clear
  
  Write-Host "Loading Profile..."
}

# On domain joined machines, the home variable gets written with the "Home Directory" value
# from Active Directory. This causes problems with loading modules so, I'll "force" the value
# to match the value set be the UserProfile environment variable.
Set-Variable -Name Home -Value $env:UserProfile -Force

. "$(Split-Path $profile)\Load-ProfileModulesAndScripts.ps1" GlobalScripts
. "$(Split-Path $profile)\Load-ProfileModulesAndScripts.ps1" MyModules

Function prompt
{
  $realLASTEXITCODE = $LASTEXITCODE
  $originalColor = $Host.UI.RawUI.ForegroundColor
  $username = $currentuser.name.split('\')[1]
  
  Write-Host($username) -nonewline -foregroundcolor Yellow
  Write-Host("@") -nonewline -foregroundcolor $originalColor
  Write-Host($env:ComputerName) -nonewline -foregroundcolor Green
  Write-Host(":") -nonewline -foregroundcolor $originalColor
  Write-Host($pwd) -foregroundcolor Red

  # Posh-GIT gets confused when in the GIT metadata directory.
  if (-not $pwd.Path.EndsWith('.git'))
  {
    # Ignore writing VCS status if tools are not loaded.
    if (Get-Command Write-VcsStatus -errorAction SilentlyContinue)
    {
      Write-VcsStatus
    }
  }

  Write-Host($PromptAdmin) -nonewline -foregroundcolor Cyan
  
  # Reset color, which can be messed up by Enable-GitColors
  $Host.UI.RawUI.ForegroundColor = $originalColor

  $global:LASTEXITCODE = $realLASTEXITCODE
  return "  `b"
}

Function Edit-Profile
{
  notepad $profile
}

Function Reload-Profile
{
  . $profile
}

