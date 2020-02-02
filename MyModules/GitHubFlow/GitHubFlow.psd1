@{
    ModuleVersion = '2020.2.1.1'
    GUID = 'cde0e14e-0368-45f8-8d13-618442f9a9aa'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'GitHubFlow.psm1'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Start-GitHubFlowFeature"
        "Finish-GitHubFlowFeature"
        "Publish-GitHubFlowFeature"
        "Pop-GitHubFlowFeature"
        "Update-GitHubFlowFeature"
    )
    AliasesToExport = @(
        "Pull-GitHubFlowFeature"
        "ghffs"
        "ghfff"
        "ghffu"
    )
}
