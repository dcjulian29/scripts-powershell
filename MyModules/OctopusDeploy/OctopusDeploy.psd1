@{
    ModuleVersion = '2020.5.3.1'
    GUID = 'b3764581-214b-4403-b277-e97b6ad00c51'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'OctopusDeploy.psm1'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Clear-OctopusProfile"
        "Find-Octo"
        "Import-OctopusProfile"
        "Invoke-DeployOctopusRelease"
        "Invoke-Octo"
        "New-OctopusPackage"
        "New-OctopusRelease"
        "Push-OctopusPackage"
        "Set-OctopusProfile"
    )
    AliasesToExport = @(
        "Create-OctopusRelease"
        "Load-OctoputProfile"
        "octo"
        "octo-profile-clear"
        "octo-profile-load"
        "octo-publish"
        "octo-release-create"
        "octo-release-deploy"
        "octopus"
        "octopus-profile-clear"
        "octopus-profile-load"
        "octopus-publish"
        "octopus-release-create"
        "octopus-release-deploy"
    )
}
