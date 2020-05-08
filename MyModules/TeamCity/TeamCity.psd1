@{
    ModuleVersion = '2020.5.8.1'
    GUID = '30e20011-16a8-4280-a894-12814809ff25'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'TeamCity.psm1'
    NestedModules = @()
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Clear-TeamCityProfile"
        "Get-TeamCityServerUptime"
        "Get-TeamCityServerVersion"
        "Import-TeamCityProfile"
        "Invoke-TeamCityApi"
        "Set-TeamCityProfile"
        "Test-TeamCityProfile"
        "Use-TeamCityProfile"
    )
    AliasesToExport = @(
        "Load-TeamCityProfile"
        "teamcityapi"
        "teamcity-api"
        "teamcity-profile-clear"
        "teamcity-profile-load"
    )
}
