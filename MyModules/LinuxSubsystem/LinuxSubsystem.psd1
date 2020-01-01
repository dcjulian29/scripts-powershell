@{
    RootModule = 'LinuxSubsystem.psm1'
    ModuleVersion = '2019.9.5.1'
    GUID = '64252dac-92cf-41fb-9ef7-94e1a42c56ac'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Disable-WindowsLinuxSubsystem"
        "Enable-WindowsLinuxSubsystem"
        "Install-KaliLinux"
        "Install-UbuntuLinux"
        "Start-KaliLinux"
        "Start-UbuntuLinux"
        "Test-WindowsLinuxSubsystem"
        "Uninstall-KaliLinux"
        "Uninstall-UbuntuLinux"
    )
    AliasesToExport = @(
        "kali"
        "ubuntu"
    )
}
