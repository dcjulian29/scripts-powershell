@{
    ModuleVersion = '2020.1.25.1'
    GUID = 'fa07d906-a7c4-4a32-a845-6b54a7cb04d6'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'VirtualLab.psm1'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "New-LabCentOSServer"
        "New-LabDomainController"
        "New-LabFirewall"
        "New-LabLinuxWorkstation"
        "New-LabWindowsServer"
        "New-LabWindowsWorkstation"
        "New-LabUbuntuServer"
        "New-LabVMFromISO"
        "New-LabVMSwitch"
        "Remove-LabVMSwitch"
    )
    AliasesToExport = @()
}
