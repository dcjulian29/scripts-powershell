@{
    RootModule = 'MongoDB.psm1'
    ModuleVersion = '2020.2.15.1'
    GUID = '4f2dd9e5-6623-4293-8c33-0c3c3052f34b'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Export-MongoCollection"
        "Find-MongoDBPath"
        "Import-MongoCollectionFromCsv"
        "Import-MongoCollectionFromDump"
        "Invoke-MongoDBClient"
        "Start-MongoDBServer"
        "Stop-MongoDBServer"
    )
    AliasesToExport = @(
        "mongodb-client"
        "mongodb-start"
        "mongodb-stop"
    )
}
