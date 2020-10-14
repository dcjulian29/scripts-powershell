@{
    ModuleVersion = '2020.10.14.1'
    GUID = '9b8cce35-7dda-4746-b7b0-ba340ef3185a'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'ElasticSearch.psm1'
    NestedModules = @()
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Clear-ElasticSearchProfile"
        "Import-ElasticSearchProfile"
        "Invoke-ElasticSearchApi"
        "New-ElasticSearchProfile"
        "Set-ElasticSearchProfile"
        "Test-ElasticSearchProfile"
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
