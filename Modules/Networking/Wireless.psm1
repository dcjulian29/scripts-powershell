function Disconnect-Wireless {
    $interface = (netsh wlan show interfaces `
        | Select-String -Pattern "\s{4}Name\s{19}:\s(.*)" `
        | &{ process { [PSCustomObject]@{
            Name = $_.matches[0].groups[1].value
        }}}).Name

    netsh wlan disconnect interface=`"$interface`"
}

function Find-WirelessAccessPoint {
    $ap = $(netsh wlan show networks mode=bssid)
    $accessPoints = @()
    $processNextLine = $false
    $lastLineIsChannel = $false

    foreach ($line in $ap) {
        if ($line -match "^SSID\s[0-9]{1,4}\s:\s(.*)") {
            $processNextLine = $true
            $name = [RegEx]::Match($line,"^SSID\s[0-9]{1,4}\s:\s(.*)").captures.groups[1].value
        } else {
            if ($processNextLine -eq $true) {
                if ($line -eq "") {
                    $processNextLine = $false

                    $accessPoints += [PSCustomObject]@{
                        BSSID          = $bssid
                        SSID           = $name
                        Authentication = $authentication
                        Channel        = $channel
                        Encryption     = $encryption
                        Signal         = $signal
                        Radio          = $radio
                    }

                    $lastLineIsChannel = $false
                } else {
                    if ($line -match "^\s{4}Authentication\s{1,24}\s:\s([a-zA-Z0-9-]*)") {
                        $authentication = $Matches[1]
                    }

                    if ($line -match "^\s{4}Encryption\s{1,24}\s:\s([a-zA-Z0-9-]*)") {
                        $encryption = $Matches[1]
                    }

                    if ($line -match "^\s{4}BSSID\s[0-9]{1,5}\s{1,24}\s:\s([0-9a-f:]*)") {
                        if ($lastLineIsChannel -eq $true) {
                            $accessPoints += [PSCustomObject]@{
                                BSSID          = $bssid
                                SSID           = $name
                                Authentication = $authentication
                                Channel        = $channel
                                Encryption     = $encryption
                                Signal         = $signal
                                Radio          = $radio
                            }

                            $lastLineIsChannel = $false
                        }

                        $bssid = $Matches[1]
                    }

                    if ($line -match "^\s{9}Signal\s{1,24}\s:\s([0-9%]*)") {
                        $signal = $Matches[1]
                    }

                    if ($line -match "^\s{9}Radio\stype\s{1,24}\s:\s([0-9a-z\.]*)") {
                        $radio = $Matches[1]
                    }

                    if ($line -match "^\s{9}Channel\s{1,24}\s:\s([0-9]*)") {
                        $channel = $Matches[1]
                        $lastLineIsChannel = $true
                    }
                }
            }
        }
    }

    return $accessPoints
}

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
