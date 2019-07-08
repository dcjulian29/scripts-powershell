@{
    RootModule = 'OpenSSH.psm1'
    ModuleVersion = '2019.7.8.1'
    GUID = '2b2add2f-ba2d-461a-8bac-6cfb19894a0d'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Disable-OpenSSHClient"
        "Disable-OpenSSHServer"
        "Enable-OpenSSHClient"
        "Enable-OpenSSHServer"
        "Invoke-OpenSCP"
        "Invoke-OpenSSH"
    )
    AliasesToExport = @(
        "scp"
        "ssh"
        "sshell"
    )
}
