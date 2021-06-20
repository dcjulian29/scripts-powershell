@{
    ModuleVersion = '2103.30.1'
    GUID = 'd8dcfccc-7a12-4dfd-a27a-c647b408e1bf'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Networking.psm1'
    NestedModules = @(
        "IPerf.psm1"
        "NMap.psm1"
        "PacketCapture.psm1"
        "Wireless.psm1"
        "WirelessProfile.psm1"
        "Wireshark.psm1"
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Add-PacketFilter"
        "Clear-PacketFilter"
        "Connect-WirelessProfile"
        "Convert-PacketCaptureFile"
        "Disconnect-Wireless"
        "Export-WirelessProfile"
        "Find-Nmap"
        "Find-WirelessAccessPoint"
        "Get-NetworkEstablishedConnection"
        "Get-NetworkInterface"
        "Get-NetworkIP"
        "Get-NetworkListeningPorts"
        "Get-PacketFilter"
        "Get-PrimaryIP"
        "Get-PublicIP"
        "Get-TSharkInterfaces"
        "Get-WirelessProfile"
        "Get-WirelessState"
        "Import-WirelessProfile"
        "Invoke-IPerf"
        "Invoke-IPerfServer"
        "Invoke-IPerfClient"
        "Invoke-Http"
        "Invoke-Nmap"
        "Invoke-PingScanNetwork"
        "Invoke-ScanHost"
        "Invoke-ScanLocalNetwork"
        "Invoke-ScanNetwork"
        "Invoke-TShark"
        "Invoke-TSharkCapture"
        "New-FirewallRule"
        "New-UrlReservation"
        "New-WirelessProfile"
        "Remove-WirelessProfile"
        "Show-UrlReservation"
        "Show-WirelessInterface"
        "Start-PacketCapture"
        "Stop-PacketCapture"
        "Remove-FirewallRule"
        "Remove-UrlReservation"
    )
    AliasesToExport = @(
        "iperf"
        "iperf-server"
        "iperf-client"
        "nmap"
        "nmap-host"
        "nmap-scan"
        "tshark"
        "tshark-showinterfaces"
        "tshark-capture"
    )
}
