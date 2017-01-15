Function Start-MongoDBServer {
    & sc.exe start MongoDB
}

Function Start-MongoDBClient {
    & "$(Find-MongoDbPath)\mongo.exe"
}

Function Stop-MongoDBServer {
    & sc.exe stop MongoDB
}

Function Import-MongoCollectionFromCsv {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ })]
        [String]$CsvFile,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Database,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Collection

    )

    $parameters = "--type csv --headerline $CsvFile -d $Database -c $Collection"
 
    & "$(Find-MongoDbPath)\mongoimport.exe $parameters"
}

Function Import-MongoCollectionFromDump {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ })]
        [String]$DumpFile,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Database,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Collection
    )

    $parameters = "--headerline $CsvFile -d $Database -c $Collection"
 
    & "$(Find-MongoDbPath)\mongoimport.exe $parameters"
}

Function Export-MongoCollection {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$JsonFile,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Database,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Collection
    )

    $parameters = "--db $Database --collection $Collection --out $JsonFile"
 
    & "$(Find-MongoDbPath)\mongoexport.exe $parameters"
}

##############################################################################

Export-ModuleMember Start-MongoDBServer
Export-ModuleMember Stop-MongoDBServer
Export-ModuleMember Import-MongoCollectionFromCsv
Export-ModuleMember Import-MongoCollectionFromDump
Export-ModuleMember Export-MongoCollection

Set-Alias mongodb-start Start-MongoDBServer
Set-Alias mongodb-stop Stop-MongoDBServer
Set-Alias mongodb-client Start-MongoDBClient

Export-ModuleMember -Alias mongodb-start
Export-ModuleMember -Alias mongodb-stop
Export-ModuleMember -Alias mongodb-client
