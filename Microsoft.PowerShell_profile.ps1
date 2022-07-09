################################################################################
# This profile is loaded when powershell.exe and pwsh.exe is executed.
################################################################################

function IsWindowsTerminal ($ChildProcess) {
  if (-not ($ChildProcess)) {
    return $false
  } else {
    if ($ChildProcess.ProcessName -eq 'WindowsTerminal') {
      return $true
    } else {
      return IsWindowsTerminal -ChildProcess $ChildProcess.Parent
    }
  }
}

################################################################################

$env:PromptAdmin="$"

if ($PSVersionTable.PSEdition -eq "Core") {
  $batch = $false
} else {
  $batch = (Get-WmiObject Win32_Process -filter "ProcessID=$pid").CommandLine `
    -match "-NonInteractive"
}

if (-not $batch) {
  $principal = New-Object System.Security.Principal.WindowsPrincipal($global:CurrentUser)
  if ($principal.IsInRole("Administrators")) {
    $env:PromptAdmin = "#"
  }

  if ((Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue).Version.Major -lt 2) {
    Set-PSReadLineOption -TokenKind Parameter -ForegroundColor Cyan
    Set-PSReadlineOption -TokenKind Operator -ForegroundColor Green
  } else {
    if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue) {
      Set-PSReadLineOption -Colors @{ "Parameter" = "$([char]0x1b)[1;35m"  }
      Set-PSReadLineOption -Colors @{ "Operator" = "$([char]0x1b)[1;32m"  }
    }
  }

  $OutputEncoding = [Console]::InputEncoding `
                  = [Console]::OutputEncoding `
                  = [System.Text.Utf8Encoding]::new()

  # if ($PSVersionTable.PSEdition -eq "Core") {
  #   Write-Host "    ____                          _____ __         ____   ______              " -ForegroundColor Yellow
  #   Write-Host "   / __ \____ _      _____  _____/ ___// /_  ___  / / /  / ____/___  ________ " -ForegroundColor Yellow
  #   Write-Host "  / /_/ / __ \ | /| / / _ \/ ___/\__ \/ __ \/ _ \/ / /  / /   / __ \/ ___/ _ \" -ForegroundColor Yellow
  #   Write-Host " / ____/ /_/ / |/ |/ /  __/ /   ___/ / / / /  __/ / /  / /___/ /_/ / /  /  __/" -ForegroundColor Yellow
  #   Write-Host "/_/    \____/|__/|__/\___/_/   /____/_/ /_/\___/_/_/   \____/\____/_/   \___/ " -ForegroundColor Yellow
  #   Write-Host ""
  # } else {
  #   Write-Host "  ____                        ____  _          _ _ " -ForegroundColor Yellow
  #   Write-Host " |  _ \ _____      _____ _ __/ ___|| |__   ___| | |" -ForegroundColor Yellow
  #   Write-Host " | |_) / _ \ \ /\ / / _ \ '__\___ \| '_ \ / _ \ | |" -ForegroundColor Yellow
  #   Write-Host " |  __/ (_) \ V  V /  __/ |   ___) | | | |  __/ | |" -ForegroundColor Yellow
  #   Write-Host " |_|   \___/ \_/\_/ \___|_|  |____/|_| |_|\___|_|_|" -ForegroundColor Yellow
  #   Write-Host ""
  # }
}

#------------------------------------------------------------------------------

# Load the Posh-GIT module if it exist
# if (Test-Path "$env:SymtemDrive/tools/poshgit") {
#   $poshgit = Get-ChildItem -Path "$env:SymtemDrive/tools/poshgit" |  `
#     Where-Object { $_.psIsContainer } | `
#     Sort-Object { $_.CreationTime } -Descending

#   Import-Module "$env:SymtemDrive/tools/poshgit/$($poshgit.name)/src/posh-git.psd1"

#   # The default colors are hard to see on dark background so set bright colors.
#   $s = $global:GitPromptSettings

#   if ($s.WorkingForegroundColor -ne $s.WorkingForegroundBrightColor) {
#     $s.LocalDefaultStatusForegroundColor = $s.LocalDefaultStatusForegroundBrightColor
#     $s.LocalWorkingStatusForegroundColor = $s.LocalWorkingStatusForegroundBrightColor
#     $s.BeforeIndexForegroundColor = $s.BeforeIndexForegroundBrightColor
#     $s.IndexForegroundColor = $s.IndexForegroundBriteColor
#     $s.WorkingForegroundColor = $s.WorkingForegroundBrightColor
#     $s.EnableWindowTitle = ""
#     $s.BeforeText = "["

#     $global:GitPromptSettings = $s
#   }
# }

# Argument Completers
if (Get-Command winget -ErrorAction SilentlyContinue) {
  Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')

    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition `
      | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
      }
  }
}

if (Get-Command dotnet -ErrorAction SilentlyContinue) {
  Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)

    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
      [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
  }
}

if (Test-Path("${env:ChocolateyInstall}\helpers\chocolateyProfile.psm1")) {
  Import-Module "${env:ChocolateyInstall}\helpers\chocolateyProfile.psm1"
}

#------------------------------------------------------------------------------

if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (&starship init powershell)
}
