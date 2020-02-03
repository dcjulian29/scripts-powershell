@{
    ModuleVersion = '2020.2.2.1'
    GUID = 'e6dcee49-99f8-4788-b4ca-786ec17b7aba'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'VirtualMachines.psm1'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Compress-Vhdx"
        "Connect-IsoToVirtual"
        "Get-VirtualizationManagementService"
        "Get-VirtualizationNamespace"
        "Get-VirtualMachineStatus"
        "Mount-Vhdx"
        "Move-FileToVM"
        "Move-FilesToVM"
        "Move-StartLayoutToVM"
        "Move-VMStartUpScriptBlockToVM"
        "Move-VMStartUpScriptFileToVM"
        "New-DataVhdx"
        "New-DifferencingVhdx"
        "New-SqlDataVhdx"
        "New-SystemVhdx"
        "New-UnattendFile"
        "New-VirtualMachine"
        "Select-VirtualMachine"
        "Uninstall-VirtualMachine"
    )
    AliasesToExport = @(
        "New-ReferenceVhdx"
    )
}
