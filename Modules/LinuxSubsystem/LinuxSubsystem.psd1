@{
    RootModule = 'LinuxSubsystem.psm1'
    ModuleVersion = '2209.25.1'
    GUID = '64252dac-92cf-41fb-9ef7-94e1a42c56ac'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Disable-LinuxSubsystem"
        "Enable-LinuxSubsystem"
        "Get-LinuxSubsystemParentProcess"
        "Restart-LinuxSubsystem"
        "Start-UbuntuLinux"
        "Test-LinuxSubsystem"
    )
    AliasesToExport = @(
        "ubuntu"
    )
}
