Function Enable-RemoteDesktop
{
    Write-Verbose "Enabling Remote Desktop ..."

    $settings = Get-WmiObject -Class "Win32_TerminalServiceSetting" `
        -Namespace root\cimv2\terminalservices
    $settings.SetAllowTsConnections(1)

    netsh advfirewall firewall set rule group="Remote Desktop" new enable=yes
}
