@{
    ModuleVersion = '2020.4.22.1'
    GUID = 'fa07d906-a7c4-4a32-a845-6b54a7cb04d6'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'VirtualLab.psm1'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "New-LabCentOSServer"
        "New-LabDebianServer"
        "New-LabDomainController"
        "New-LabFirewall"
        "New-LabMintWorkstation"
        "New-LabUbuntuServer"
        "New-LabUbuntuWorkstation"
        "New-LabVMFromISO"
        "New-LabVMSwitch"
        "New-LabWindowsServer"
        "New-LabWindowsWorkstation"
        "Remove-LabVMSwitch"
    )
    AliasesToExport = @(
        "New-LabLinuxServer"
        "New-LabLinuxWorkstation"
    )
}
