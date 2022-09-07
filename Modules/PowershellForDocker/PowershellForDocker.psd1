@{
  RootModule = 'PowershellForDocker.psm1'
  ModuleVersion = '2209.7.1'
  Description = "A collection of commands to interact with Docker."
  GUID = '2cd0c771-ed8b-48bc-b6bc-be8540c915e4'
  Author = 'Julian Easterling'
  Copyright = '(c) Julian Easterling. Some rights reserved.'
  PowerShellVersion = '5.1'
  RequiredModules = @()
  RequiredAssemblies = @()
  ScriptsToProcess = @()
  TypesToProcess = @()
  FormatsToProcess = @()
  NestedModules = @(
    "DockerCompose.psm1"
    "DockerContainer.psm1"
    "DockerImage.psm1"
    "DockerNetwork.psm1"
    "DockerVolume.psm1"
  )
  FunctionsToExport = @(
    "Connect-DockerContainer"
    "Connect-DockerNetwork"
    "Disconnect-DockerNetwork"
    "Find-Docker"
    "Find-DockerCompose"
    "Get-DockerComposeLog"
    "Get-DockerContainer"
    "Get-DockerContainerIds"
    "Get-DockerContainerIPAddress"
    "Get-DockerContainerNames"
    "Get-DockerContainerState"
    "Get-DockerDiskUsage"
    "Get-DockerImage"
    "Get-DockerMountPoint"
    "Get-DockerNetwork"
    "Get-DockerServerEngine"
    "Get-DockerVolume"
    "Get-FilePathForContainer"
    "Get-PathForContainer"
    "Get-RunningDockerContainers"
    "Invoke-AlpineContainer"
    "Invoke-DebianContainer"
    "Invoke-Dive"
    "Invoke-Docker"
    "Invoke-DockerLog"
    "Invoke-DockerLogTail"
    "Invoke-DockerCompose"
    "Invoke-DockerComposeBuild"
    "Invoke-DockerComposeLog"
    "Invoke-DockerComposeLogTail"
    "Invoke-DockerComposePull"
    "Invoke-DockerContainerShell"
    "New-DockerContainer"
    "New-DockerNetwork"
    "New-DockerNfsVolume"
    "New-DockerVolume"
    "Optimize-Docker"
    "Optimize-DockerNetwork"
    "Optimize-DockerVolume"
    "Pop-DockerCompose"
    "Pop-DockerImage"
    "Read-DockerCompose"
    "Remove-DockerContainer"
    "Remove-DockerImage"
    "Remove-DockerNetwork"
    "Remove-DockerVolume"
    "Resume-DockerCompose"
    "Start-DockerCompose"
    "Start-DockerContainer"
    "Start-LinuxServerCommunityContainer"
    "Stop-DockerCompose"
    "Stop-DockerContainer"
    "Suspend-DockerCompose"
    "Switch-DockerLinuxEngine"
    "Switch-DockerWindowsEngine"
    "Test-Docker"
    "Test-DockerCompose"
    "Test-DockerLinuxEngine"
    "Test-DockerWindowsEngine"
  )
  CmdletsToExport = @()
  VariablesToExport = @()
  AliasesToExport = @(
    "alpine"
    "dc"
    "dcb"
    "dcd"
    "dcdown"
    "dcl"
    "dclog"
    "dcpull"
    "dctail"
    "dcu"
    "dcup"
    "debian"
    "dive"
    "dlog"
    "docker-container"
    "docker-diskusage"
    "docker-image"
    "docker-prune"
    "docker-pull"
    "docker-linuxserverio"
    "docker-lsio"
    "dtail"
    "Get-DockerContainerLog"
    "Prune-Docker"
    "Prune-DockerNetwork"
    "Prune-DockerVolume"
    "Pull-DockerCompose"
    "Pull-DockerImage"
    "Validate-DockerCompose"
  )
  PrivateData = @{
    PSData = @{
      Tags = @(
        "dcjulian29"
        "docker"
      )
      LicenseUri = 'https://github.com/dcjulian29/scripts-powershell/LICENSE.md'
      ProjectUri = 'https://github.com/dcjulian29/scripts-powershell'
      RequireLicenseAcceptance = $false
      ExternalModuleDependencies = @()
    }
  }
  HelpInfoURI = 'https://github.com/dcjulian29/scripts-powershell/tree/main/Modules/PowershellForDocker'
}
