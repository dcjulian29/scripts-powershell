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

if($env:TERM_PROGRAM -eq 'vscode') {
  . "$(Split-Path -Path $PROFILE -Parent)\Microsoft.VSCode_profile.ps1"
  exit
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

# Turn off the very broken and bad implementation of autocomplete provided by PSReadLine
Set-PSReadLineOption -PredictionSource None

#------------------------------------------------------------------------------

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

if (Get-Command gh -ErrorAction SilentlyContinue) {
  Invoke-Expression -Command $(gh completion -s powershell | Out-String)
}

if (Test-Path("${env:ChocolateyInstall}\helpers\chocolateyProfile.psm1")) {
  Import-Module "${env:ChocolateyInstall}\helpers\chocolateyProfile.psm1"
}

if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (&starship init powershell)
}
