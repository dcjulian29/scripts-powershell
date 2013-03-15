################################################################################
# This profile is loaded with the PowerShell.exe "host" is executed.
################################################################################

$Global:PromptAdmin="$"

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

clear

# On domain joined machines, the home variable gets written with the "Home Directory" value
# from Active Directory. This causes problems with loading modules so, I'll "force" the value
# to match the value set be the UserProfile environment variable.
Set-Variable -Name Home -Value $env:UserProfile -Force

# On some systems, the modules will not load because they "can't be found"; so, let's
# explicitly add the modules path to the search path...
$env:PSModulePath = "$(Get-Item "$(Split-Path $profile)\Modules");" + $env:PSModulePath

if ($host.version.major -eq 3)
{
  #"Loading PowerShell Community Extensions - Version 3"
  #Import-Module Pscx -RequiredVersion 3.0.0.0
}
else
{
  "Loading PowerShell Community Extensions - Version 2"
  Import-Module Pscx
}

"Loading PowerShell Pack"
Import-Module PowerShellPack

#Import-Module PowerTab

$globalScriptsPath = (Get-Item "$(Split-Path $profile)\GlobalScripts\")

foreach ($directory in $globalScriptsPath.GetDirectories())
{
  foreach ($file in $directory.GetFiles("*.ps1"))
  {
    "Loading $($file.Name)"
    . $file.FullName
  }
}

function prompt
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


#if($error.Count -eq 0)
#{
#  clear
#}
#else
#{
#  ""
#  "Error(s) Loading Profile..."
#  ""
#  foreach ($e in $error)
#  {
#  $e.ToString()
#  ""
#  }
#  "For details, type error-details..."
#  ""
#  function error-details { $error }
#}
