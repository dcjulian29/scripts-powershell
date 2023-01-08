@{
    RootModule = 'FileSystem.psm1'
    ModuleVersion = '2301.7.1'
    GUID = 'aaad40aa-30a0-495c-8377-53e89ea1ec11'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    NestedModules = @(
      "Path.psm1"
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Assert-FolderExists"
        "ConvertTo-UnixPath"
        "Copy-File"
        "Get-FileEncoding"
        "Reset-Path"
        "Separator"
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
        "Remove-FilePermission"
        "Remove-Path"
        "Resolve-FullPath"
        "Set-FileInheritance"
        "Set-FilePermission"
        "Set-FileShortCut"
        "Set-Path"
        "Set-PathAtPosition"
        "Test-InPath"
        "Test-InPathAtPosition"
    )
    AliasesToExport = @(
        "Calculate-Folder-Size"
        "Calculate-FolderSize"
        "Clean-Path"
        "Download-File"
        "First-Path"
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
}
