@{
    ModuleVersion = '2020.6.5.1'
    GUID = 'd8dcfccc-7a12-4dfd-a27a-c647b408e1bf'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Networking.psm1'
    NestedModules = @(
        "IPerf.psm1"
        "NMap.psm1"
        "PacketCapture.psm1"
        "Wireshark.psm1"
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Add-PacketFilter"
        "Clear-PacketFilter"
        "Convert-PacketCaptureFile"
        "Get-PacketFilter"
        "Get-TSharkInterfaces"
        "Invoke-IPerf"
        "Invoke-IPerfServer"
        "Invoke-IPerfClient"
        "Invoke-Http"
        "Invoke-Nmap"
        "Invoke-PingScanNetwork"
        "Invoke-ScanNetwork"
        "Invoke-ScanHost"
        "Invoke-ScanLocalNetwork"
        "Invoke-TShark"
        "Invoke-TSharkCapture"
        "New-NetFirewallRule"
        "New-UrlReservation"
        "Start-PacketCapture"
        "Stop-PacketCapture"
        "Remove-NetFirewallRule"
        "Remove-UrlReservation"
    )
    AliasesToExport = @(
        "iperf"
        "iperf-server"
        "iperf-client"
        "nmap"
        "nmap-scan"
        "tshark"
        "tshark-showinterfaces"
        "tshark-capture"
    )
}
