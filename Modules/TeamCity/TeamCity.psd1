@{
    ModuleVersion = '2020.6.7.1'
    GUID = '30e20011-16a8-4280-a894-12814809ff25'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'TeamCity.psm1'
    NestedModules = @(
        "TeamCityAgents.psm1"
        "TeamCityBuilds.psm1"
        "TeamCityProjects.psm1"
        "TeamCityUsers.psm1"
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Approve-TeamCityAgent"
        "Clear-TeamCityProfile"
        "Deny-TeamCityAgent"
        "Disable-TeamCityAgent"
        "Enable-TeamCityAgent"
        "Get-TeamCityAgent"
        "Get-TeamCityAgentPool"
        "Get-TeamCityAgentPools"
        "Get-TeamCityAgents"
        "Get-TeamCityBackup"
        "Get-TeamCityBuild"
        "Get-TeamCityBuilds"
        "Get-TeamCityBuildConfiguration"
        "Get-TeamCityBuildConfigurations"
        "Get-TeamCityBuildQueue"
        "Get-TeamCityBuildQueueDetail"
        "Get-TeamCityBuildStatistics"
        "Get-TeamCityBuildTests"
        "Get-TeamCityProject"
        "Get-TeamCityProjects"
        "Get-TeamCityServerLicense"
        "Get-TeamCityServerUptime"
        "Get-TeamCityServerVersion"
        "Get-TeamCityUser"
        "Get-TeamCityUsers"
        "Import-TeamCityProfile"
        "Invoke-TeamCityApi"
        "Invoke-TeamCityBackup"
        "Move-TeamCityAgent"
        "Set-TeamCityProfile"
        "Start-TeamCityBuild"
        "Stop-TeamCityBuild"
        "Test-TeamCityProfile"
        "Use-TeamCityProfile"
    )
    AliasesToExport = @(
        "Authorize-TeamCityAgent"
        "Backup-TeamCity"
        "Load-TeamCityProfile"
        "teamcityapi"
        "teamcity-api"
        "teamcity-profile-clear"
        "teamcity-profile-load"
        "Unauthorize-TeamCityAgent"
    )
}
