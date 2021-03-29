function Get-WirelessState {
    $adapter = Get-NetworkInterface -InterfaceStatus Up -InterfaceType Wireless80211

    $r = [PSCustomObject]@{
        IPv4Address = (Get-NetworkIp $adapter.Name).IPv4
        IPv6Address = (Get-NetworkIp $adapter.Name).IPv6
        SSID = ""
        BSSID = ""
        State = ""
        Authentication = ""
        Channel = ""
        Signal = ""
        RxRate = ""
        TxRate = ""
        StateTime = Get-Date
    }

    $status = ($(netsh wlan show interfaces)).Split("`n")

    foreach ($line in $status) {
        if ($line -match "^    SSID\s{10,35}:\s(.*)") { $r.SSID = $Matches[1] }
        if ($line -match "^    BSSID\s{10,35}:\s(.*)") { $r.BSSID = $Matches[1] }
        if ($line -match "^    State\s{10,35}:\s(.*)") { $r.State = $Matches[1]}
        if ($line -match "^    Authentication\s{5,35}:\s(.*)") { $r.Authentication = $Matches[1] }
        if ($line -match "^    Channel\s{10,35}:\s(.*)") { $r.Channel = $Matches[1] }
        if ($line -match "^    Signal\s{10,35}:\s(.*)") { $r.Signal=$Matches[1] }
        if ($line -match "^    Receive\srate\s\(Mbps\)\s{2,15}:\s(.*)") { $r.RxRate = $Matches[1] }
        if ($line -match "^    Transmit\srate\s\(Mbps\)\s{2,15}:\s(.*)") { $r.TxRate=$Matches[1] }
    }

    return $r
}

function Show-WirelessInterface {
    netsh wlan show interfaces
}
