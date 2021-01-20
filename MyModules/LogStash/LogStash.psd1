@{
    ModuleVersion = '2101.19.1'
    GUID = '2d6efd08-0859-4734-a2e0-c873bd36ccb4'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'LogStash.psm1'
    NestedModules = @()
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Clear-LogStashProfile"
        "Get-LogStashNode"
        "Get-LogStashPipeline"
        "Get-LogStashPlugins"
        "Get-LogStashServer"
        "Import-LogStashProfile"
        "Invoke-LogStashApi"
        "New-LogStashProfile"
        "Set-LogStashProfile"
        "Test-LogStashProfile"
        "Use-LogStashProfile"
    )
    AliasesToExport = @(
        "Load-LogStashProfile"
        "ls-api"
        "logstash-api"
        "logstash-profile-clear"
        "ls-profile-clear"
        "logstash-profile-load"
        "ls-profile-load"
    )
}
