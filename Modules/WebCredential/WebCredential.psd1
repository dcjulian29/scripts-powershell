@{
    RootModule = 'WebCredential.psm1'
    ModuleVersion = '2201.9.1'
    GUID = 'e2f61e99-799f-4f18-9a1e-d217dceea068'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Get-WebCredential"
        "Remove-WebCredential"
        "Set-WebCredential"
    )
    AliasesToExport = @()
}
