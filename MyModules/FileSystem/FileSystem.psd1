@{
    RootModule = 'FileSystem.psm1'
    ModuleVersion = '2020.2.13.1'
    GUID = 'aaad40aa-30a0-495c-8377-53e89ea1ec11'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Copy-File"
        "Get-FullFilePath"
        "Get-FullDirectoryPath"
        "Get-FileEncoding"
        "Reset-Path"
        "Separator"
        "Find-FirstPath"
        "Find-ProgramFiles"
        "Get-Md5"
        "Get-Path"
        "Get-Sha1"
        "Get-Sha256"
        "Invoke-DownloadFile"
        "Invoke-PurgeFiles"
        "Invoke-TouchFile"
        "Invoke-UnzipFile"
        "Optimize-Path"
        "Remove-Path"
        "Set-FileShortCut"
        "Set-Path"
        "Set-PathAtPosition"
        "Test-InPath"
        "Test-InPathAtPosition"
    )
    AliasesToExport = @(
        "Clean-Path"
        "Download-File"
        "First-Path"
        "md5"
        "New-FileShortCut"
        "Purge-Files"
        "sha1"
        "sha256"
        "touch"
        "Unzip-File"
    )
}
