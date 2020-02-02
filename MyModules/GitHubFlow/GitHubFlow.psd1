@{
    ModuleVersion = '2020.2.1.2'
    GUID = 'cde0e14e-0368-45f8-8d13-618442f9a9aa'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'GitHubFlow.psm1'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Start-GitHubFlowFeature"
        "Stop-GitHubFlowFeature"
        "Publish-GitHubFlowFeature"
        "Pop-GitHubFlowFeature"
        "Update-GitHubFlowFeature"
    )
    AliasesToExport = @(
        "Finish-GitHubFlowFeature"
        "Pull-GitHubFlowFeature"
        "ghffs"
        "ghfff"
        "ghffu"
    )
}
