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

function Test-OpenSSHClient {
    return ((Get-WindowsCapability -Online -Name $(getClientPackageName)).State -eq "Installed")
}

function Test-OpenSSHServer {
    return ((Get-WindowsCapability -Online -Name $(getServerPackageName)).State -eq "Installed")
}
