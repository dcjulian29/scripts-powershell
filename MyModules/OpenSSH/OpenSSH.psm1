function getServerPackageName {
    return (Get-WindowsCapability -online `
        | Where-Object { $_.Name -like "*OpenSSH.Server*" }).Name
}

function getClientPackageName {
    return (Get-WindowsCapability -online `
        | Where-Object { $_.Name -like "*OpenSSH.Client*" }).Name
}

###############################################################################

function Add-OpenSSHClient {
    if (-not (Test-OpenSSHClient)) {
        if (Test-Elevation) {
            Add-WindowsCapability -Online -Name $(getClientPackageName)
        }
    }
}

function Add-OpenSSHServer {
    if (-not (Test-OpenSSHServer)) {
        if (Test-Elevation) {
            Add-WindowsCapability -Online -Name $(getServerPackageName)

            if (Test-OpenSSHServer) {
                Set-OpenSSHDefaultShell "$env:windir\System32\WindowsPowerShell\v1.0\powershell.exe"

                if (Get-Service -Name 'sshd') {
                    Set-Service -Name 'sshd' -StartupType 'Automatic'
                    Start-Service -Name 'sshd'
                }
            }
        }
    }
}

function Disable-OpenSSHServer {
     if (Test-OpenSSHServer) {
        if (Test-Elevation) {
            if (Get-Service -Name 'sshd') {
                Set-Service -Name 'sshd' -StartupType 'Disabled'
                if (Test-OpenSSHService) {
                    Stop-Service -Name 'sshd'
                }
            }
        }
    }
}

function Get-OpenSSHDefaultShell {
    if (Test-OpenSSHServer) {
        if (Test-Path "HKLM:\SOFTWARE\OpenSSH") {
            (Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell).DefaultShell
        }
    }
}

function Get-OpenSSHDefaultShellOptions {
    if (Test-Path "HKLM:\SOFTWARE\OpenSSH") {
        $present = Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
            | Select-Object -ExpandProperty 'DefaultShellCommandOption' `
                -ErrorAction SilentlyContinue | Out-Null

        if ($present) {
            (Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
                -Name DefaultShellCommandOption).DefaultShellCommandOption
        }
    }
}

function Invoke-OpenSCP {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RemoteHost,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationPath,
        [string]$RemoteUser,
        [string]$IdentityFile,
        [int32]$Port,
        [switch]$Recurse
    )

    $scp = "$env:windir\System32\OpenSSH\scp.exe"
    $etc = "$env:SystemDrive\etc\ssh"

    $arguments = "-F ""$etc\config"""

    if (($null = $IdentityFile) -and (Test-Path "$env:SystemDrive\etc\ssh\id_$RemoteHost")) {
        $IdentityFile = "$env:SystemDrive\etc\ssh\id_$RemoteHost"
    }

    if ($IdentifyFile) {
        $arguments += " -i ""$IdentityFile"""
    }

    if ($Recurse) {
        $arguments += " -r"
    }

    if ($Port) {
        $arguments += " -P $Port"
    }

    $arguments += " $SourcePath"

    if ($RemoteUser) {
        $RemoteHost = "$RemoteUser@$RemoteHost"
    }

    $arguments += " $($RemoteHost):$DestinationPath"

    Start-Process -FilePath $scp -ArgumentList $arguments -NoNewWindow -Wait
}

Set-Alias scp Invoke-OpenSCP

function Invoke-OpenSSH {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Remote,
        [string]$IdentityFile
    )

    $ssh = "$env:windir\System32\OpenSSH\ssh.exe"
    $etc = "$env:SystemDrive\etc\ssh"

    if (-not $IdentityFile) {
        if ($Remote.Contains("@")) {
            $ComputerName = $Remote.Split('@')[1]
        } else {
            $ComputerName = $Remote
        }

        $file = "$env:SystemDrive\etc\ssh\id_$ComputerName"

        if (Test-Path $file) {
            $IdentityFile = $file
        }
    }

    $arguments = "-F ""$etc\config"""

    if ($IdentityFile -and (Test-Path $IdentityFile)) {
        $arguments = $arguments + " -i ""$IdentityFile"""
    }

    $arguments = $arguments + " $Remote"

    Start-Process -FilePath $ssh -ArgumentList $arguments -NoNewWindow -Wait
}

Set-Alias ssh Invoke-OpenSSH
Set-Alias sshell Invoke-OpenSSH

function New-OpenSSHHostShortcut {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName,
        [string]$Path = "$ComputerName.lnk"
    )

    Set-FileShortCut -Path $Path.ToUpper() `
    -TargetPath "${env:WINDIR}\System32\OpenSSH\ssh.exe"  `
    -Arguments "-F ""${env:SystemDrive}\etc\ssh\config"" $($ComputerName.ToLower())" `
    -Description "Open SSH Console to $($ComputerName.ToUpper())" `
    -IconPath "${env:SystemRoot}\System32\SHELL32.dll,92" `
    -WorkingDirectory "${env:WINDIR}\System32\OpenSSH"

}
function Remove-OpenSSHClient {
    if (Test-OpenSSHClient) {
        if (Test-Elevation) {
            Remove-WindowsCapability -Online -Name $(getClientPackageName)
        }
    }
}

function Remove-OpenSSHServer {
     if (Test-OpenSSHServer) {
        if (Test-Elevation) {
            if (Get-Service -Name 'sshd') {
                Stop-Service -Name 'sshd' -Force
            }

            Remove-WindowsCapability -Online -Name $(getServerPackageName) | Out-Null
        }
    }
}

function Set-OpenSSHDefaultShell {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path,
        [string]$Options = $null
    )

    if (-not (Test-OpenSSHServer)) {
        return
    }

    if (-not (Test-Path "HKLM:\SOFTWARE\OpenSSH")) {
        New-Item -Path "HKLM:\SOFTWARE" -Name "OpenSSH" -Force | out-null
    }

    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
        -Name 'DefaultShell' -Value "$Path" `
        -PropertyType 'String' -Force | Out-Null

    if ($Options) {
        New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
            -Name 'DefaultShellCommandOption' `
            -Value "$Options" -PropertyType 'String' -Force  | Out-Null
    } else {
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
            -Name 'DefaultShellCommandOption' -ErrorAction 'SilentlyContinue'
    }
}

function Test-OpenSSHClient {
    return ((Get-WindowsCapability -Online -Name $(getClientPackageName)).State -eq "Installed")
}

function Test-OpenSSHServer {
    return ((Get-WindowsCapability -Online -Name $(getServerPackageName)).State -eq "Installed")
}

function Test-OpenSSHService {
    if (Get-Service -Name 'sshd' -ErrorAction SilentlyContinue) {
        return ((Get-Service -Name 'sshd').Status -eq "Running")
    } else {
        return $false
    }
}
