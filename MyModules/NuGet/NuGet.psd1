@{
    ModuleVersion = '2020.11.13.1'
    GUID = 'b3764581-214b-4403-b277-e97b6ad00c51'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'NuGet.psm1'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Clear-NuGetProfile"
        "Find-NuGet"
        "Get-NuGetMetaData"
        "Import-NuGetProfile"
        "Invoke-NuGet"
        "New-NuGetPackage"
        "Push-NuGetPackage"
        "Remove-AllNuGetPackages"
        "Remove-AllNuGetPackagesFromCache"
        "Remove-NuGetPackagesFromCache"
        "Restore-NuGetPackages"
    )
    AliasesToExport = @(
        "Create-NuGetPackage"
        "Load-NuGetProfile"
        "nuget-metadata"
        "nuget-profile-clear"
        "nuget-profile-load"
        "nuget-package-clean"
        "nuget-make-package"
        "nuget-publish"
        "Purge-AllNuGetPackages"
        "Purge-AllNuGetPackagesFromCache"
        "Purge-NuGetPackagesFromCache"
    )
}
