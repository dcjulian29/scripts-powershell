@{
    RootModule = 'VisualStudio.psm1'
    ModuleVersion = '2211.16.1'
    GUID = '1f375f95-3e56-426c-831b-3ff97ed8f0a2'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Find-VisualStudio"
        "Find-VisualStudioSolutions"
        "Find-VSIX"
        "Find-VSVars"
        "Get-VsixUrl"
        "Get-VSVars"
        "Import-VSVars"
        "Install-VsixByName"
        "Install-VsixPackage"
        "Show-VisualStudioInstalledVersions"
        "Show-VsixExtensions"
        "Start-VisualStudio"
        "Start-VisualStudio2019"
        "Start-VisualStudio2022"
        "Start-VisualStudioCode"
        "Test-VisualStudioInstalledVersion"
    )
    AliasesToExport = @(
        "code"
        "Find-VisualStudioVariables"
        "Register-VisualStudioVariables"
        "Register-VSVariables"
        "vs-solutions"
        "vs2019"
        "vs2022"
        "vscode"
        "vsvars32"
        "VSVariables"
    )
}
