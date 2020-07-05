@{
    RootModule = 'VirtualBaseDisk.psm1'
    ModuleVersion = '2019.12.18.2'
    GUID = 'ed6e65e3-8813-426c-aa4c-b0373081f509'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Convert-WindowsImage"
        "Get-WindowsImagesInISO"
        "Get-WindowsImagesInWIM"
        "New-DevBaseVhdxDisk"
        "New-BaseVhdxDisk"
    )
    AliasesToExport = @()
    ScriptsToProcess = @(
        "Convert-WindowsImage.ps1"
    )
}
