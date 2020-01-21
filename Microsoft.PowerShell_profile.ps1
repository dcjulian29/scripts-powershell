################################################################################
# This profile is loaded with the PowerShell.exe "host" is executed.
################################################################################

$Global:PromptAdmin="$"

$batch = (Get-WmiObject Win32_Process -filter "ProcessID=$pid").CommandLine -match "-NonInteractive"
if (-not $batch) {
   # Sometimes color settings get set based on subkeys in HKCU:\Console, remove them
   Remove-Item -Path HKCU:\Console\* -Recurse -Force
   $principal = new-object System.Security.principal.windowsprincipal($CurrentUser)
   if ($principal.IsInRole("Administrators")) {
       Set-Location C:\
       $host.UI.RawUI.WindowTitle = "Administrator: PowerShell Prompt"
       $PromptAdmin="#"
       ColorTool.exe -q Treehouse.itermcolors
       $host.UI.RawUI.BackgroundColor = "DarkGray"
       $host.UI.RawUI.ForegroundColor = "Yellow"
       if ((Get-Host).Version.Build -lt 18362) {
           Clear-Host
       }
   } else {
       $host.UI.RawUI.WindowTitle = "PowerShell Prompt"
       ColorTool.exe -q purplepeter.itermcolors
   }
   if ((Get-Command Set-PSReadLineOption).Version.Major -lt 2) {
       Set-PSReadLineOption -TokenKind Parameter -ForegroundColor Cyan
       Set-PSReadlineOption -TokenKind Operator -ForegroundColor Green
   } else {
       Set-PSReadLineOption -Colors @{ "Parameter" = "$([char]0x1b)[1;35m"  }
       Set-PSReadLineOption -Colors @{ "Operator" = "$([char]0x1b)[1;32m"  }
   }

    Write-Output "  ____                        ____  _          _ _"
    Write-Output " |  _ \ _____      _____ _ __/ ___|| |__   ___| | |"
    Write-Output " | |_) / _ \ \ /\ / / _ \ '__\___ \| '_ \ / _ \ | |"
    Write-Output " |  __/ (_) \ V  V /  __/ |   ___) | | | |  __/ | |"
    Write-Output " |_|   \___/ \_/\_/ \___|_|  |____/|_| |_|\___|_|_|"
    Write-Output ""
}

################################################################################

Function prompt {
    $realLASTEXITCODE = $LASTEXITCODE
    $Host.UI.RawUI.BackgroundColor = $(Get-Host).UI.RawUI.BackgroundColor
    $originalColor = $Host.UI.RawUI.ForegroundColor
    $username = $currentuser.name.split('\')[1]

    Write-Host($username) -nonewline -foregroundcolor Yellow
    Write-Host("@") -nonewline -foregroundcolor $originalColor
    Write-Host($env:ComputerName) -nonewline -foregroundcolor Green
    Write-Host(":") -nonewline -foregroundcolor $originalColor
    Write-Host($pwd) -foregroundcolor Red

    # Don't show Git Status in Admin shell but do on Work Laptop with UAC disabled
    if  ((-not ($principal.IsInRole("Administrators"))) -or ($env:COMPUTERNAME -like "RMT*")) {
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

# Load the Posh-GIT module if it exist
if (Test-Path "C:\tools\poshgit") {
    $poshgit = Get-ChildItem -Path "C:\tools\poshgit" |  `
        Where-Object { $_.psIsContainer } | `
        Sort-Object { $_.CreationTime } -Descending

    Import-Module "C:\tools\poshgit\$poshgit\src\posh-git.psd1"
}
