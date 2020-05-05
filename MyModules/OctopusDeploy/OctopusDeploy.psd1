@{
    ModuleVersion = '2020.5.3.1'
    GUID = 'b3764581-214b-4403-b277-e97b6ad00c51'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'OctopusDeploy.psm1'
    NestedModules = @(
        "OctopusEnvironments.psm1"
        "OctopusProjects.psm1"
        "OctopusServer.psm1"
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Clear-OctopusProfile"
        "Find-Octo"
        "Get-OctopusEnvironment"
        "Get-OctopusEnvironments"
        "Get-OctopusProject"
        "Get-OctopusProjectById"
        "Get-OctopusProjects"
        "Get-OctopusRelease"
        "Get-OctopusReleases"
        "Get-OctopusReleasesForEnvironment"
        "Get-OctopusReleasesForProjectInEnvironment"
        "Get-OctopusServerUptime"
        "Get-OctopusServerVersion"
        "Import-OctopusProfile"
        "Invoke-DeployOctopusRelease"
        "Invoke-Octo"
        "Invoke-OctopusApi"
        "New-OctopusPackage"
        "New-OctopusRelease"
        "Push-OctopusPackage"
        "Set-OctopusProfile"
        "Test-OctopusProfile"
        "Use-OctopusProfile"
    )
    AliasesToExport = @(
        "Create-OctopusRelease"
        "Load-OctoputProfile"
        "octo"
        "octoapi"
        "octo-profile-clear"
        "octo-profile-load"
        "octo-publish"
        "octo-release-create"
        "octo-release-deploy"
        "octopus"
        "octopusapi"
        "octopus-api"
        "octopus-profile-clear"
        "octopus-profile-load"
        "octopus-publish"
        "octopus-release-create"
        "octopus-release-deploy"
    )
}
