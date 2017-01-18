Function Get-OSInstallDate {
    Get-CimInstance Win32_OperatingSystem | select Caption, Version, InstallDate
}



##############################################################################

Export-ModuleMember Get-OSInstallDate