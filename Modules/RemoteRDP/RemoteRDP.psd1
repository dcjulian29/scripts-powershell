@{
    RootModule = 'RemoteRDP.psm1'
    ModuleVersion = '2105.24.1'
    GUID = '9476a49d-58bf-414f-89d8-619bf4f552b7'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Get-ActiveRdpSession"
        "Get-DisconnectedRdpSession"
        "Get-RdpSession"
        "Close-RdpSession"
        "Disable-RdpHostFile"
        "Disable-RdpHostFileDirectory"
        "Find-RdpHost"
        "Find-RdpHostFile"
        "Find-RdpHostFileDirectory"
        "New-RemoteDesktopShortcut"
        "Restore-RdpHostFile"
        "Restore-RdpHostFileDirectory"
    )
    AliasesToExport = @(
        "rdplist"
        "rdpkick"
        "New-RdpShortcut"
        "Validate-RdpHost"
        "Validate-RdpHostFile"
        "Validate-RdpHostFileDirectory"
    )
}
