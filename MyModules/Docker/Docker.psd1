@{
    ModuleVersion = '2020.12.13.1'
    GUID = '2cd0c771-ed8b-48bc-b6bc-be8540c915e4'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Docker.psm1'
    NestedModules = @(
        "DockerCompose.psm1"
        "DockerContainer.psm1"
        "DockerImage.psm1"
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Build-DockerCompose"
        "Find-Docker"
        "Find-DockerCompose"
        "Connect-DockerContainer"
        "Get-DockerComposeLog"
        "Get-DockerContainer"
        "Get-DockerContainerLog"
        "Get-DockerContainerNames"
        "Get-DockerContainerIds"
        "Get-DockerContainerIPAddress"
        "Get-DockerContainerState"
        "Get-DockerImage"
        "Get-DockerDiskUsage"
        "Get-RunningDockerContainers"
        "Get-DockerServerEngine"
        "Invoke-AlpineContainer"
        "Invoke-DockerContainerShell"
        "Invoke-Docker"
        "Invoke-DockerCompose"
        "New-DockerContainer"
        "Optimize-Docker"
        "Pop-DockerImage"
        "Read-DockerCompose"
        "Remove-DockerContainer"
        "Remove-DockerImage"
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
        "docker-container"
        "docker-image"
        "docker-prune"
        "docker-pull"
        "docker-diskusage"
        "Prune-Docker"
        "Pull-DockerImage"
        "Validate-DockerCompose"
    )
}
