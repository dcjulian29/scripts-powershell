@{
    RootModule = 'VirtualBaseDisk.psm1'
    ModuleVersion = '2201.16.1'
    GUID = 'ed6e65e3-8813-426c-aa4c-b0373081f509'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Get-WindowsImagesInISO"
        "Get-WindowsImagesInWIM"
        "New-BaseVhdxDisk"
        "New-BaseServerVhdxDisks"
        "New-DevBaseVhdxDisk"
    )
    AliasesToExport = @()
    ScriptsToProcess = @()
}
