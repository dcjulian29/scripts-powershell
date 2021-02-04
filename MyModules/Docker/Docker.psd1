@{
    ModuleVersion = '2102.4.1'
    GUID = '2cd0c771-ed8b-48bc-b6bc-be8540c915e4'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Docker.psm1'
    NestedModules = @(
        "DockerCompose.psm1"
        "DockerContainer.psm1"
        "DockerImage.psm1"
        "DockerNetwork.psm1"
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Build-DockerCompose"
        "Connect-DockerContainer"
        "Connect-DockerNetwork"
        "Disconnect-DockerNetwork"
        "Find-Docker"
        "Find-DockerCompose"
        "Get-DockerComposeLog"
        "Get-DockerContainer"
        "Get-DockerContainerIds"
        "Get-DockerContainerIPAddress"
        "Get-DockerContainerLog"
        "Get-DockerContainerNames"
        "Get-DockerContainerState"
        "Get-DockerDiskUsage"
        "Get-DockerImage"
        "Get-DockerNetwork"
        "Get-DockerServerEngine"
        "Get-RunningDockerContainers"
        "Invoke-AlpineContainer"
        "Invoke-DebianContainer"
        "Invoke-Docker"
        "Invoke-DockerCompose"
        "Invoke-DockerContainerShell"
        "New-DockerContainer"
        "New-DockerNetwork"
        "Optimize-Docker"
        "Optimize-DockerNetwork"
        "Pop-DockerImage"
        "Read-DockerCompose"
        "Remove-DockerContainer"
        "Remove-DockerImage"
        "Remove-DockerNetwork"
        "Resume-DockerCompose"
        "Start-DockerCompose"
        "Start-DockerContainer"
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
    AliasesToExport = @(
        "alpine"
        "dc"
        "dcb"
        "dcd"
        "dcu"
        "debian"
        "docker-container"
        "docker-diskusage"
        "docker-image"
        "docker-prune"
        "docker-pull"
        "Prune-Docker"
        "Prune-DockerNetwork"
        "Pull-DockerImage"
        "Validate-DockerCompose"
    )
}
