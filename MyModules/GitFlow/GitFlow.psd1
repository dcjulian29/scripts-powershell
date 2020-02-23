@{
    ModuleVersion = '2020.2.23.1'
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
        "Pop-GitFlowHotfix"
        "Publish-GitFlowFeature"
        "Publish-GitFlowHotfix"
        "Remove-GitFlowFeature"
        "Remove-GitFlowRelease"
        "Start-GitFlowFeature"
        "Start-GitFlowHotfix"
        "Start-GitFlowRelease"
        "Stop-GitFlowFeature"
        "Stop-GitFlowHotfix"
        "Stop-GitFlowRelease"
        "Update-GitFlowFeature"
    )
    AliasesToExport = @(
        "Abort-GitFlowFeature"
        "Abort-GitFlowRelease"
        "Finish-GitFlowFeature"
        "Finish-GitFlowHotfix"
        "Finish-GitFlowRelease"
        "gfff"
        "gffs"
        "gfhs"
        "gfhf"
        "gfrf"
        "gfrs"
        "Pull-GitFlowFeature"
        "Pull-GitFlowHotfix"
    )
}
