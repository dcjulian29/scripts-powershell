@{
    ModuleVersion = '2020.1.30.1'
    GUID = '4f41eba3-297c-4908-a686-d92063e79122'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'GitFlow.psm1'
    NestedModules = @()
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Initialize-GitFlow"
        "Pop-GitFlowFeature"
        "Publish-GitFlowFeature"
        "Start-GitFlowFeature"
        "Start-GitFlowHotfix"
        "Start-GitFlowRelease"
        "Stop-GitFlowFeature"
        "Stop-GitFlowHotfix"
        "Stop-GitFlowRelease"
        "Update-GitFlowFeature"
    )
    AliasesToExport = @(
        "Finish-GitFlowFeature"
        "Finish-GitFlowRelease"
        "gffff"
        "gffs"
        "gfrf"
        "gfrs"
    )
}
