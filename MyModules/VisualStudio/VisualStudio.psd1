@{
    RootModule = 'VisualStudio.psm1'
    ModuleVersion = '2020.11.26.1'
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
        "Get-VSVars"
        "Install-VsixPackage"
        "Set-VSVars"
        "Start-VisualStudio"
        "Start-VisualStudio2017"
        "Start-VisualStudio2019"
        "Start-VisualStudioCode"
        "Update-CodeSnippets"
    )
    AliasesToExport = @(
        "code"
        "Find-VisualStudioVariables"
        "Register-VisualStudioVariables"
        "Register-VSVariables"
        "vs-solutions"
        "vs2017"
        "vs2019"
        "vscode"
        "vsvars32"
        "VSVariables"
    )
}
