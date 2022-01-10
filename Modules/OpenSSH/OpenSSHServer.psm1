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

function Test-OpenSSHService {
    if (Get-Service -Name 'sshd' -ErrorAction SilentlyContinue) {
        return ((Get-Service -Name 'sshd').Status -eq "Running")
    } else {
        return $false
    }
}
