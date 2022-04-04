@{
    ModuleVersion = '2203.30.1'
    GUID = '2b2add2f-ba2d-461a-8bac-6cfb19894a0d'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'OpenSSH.psm1'
    NestedModules = @(
        "OpenSSHPackages.psm1"
        "OpenSSHServer.psm1"
    )
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
        "Invoke-OpenSSHCommand"
        "New-OpenSSHHostShortcut"
        "New-OpenSSHKey"
        "Receive-FileScp"
        "Remove-OpenSSHClient"
        "Remove-OpenSSHServer"
        "Remove-OpenSSHKnownHost"
        "Send-FileScp"
        "Set-OpenSSHDefaultShell"
        "Test-OpenSSHClient"
        "Test-OpenSSHServer"
        "Test-OpenSSHService"
    )
    AliasesToExport = @(
        "Execute-OpenSSHCommand"
        "scp"
        "ssh"
        "sshell"
        "sshellc"
    )
}
