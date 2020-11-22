@{
    ModuleVersion = '2020.11.22.1'
    GUID = '2cd0c771-ed8b-48bc-b6bc-be8540c915e4'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Docker.psm1'
        NestedModules = @(
        "DockerContainer.psm1"
        "DockerImage.psm1"
    )

    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Find-Docker"
        "Connect-DockerContainer"
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
        "Invoke-Docker"
        "New-DockerContainer"
        "Optimize-Docker"
        "Pop-DockerImage"
        "Remove-DockerImage"
        "Remove-ExitedDockerContainers"
        "Remove-NonRunningDockerContainers"
        "Start-DockerContainer"
        "Stop-DockerContainer"
        "Switch-DockerLinuxEngine"
        "Switch-DockerWindowsEngine"
        "Test-Docker"
        "Test-DockerLinuxEngine"
        "Test-DockerWindowsEngine"
    )
    AliasesToExport = @(
        "alpine"
        "docker-container"
        "docker-image"
        "docker-prune"
        "docker-pull"
        "docker-diskusage"
        "Prune-Docker"
        "Pull-DockerImage"
    )
}
