Function Watch-DefaultGatewayChangeVpn($IfName) {
    $adapter = Get-NetAdapter | Where-Object { $_.Name -eq $IfName } 
    if ($adapter.Status -eq "Up") {
        while ($true) {
            $routes = Get-WmiObject -Class Win32_IP4RouteTable `
                | Where-Object { $_.destination -eq '0.0.0.0' -and $_.mask -eq '0.0.0.0'} `
                | Sort-Object metric1 | Select-Object nexthop, metric1, interfaceindex

            Write-Host $([DateTime]::Now),$routes.nexthop

            if ($routes.interfaceindex -ne $adapter.ifIndex) {
                $adapter | Disable-NetAdapter -Confirm:$false
                
                $connectedAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
                
                foreach ($gateway in $connectedAdapters) {
                    $gateway | Disable-NetAdapter -Confirm:$false
                }

                $adapter | Enable-NetAdapter

                ShowPopUpVpn "Default Gateway is not currently set to the VPN adapter!"
 
                foreach ($gateway in $connectedAdapters) {
                    $gateway | Enable-NetAdapter
                }
                
                ShowPopUpVpn "Click Ok to resume watch."
            }

            Start-Sleep -s 15
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
