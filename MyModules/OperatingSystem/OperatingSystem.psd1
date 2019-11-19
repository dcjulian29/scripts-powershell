@{
    RootModule = 'OperatingSystem.psm1'
    ModuleVersion = '2019.11.18.1'
    GUID = '3ffbac72-4374-43f7-8b6d-f190478077e7'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Get-OSInstallDate"
        "Get-OSVersion"
        "Get-OSRegisteredUser"
        "Get-OSInstallDate"
        "Get-OSBuildNumber"
        "New-RemoteDesktopShortcut"
        "Test-PendingReboot"
    )
}
