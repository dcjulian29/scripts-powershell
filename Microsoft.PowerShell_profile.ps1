################################################################################
# This profile is loaded with the PowerShell.exe "host" is executed.
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

$Global:PromptAdmin="$"

if ($PSVersionTable.PSEdition -eq "Core") {
    $batch = $false
} else {
    $batch = (Get-WmiObject Win32_Process -filter "ProcessID=$pid").CommandLine -match "-NonInteractive"
}

if (-not $batch) {
    # Sometimes color settings get set based on subkeys in HKCU:\Console, remove them
    Remove-Item -Path HKCU:\Console\* -Recurse -Force

    $windowsTerminal = IsWindowsTerminal -ChildProcess (Get-Process -Id $PID)

    $principal = new-object System.Security.principal.windowsprincipal($CurrentUser)
    if ($principal.IsInRole("Administrators")) {
        Set-Location C:\
        $host.UI.RawUI.WindowTitle = "Administrator: PowerShell Prompt"
        $PromptAdmin="#"
        if ($windowsTerminal) {
            ColorTool.exe -q -x Treehouse.itermcolors
        } else {
            ColorTool.exe -q Treehouse.itermcolors
            $host.UI.RawUI.BackgroundColor = "DarkGray"
            $host.UI.RawUI.ForegroundColor = "Yellow"
        }
    } else {
        $host.UI.RawUI.WindowTitle = "PowerShell Prompt"
        if ($windowsTerminal) {
            ColorTool.exe -q -x purplepeter.itermcolors
        } else {
            ColorTool.exe -q purplepeter.itermcolors
        }
    }

    if ((Get-Command Set-PSReadLineOption).Version.Major -lt 2) {
        Set-PSReadLineOption -TokenKind Parameter -ForegroundColor Cyan
        Set-PSReadlineOption -TokenKind Operator -ForegroundColor Green
    } else {
        Set-PSReadLineOption -Colors @{ "Parameter" = "$([char]0x1b)[1;35m"  }
        Set-PSReadLineOption -Colors @{ "Operator" = "$([char]0x1b)[1;32m"  }
    }

    if ($PSVersionTable.PSEdition -eq "Core") {
        Write-Output "    ____                          _____ __         ____   ______              "
        Write-Output "   / __ \____ _      _____  _____/ ___// /_  ___  / / /  / ____/___  ________ "
        Write-Output "  / /_/ / __ \ | /| / / _ \/ ___/\__ \/ __ \/ _ \/ / /  / /   / __ \/ ___/ _ \"
        Write-Output " / ____/ /_/ / |/ |/ /  __/ /   ___/ / / / /  __/ / /  / /___/ /_/ / /  /  __/"
        Write-Output "/_/    \____/|__/|__/\___/_/   /____/_/ /_/\___/_/_/   \____/\____/_/   \___/ "
        Write-Output ""
    } else {
        Write-Output "  ____                        ____  _          _ _"
        Write-Output " |  _ \ _____      _____ _ __/ ___|| |__   ___| | |"
        Write-Output " | |_) / _ \ \ /\ / / _ \ '__\___ \| '_ \ / _ \ | |"
        Write-Output " |  __/ (_) \ V  V /  __/ |   ___) | | | |  __/ | |"
        Write-Output " |_|   \___/ \_/\_/ \___|_|  |____/|_| |_|\___|_|_|"
        Write-Output ""
    }
}

# Load the Posh-GIT module if it exist
if (Test-Path "C:\tools\poshgit") {
    $poshgit = Get-ChildItem -Path "C:\tools\poshgit" |  `
        Where-Object { $_.psIsContainer } | `
        Sort-Object { $_.CreationTime } -Descending

    Import-Module "C:\tools\poshgit\$($poshgit.name)\src\posh-git.psd1"
}

# Argument Completers

if (Get-Command winget -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)

            [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
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

################################################################################

function prompt {
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
