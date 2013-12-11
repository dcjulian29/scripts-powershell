Function Watch-DefaultGatewayChangeVpnToWiFi($SSID, $IfName) {

    $i = cmd.exe /c NETSH WLAN SHOW INTERFACE | findstr /r "^....SSID"
    if ($i.Contains($SSID)) {
        $adapter = Get-NetAdapter | Where-Object { $_.Name -eq $IfName } 
        if ($adapter.Status -eq "Up") {
            while ($true) {
                $routes = Get-WmiObject -Class Win32_IP4RouteTable `
                    | Where-Object { $_.destination -eq '0.0.0.0' -and $_.mask -eq '0.0.0.0'} `
                    | Sort-Object metric1 | Select-Object nexthop, metric1, interfaceindex

                if ($routes.interfaceindex -eq $adapter.ifIndex) {
                    Write-Warning "Default Gateway is currently set to the Wi-Fi adapter instead of the VPN Adapter!"
                    break
                }

                $i = cmd.exe /c NETSH WLAN SHOW INTERFACE | findstr /r "^....SSID"
                if (-not $i.Contains($SSID)) {
                    Write-Warning "WiFi is not currently connected to $SSID!"
                    break
                }

                Write-Host $([DateTime]::Now),$routes.nexthop

                Start-Sleep -s 60
            }

            $adapter | Disable-NetAdapter -Confirm:$false
            $shell = New-Object -ComObject "WScript.Shell"
            $button = $shell.Popup("The default gateway is set to Wireless...", 0, "Watch Default Gateway", 0)
            $adapter | Enable-NetAdapter
        } else {
            Write-Warning "The specified interface is not connected to a network..."
        }
    } else {
        Write-Warning "You are not currently connected to $SSID..."
    }
}
