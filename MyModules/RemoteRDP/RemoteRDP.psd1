@{
    RootModule = 'RemoteRDP.psm1'
    ModuleVersion = '2020.3.29.1'
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
        "Restore-RdpHostFile"
        "Restore-RdpHostFileDirectory"
    )
    AliasesToExport = @(
        "rdplist"
        "rdpkick"
        "Validate-RdpHost"
        "Validate-RdpHostFile"
        "Validate-RdpHostFileDirectory"
    )
}
