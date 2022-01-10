@{
    ModuleVersion = '2101.12.1'
    GUID = '9b8cce35-7dda-4746-b7b0-ba340ef3185a'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'ElasticSearch.psm1'
    NestedModules = @(
        'ElasticSearchCluster.psm1'
        'ElasticSearchDocument.psm1'
        'ElasticSearchIndex.psm1'
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Clear-ElasticSearchProfile"
        "Find-ElasticSearchDocument"
        "Get-ElasticSearchDocument"
        "Get-ElasticSearchHealth"
        "Get-ElasticSearchIndex"
        "Get-ElasticSearchIndexDocumentCount"
        "Get-ElasticSearchNode"
        "Get-ElasticSearchNodeDetail"
        "Get-ElasticSearchState"
        "Get-ElasticSearchStatistic"
        "Import-ElasticSearchProfile"
        "Invoke-ElasticSearchApi"
        "New-ElasticSearchDocument"
        "New-ElasticSearchProfile"
        "Remove-ElasticSearchDocument"
        "Set-ElasticSearchProfile"
        "Test-ElasticSearchIndex"
        "Test-ElasticSearchProfile"
        "Update-ElasticSearchDocument"
        "Use-ElasticSearchProfile"
    )
    AliasesToExport = @(
        "Load-ElasticSearchProfile"
        "es-api"
        "elasticsearch-api"
        "elasticsearch-profile-clear"
        "es-profile-clear"
        "elasticsearch-profile-load"
        "es-profile-load"
    )
}
