@{
    RootModule = 'OperatingSystem.psm1'
    ModuleVersion = '2020.9.21.1'
    GUID = '3ffbac72-4374-43f7-8b6d-f190478077e7'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Find-FolderSize"
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
        "Install-WindowsUpdates"
        "Remove-EnvironmentVariable"
        "Set-EnvironmentVariable"
        "Set-Tls13Client"
        "Test-DaylightSavingsInEffect"
        "Test-DomainJoined"
        "Test-EnvironmentVariable"
        "Test-NormalBoot"
        "Test-Os64Bit"
        "Test-OsClient"
        "Test-OsDomainController"
        "Test-OsServer"
        "Test-PendingReboot"
    )
    AliasesToExport = @(
        "Calculate-Folder-Size"
        "Calculate-FolderSize"
        "midnight"
    )
}
