Function Get-OSInstallDate {
    (Get-CimInstance Win32_OperatingSystem).InstallDate
}

Function Get-OSVersion {
    (Get-CimInstance Win32_OperatingSystem).Version
}

Function Get-OSRegisteredUser {
    (Get-CimInstance Win32_OperatingSystem).RegisteredUser
}

Function Get-OSOrganization {
    (Get-CimInstance Win32_OperatingSystem).Organization
}

Function Get-OSBuildNumber {
    (Get-CimInstance Win32_OperatingSystem).BuildNumber
}

Function Test-PendingReboot {
    $PendingReboot = $false

    Push-Location "HKLM:\Software\Microsoft\Windows\CurrentVersion\"

    if (Get-ChildItem "Component Based Servicing\RebootPending" -EA Ignore) {
        $PendingReboot = $true
    }

    if (Get-Item "WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { 
        $PendingReboot = $true
    }

    Pop-Location

    Push-Location "HKLM:\SYSTEM\CurrentControlSet\Control"

    if (Get-ItemProperty "Session Manager" -Name PendingFileRenameOperations -EA Ignore) { 
        $PendingReboot = $true 
    }

    Pop-Location

    return $PendingReboot
}

##############################################################################

Export-ModuleMember Get-OSInstallDate
Export-ModuleMember Get-OSVersion
Export-ModuleMember Get-OSRegisteredUser
Export-ModuleMember Get-OSInstallDate
Export-ModuleMember Get-OSBuildNumber

Export-ModuleMember Test-PendingReboot
