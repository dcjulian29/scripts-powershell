@{
    RootModule = 'VirtualBaseDisk.psm1'
    ModuleVersion = '2110.15.1'
    GUID = 'ed6e65e3-8813-426c-aa4c-b0373081f509'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Get-WindowsImagesInISO"
        "Get-WindowsImagesInWIM"
        "New-DevBaseVhdxDisk"
        "New-BaseVhdxDisk"
        "New-BaseServeVhdxDisks"
    )
    AliasesToExport = @()
    ScriptsToProcess = @()
}
