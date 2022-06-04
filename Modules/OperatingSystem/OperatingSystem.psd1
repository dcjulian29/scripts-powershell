@{
    RootModule = 'OperatingSystem.psm1'
    ModuleVersion = '2206.4.2'
    GUID = '3ffbac72-4374-43f7-8b6d-f190478077e7'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "ConvertTo-UnixPath"
        "Find-FolderSize"
        "Find-UwpApp"
        "Get-InstalledFont"
        "Get-InstalledSoftware"
        "Get-Midnight"
        "Get-OSActivationStatus"
        "Get-OSArchitecture"
        "Get-OSBoot"
        "Get-OSBuildNumber"
        "Get-OSCaption"
        "Get-OSInstallDate"
        "Get-OSRegisteredOrganization"
        "Get-OSRegisteredUser"
        "Get-OSVersion"
        "Get-UwpApp"
        "Get-UwpAppManifest"
        "Install-Font"
        "Install-WindowsUpdates"
        "New-UwpAppShortcut"
        "Remove-EnvironmentVariable"
        "Set-EnvironmentVariable"
        "Set-Tls13Client"
        "Start-UwpApp"
        "Test-DaylightSavingsInEffect"
        "Test-DomainJoined"
        "Test-EnvironmentVariable"
        "Test-NormalBoot"
        "Test-Os64Bit"
        "Test-OsClient"
        "Test-OsDomainController"
        "Test-OsServer"
        "Test-PendingReboot"
        "Test-UnixPath"
        "Test-WindowsPath"
    )
    AliasesToExport = @(
        "Calculate-Folder-Size"
        "Calculate-FolderSize"
        "midnight"
    )
}
