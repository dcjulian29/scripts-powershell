################################################################################
# This profile is loaded with the PowerShell.exe "host" is executed.
################################################################################

$Global:PromptAdmin="$"

$batch = (Get-WmiObject Win32_Process -filter "ProcessID=$pid").CommandLine -match "-NonInteractive"
if (-not $batch) {
  $principal = new-object System.Security.principal.windowsprincipal($CurrentUser)
  if ($principal.IsInRole("Administrators")) {
    $host.UI.RawUI.BackgroundColor = "DarkRed"
    $host.UI.RawUI.ForegroundColor = "Yellow"

    Set-Location C:\
    $host.UI.RawUI.WindowTitle = "Administrator: PowerShell Prompt"
    $PromptAdmin="#"
  } else {
    $host.UI.RawUI.WindowTitle = "PowerShell Prompt"
    $host.UI.RawUI.BackgroundColor = "Black"
    $host.UI.RawUI.ForegroundColor = "Green"
  }

  # Something keeps changing the PowerShell Console font and size from my preference, so
  # we'll enforce the defaults for all console windows.
  Remove-Item HKCU:\Console\* -Force
  
  # Changing the color of the console window doesn't take effect unless you clear the screen
  clear

  Write-Host "  ____                        ____  _          _ _"
  Write-Host " |  _ \ _____      _____ _ __/ ___|| |__   ___| | |"
  Write-Host " | |_) / _ \ \ /\ / / _ \ '__\___ \| '_ \ / _ \ | |"
  Write-Host " |  __/ (_) \ V  V /  __/ |   ___) | | | |  __/ | |"
  Write-Host " |_|   \___/ \_/\_/ \___|_|  |____/|_| |_|\___|_|_|"
  Write-Host ""
  Write-Host "Loading Profile..."
}

# On domain joined machines, the home variable gets written with the "Home Directory" value
# from Active Directory.
Set-Variable -Name Home -Value $env:UserProfile -Force

# My modules used to be executed once for each module file where the path was updated for various
# tools. Since they are now being dynamically loaded I have the update the path here...
Add-DevPath

Function prompt {
  $realLASTEXITCODE = $LASTEXITCODE
  $originalColor = $Host.UI.RawUI.ForegroundColor
  $username = $currentuser.name.split('\')[1]
  
  Write-Host($username) -nonewline -foregroundcolor Yellow
  Write-Host("@") -nonewline -foregroundcolor $originalColor
  Write-Host($env:ComputerName) -nonewline -foregroundcolor Green
  Write-Host(":") -nonewline -foregroundcolor $originalColor
  Write-Host($pwd) -foregroundcolor Red

  # Don't show Git Status in Admin shell
  if (-not ($principal.IsInRole("Administrators"))) {
      # In prior editions of the Posh GIT modules,
      #    it got confused when in the GIT metadata directory.
      if (-not $pwd.Path.EndsWith('.git')) {
        # Ignore writing VCS status if tools are not loaded.
        if (Get-Command Write-VcsStatus -errorAction SilentlyContinue) {
            # I like bright colors. The dark green and red are hard to see on black background.
            $s = $global:GitPromptSettings
            
            if ($s.WorkingForegroundColor -ne $s.WorkingForegroundBrightColor) {
                $s.LocalDefaultStatusForegroundColor = $s.LocalDefaultStatusForegroundBrightColor
                $s.LocalWorkingStatusForegroundColor = $s.LocalWorkingStatusForegroundBrightColor
                $s.BeforeIndexForegroundColor = $s.BeforeIndexForegroundBrightColor
                $s.IndexForegroundColor = $s.IndexForegroundBriteColor
                $s.WorkingForegroundColor = $s.WorkingForegroundBrightColor
                $s.EnableWindowTitle = ""
                $s.BeforeText = "["
            }
            
          Write-VcsStatus
        }
      }
  }

  Write-Host($PromptAdmin) -nonewline -foregroundcolor Cyan
  
  # Reset color, which can be messed up by Enable-GitColors
  $Host.UI.RawUI.ForegroundColor = $originalColor

  $global:LASTEXITCODE = $realLASTEXITCODE
  return "  `b"
}

Function Edit-Profile {
  notepad $profile
}

Function Reload-Profile {
  . $profile
}

Function Get-LastExecutionTime {
    $command = Get-History -Count 1    
    $command.EndExecutionTime - $command.StartExecutionTime
}
