@{
  RootModule = 'Path.psm1'
  ModuleVersion = '2201.9.1'
  GUID = '3ffbac72-4374-43f7-8b6d-f190478077e7'
  Author = 'Julian Easterling'
  PowerShellVersion = '3.0'
  TypesToProcess = @()
  FormatsToProcess = @()
  FunctionsToExport = @(
        "Add-CygwinPath"
        "Add-JavaPath"
        "Add-MongoDbPath"
        "Add-MongoDbPath"
        "Add-NodeJsPath"
        "Find-CygwinPath"
        "Find-InPath"
        "Find-JavaPath"
        "Find-MongoDbPath"
        "Find-NodeJsPath"
  )
  AliasesToExport = @(
    "path-cygwin"
    "path-find"
    "path-java"
    "path-mongodb"
    "path-nodejs"
  )
}
