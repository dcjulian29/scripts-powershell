@{
    RootModule = 'OpenSSH.psm1'
    ModuleVersion = '2020.4.30.1'
    GUID = '2b2add2f-ba2d-461a-8bac-6cfb19894a0d'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Add-OpenSSHClient"
        "Add-OpenSSHServer"
        "Add-OpenSSHKnownHost"
        "Disable-OpenSSHServer"
        "Get-OpenSSHDefaultShell"
        "Get-OpenSSHDefaultShellOptions"
        "Get-OpenSSHKnownHosts"
        "Invoke-OpenSCP"
        "Invoke-OpenSSH"
        "New-OpenSSHHostShortcut"
        "Remove-OpenSSHClient"
        "Remove-OpenSSHServer"
        "Remove-OpenSSHKnownHost"
        "Set-OpenSSHDefaultShell"
        "Test-OpenSSHClient"
        "Test-OpenSSHServer"
        "Test-OpenSSHService"
    )
    AliasesToExport = @(
        "scp"
        "ssh"
        "sshell"
    )
}
