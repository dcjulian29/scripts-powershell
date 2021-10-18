@{
    ModuleVersion = '2110.18.1'
    GUID = '3d789869-88e4-46e8-a9f8-8cd1f8652e10'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'VirtualDevelopment.psm1'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Install-DevVmPackage"
        "New-DevVM"
        "New-LinuxDevVM"
        "Update-DevVmPackages"
    )
    AliasesToExport = @()
}
