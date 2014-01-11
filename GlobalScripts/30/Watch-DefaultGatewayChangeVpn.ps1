Function Watch-DefaultGatewayChangeVpn($IfName) {
    $adapter = Get-NetAdapter | Where-Object { $_.Name -eq $IfName } 
    if ($adapter.Status -eq "Up") {
        while ($true) {
            $routes = Get-WmiObject -Class Win32_IP4RouteTable `
                | Where-Object { $_.destination -eq '0.0.0.0' -and $_.mask -eq '0.0.0.0'} `
                | Sort-Object metric1 | Select-Object nexthop, metric1, interfaceindex

            if ($routes.interfaceindex -ne $adapter.ifIndex) {
                for ($i = 0; $i -lt $routes.length; $i++) {
                    $gateway = Get-NetAdapter | Where-Object { $_.ifIndex -eq $routes[$i].interfaceindex }
                    $gateway
                    "-----"
                    $gateway | Disable-NetAdapter -Confirm:$false
                }

                ShowPopUpVpn "Default Gateway is not currently set to the VPN adapter!"

                for ($i = 0; $i -lt $routes.length; $i++) {
                    Get-NetAdapter | Where-Object { $_.ifIndex -eq $routes[$i].interfaceindex } | Enable-NetAdapter
                }
            }

            Write-Host $([DateTime]::Now),$routes.nexthop

            Start-Sleep -s 60
        }
    } else {
        ShowPopUpVpn "The specified interface is not connected..."
    }
}

Function ShowPopUpVpn($message) {
    Write-Warning $message
    $shell = New-Object -ComObject "WScript.Shell"
    $button = $shell.Popup($message, 0, "Watch VPN Adpater", 0)
}
