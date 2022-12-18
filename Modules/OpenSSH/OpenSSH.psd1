@{
  ModuleVersion = '2212.17.1'
  GUID = '2b2add2f-ba2d-461a-8bac-6cfb19894a0d'
  Author = 'Julian Easterling'
  PowerShellVersion = '3.0'
  RootModule = 'OpenSSH.psm1'
  NestedModules = @(
    "OpenSCP.psm1"
    "OpenSSHConfig.psm1"
    "OpenSSHKnownHosts.psm1"
    "OpenSSHPackages.psm1"
    "OpenSSHServer.psm1"
  )
  TypesToProcess = @()
  FormatsToProcess = @()
  FunctionsToExport = @(
    "Add-OpenSSHClient"
    "Add-OpenSSHServer"
    "Add-OpenSSHKnownHost"
    "Enable-OpenSSHServer"
    "Disable-OpenSSHServer"
    "Find-OpenSCP"
    "Find-OpenSSH"
    "Get-OpenSSHConfigFileName"
    "Get-OpenSSHDefaultShell"
    "Get-OpenSSHDefaultShellOptions"
    "Get-OpenSSHKnownHosts"
    "Get-OpenSSHConfig"
    "Invoke-OpenSCP"
    "Invoke-OpenSSH"
    "New-OpenSSHHostShortcut"
    "New-OpenSSHKey"
    "Receive-OpenSCPPath"
    "Remove-OpenSSHClient"
    "Remove-OpenSSHServer"
    "Remove-OpenSSHKnownHost"
    "Send-OpenSCPPath"
    "Set-OpenSSHDefaultShell"
    "Test-OpenSSHClient"
    "Test-OpenSSHServer"
    "Test-OpenSSHService"
  )
  AliasesToExport = @(
    "Execute-OpenSSHCommand"
    "Invoke-OpenSSHCommand"
    "secure-copy"
    "secure-copy-receive"
    "secure-copy-send"
    "ssh-knownhost-add"
    "ssh-knownhost-remove"
    "sshell"
    "sshellc"
  )
}
