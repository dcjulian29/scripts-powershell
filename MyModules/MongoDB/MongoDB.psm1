function Find-MongoDBPath {
    First-Path `
        (Find-ProgramFiles 'MongoDB\Server\4.2\bin') `
        (Find-ProgramFiles 'MongoDB\Server\4.0\bin') `
        (Find-ProgramFiles 'MongoDB\Server\3.6\bin') `
        (Find-ProgramFiles 'MongoDB\Server\3.4\bin')
}

function Export-MongoCollection {
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

    cmd / """$(Find-MongoDbPath)\mongoexport.exe"" $parameters"
}

function Import-MongoCollectionFromCsv {
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

    cmd /c """$(Find-MongoDbPath)\mongoimport.exe"" $parameters"
}

function Import-MongoCollectionFromDump {
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

    cmd /c """$(Find-MongoDbPath)\mongoimport.exe"" $parameters"
}

function Invoke-MongoDBClient {
    cmd /c """$(Find-MongoDbPath)\mongo.exe"" $args"
}

Set-Alias -Name mongodb-client -Value Invoke-MongoDBClient

function Start-MongoDBServer {
    & sc.exe start MongoDB
}

Set-Alias -Name mongodb-start -Value Start-MongoDBServer

function Stop-MongoDBServer {
    & sc.exe stop MongoDB
}

Set-Alias -Name mongodb-stop -Value Stop-MongoDBServer
