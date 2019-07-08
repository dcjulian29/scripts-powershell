#Windows Server... Need to figure out Windows 10.
function Disable-OpenSSHClient {
    Remove-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
}

function Disable-OpenSSHServer {
    Remove-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
}

function Enable-OpenSSHClient {
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
}

function Enable-OpenSSHServer {
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

    Start-Service sshd

    Set-Service -Name sshd -StartupType 'Automatic'

    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell `
        -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
        -PropertyType String -Force
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

###################################################################################################

Set-Alias scp Invoke-OpenSCP
Set-Alias ssh Invoke-OpenSSH
Set-Alias sshell Invoke-OpenSSH
