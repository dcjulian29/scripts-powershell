#Windows Server... Need to figure out Windows 10.
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

function Disable-OpenSSHClient {
    Remove-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
}

function Disable-OpenSSHServer {
    Remove-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
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

function Invoke-OpenSCP {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SourcePath,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationPath,
        [string]$IdentityFile = "$env:SystemDrive\etc\ssh\id_$ComputerName"
    )

    $scp = "$env:windir\System32\OpenSSH\scp.exe"
    $etc = "$env:SystemDrive\etc\ssh"
    $arguments = "-F ""$etc\config"" -i ""$IdentityFile"" $SourcePath $DestinationPath"

    Start-Process -FilePath $scp -ArgumentList $arguments -NoNewWindow -Wait
}

###################################################################################################

Export-ModuleMember Enable-OpenSSHClient
Export-ModuleMember Enable-OpenSSHServer
Export-ModuleMember Disable-OpenSSHClient
Export-ModuleMember Disable-OpenSSHServer

Export-ModuleMember Invoke-OpenSSH
Export-ModuleMember Invoke-OpenSCP

Set-Alias ssh Invoke-OpenSSH
Export-ModuleMember -Alias ssh

Set-Alias scp Invoke-OpenSCP
Export-ModuleMember -Alias scp
