@{
    RootModule = "VirtualBox.psm1"
    ModuleVersion = "2110.12.3"
    GUID = "c66d09da-ef6d-411b-8708-9526b68533fa"
    Author = "Julian Easterling"
    PowerShellVersion = "3.0"
    TypesToProcess = @()
    FormatsToProcess = @()
    NestedModules = @()
    FunctionsToExport = @(
        "Get-VirtualBoxMachine"
        "Get-VirtualBoxProcess"
        "Find-VirtualBox"
        "Invoke-VirtualBox"
        "Save-VirtualBoxMachine"
        "Start-VirtualBoxMachine"
        "Stop-VirtualBoxMachine"
    )
    AliasesToExport = @(
        "Get-VBoxMachine"
        "gvbm"
        "Resume-VirtualBoxMachine"
        "Resume-VBoxMachine"
        "Start-VBoxMachine"
        "Stop-VBoxMachine"
        "vbox"
    )
}
