@{
    ModuleVersion = '2020.11.14.1'
    GUID = '2cd0c771-ed8b-48bc-b6bc-be8540c915e4'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Docker.psm1'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Find-Docker"
        "Get-DockerContainer"
        "Get-DockerContainerNames"
        "Get-DockerContainerIds"
        "Get-DockerContainerIPAddress"
        "Get-DockerContainerIPAddresses"
        "Get-DockerContainers"
        "Get-DockerContainerState"
        "Get-DockerContainerStates"
        "Get-RunningDockerContainers"
        "Invoke-AlpineContainer"
        "Invoke-Docker"
        "Remove-ExitedDockerContainers"
        "Remove-NonRunningDockerContainers"
        "Start-DockerContainer"
        "Stop-DockerContainer"
    )
    AliasesToExport = @(
        "alpine"
    )
}
