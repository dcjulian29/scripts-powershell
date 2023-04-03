@{
    ModuleVersion = '2304.3.1'
    GUID = '6aa69e5b-f92d-41ba-947b-7840504d31da'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Code.psm1'
    NestedModules = @(
        "CodeBuilding.psm1"
        "CodeFolder.psm1"
        "CodeManagement.psm1"
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Get-CakeBuildBootstrapper"
        "Get-CodeCoverageReport"
        "Get-DefaultCodeFolder"
        "Get-MsBuildErrorsFromLog"
        "Get-UnitTestReport"
        "Edit-StyleCopSettings"
        "Find-MSBuild"
        "Find-StyleCopSettingsEditor"
        "Import-DevelopmentPowerShellModule"
        "Invoke-ArchiveProject"
        "Invoke-BuildProject"
        "Invoke-CleanAllProjects"
        "Invoke-CleanProject"
        "Invoke-MSBuild"
        "Invoke-SortConfigurationFile"
        "Invoke-SortProjectFile"
        "New-CodeFolder"
        "Set-CodeFolder"
        "Set-DefaultCodeFolder"
        "Show-CodeStatus"
        "Show-CoverageReport"
        "Test-DefaultCodeFolder"
        "Update-CodeFolder"
    )
    AliasesToExport = @(
        "bp"
        "idpsm"
        "msbuild"
        "project-archive"
        "project-clean"
        "project-clean-all"
        "Sort-ConfigurationFile"
        "Sort-ProjectFile"
    )
}
