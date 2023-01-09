@{
  RootModule = 'FileSystem.psm1'
  ModuleVersion = '2301.8.1'
  Description = "A collection of functions to deal with file systems including path operations."
  GUID = 'aaad40aa-30a0-495c-8377-53e89ea1ec11'
  Author = 'Julian Easterling'
  Copyright = '(c) Julian Easterling. Some rights reserved.'
  PowerShellVersion = '5.1'
  RequiredModules = @()
  RequiredAssemblies = @()
  ScriptsToProcess = @()
  TypesToProcess = @()
  FormatsToProcess = @()
  NestedModules = @(
    "FavoriteFolders.psm1"
    "Path.psm1"
  )
  FunctionsToExport = @(
    "Add-FavoriteFolder"
    "Assert-FolderExists"
    "Clear-FavoriteFolder"
    "ConvertTo-UnixPath"
    "Copy-File"
    "Get-FavoriteFolder"
    "Get-FileEncoding"
    "Find-FirstPath"
    "Find-FolderSize"
    "Find-ProgramFiles"
    "Format-FileWithSpaceIndent"
    "Format-FileWithTabIndent"
    "Get-Md5"
    "Get-Path"
    "Get-Sha1"
    "Get-Sha256"
    "Get-Share"
    "Invoke-DownloadFile"
    "Invoke-PurgeFiles"
    "Invoke-TouchFile"
    "Invoke-UnzipFile"
    "New-FileLink"
    "New-Folder"
    "New-FolderLink"
    "New-Share"
    "Optimize-Path"
    "Push-FavoriteFolder"
    "Push-LastFavoriteFolder"
    "Remove-FavoriteFolder"
    "Remove-FilePermission"
    "Remove-Path"
    "Reset-Path"
    "Resolve-FullPath"
    "Set-FileInheritance"
    "Set-FilePermission"
    "Set-FileShortCut"
    "Set-Path"
    "Set-PathAtPosition"
    "Test-InPath"
    "Test-InPathAtPosition"
  )
  CmdletsToExport = @()
  VariablesToExport = @()
  AliasesToExport = @(
    "Calculate-Folder-Size"
    "Calculate-FolderSize"
    "Clean-Path"
    "Download-File"
    "First-Path"
    "gd"
    "Get-FullFilePath"
    "Get-FullDirectoryPath"
    "md5"
    "New-FileShortCut"
    "Purge-Files"
    "sha1"
    "sha256"
    "touch"
    "Unzip-File"
  )
  PrivateData = @{
    PSData = @{
      Tags = @(
        "dcjulian29"
        "filesystem"
        "file"
        "path"
      )
      LicenseUri = 'https://github.com/dcjulian29/scripts-powershell/LICENSE.md'
      ProjectUri = 'https://github.com/dcjulian29/scripts-powershell'
      RequireLicenseAcceptance = $false
      ExternalModuleDependencies = @()
    }
  }
  HelpInfoURI = 'https://github.com/dcjulian29/scripts-powershell/tree/main/Modules/FileSystem'
}
