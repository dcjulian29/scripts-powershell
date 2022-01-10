@{
    RootModule = 'LinuxSubsystem.psm1'
    ModuleVersion = '2112.9.1'
    GUID = '64252dac-92cf-41fb-9ef7-94e1a42c56ac'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Disable-LinuxSubsystem"
        "Enable-LinuxSubsystem"
        "Install-KaliLinux"
        "Restart-LinuxSubsystem"
        "Start-KaliLinux"
        "Start-UbuntuLinux"
        "Test-LinuxSubsystem"
        "Uninstall-KaliLinux"
    )
    AliasesToExport = @(
        "kali"
        "ubuntu"
    )
}
