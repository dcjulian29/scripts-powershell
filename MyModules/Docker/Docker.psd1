@{
    ModuleVersion = '2020.11.15.1'
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
        "Invoke-AlpineContainer"
        "Invoke-Docker"
        "New-DockerContainer"
        "Pop-DockerImage"
        "Prune-Docker"
        "Remove-DockerImage"
        "Remove-ExitedDockerContainers"
        "Remove-NonRunningDockerContainers"
        "Start-DockerContainer"
        "Stop-DockerContainer"
    )
    AliasesToExport = @(
        "alpine"
        "Pull-DockerImage"
        "docker-container"
        "docker-image"
        "docker-prune"
        "docker-pull"
        "docker-diskusage"
    )
}
