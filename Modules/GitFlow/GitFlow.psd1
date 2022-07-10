@{
    ModuleVersion = '2207.10.1'
    GUID = '4f41eba3-297c-4908-a686-d92063e79122'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'GitFlow.psm1'
    NestedModules = @(
      "GitFlowFeature.psm1"
      "GitFlowHotFix.psm1"
      "GitFlowRelease.psm1"
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Initialize-GitFlow"
        "Pop-GitFlowFeature"
        "Pop-GitFlowHotfix"
        "Pop-GitFlowRelease"
        "Publish-GitFlowFeature"
        "Publish-GitFlowHotfix"
        "Publish-GitFlowRelease"
        "Remove-GitFlowFeature"
        "Remove-GitFlowHotfix"
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
        "Abort-GitFlowHotfix"
        "Abort-GitFlowRelease"
        "Finish-GitFlowFeature"
        "Finish-GitFlowHotfix"
        "Finish-GitFlowRelease"
        "gfff"
        "gffs"
        "gfhf"
        "gfhs"
        "gfrf"
        "gfrs"
        "Pull-GitFlowFeature"
        "Pull-GitFlowHotfix"
        "Pull-GitFlowRelease"
    )
}
