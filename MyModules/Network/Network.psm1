Function Hide-PCapNetworkInterface {
    $adapters = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
    $networks = "HKLM:\SYSTEM\CurrentControlSet\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}"

    Push-Location $adapters

    Get-ChildItem -ErrorAction 0  | ForEach-Object {  
        $node = $_.pspath  
        $netId = (Get-ItemProperty $node).NetCfgInstanceId
        if ($netId) {
            $name = (Get-ItemProperty "$networks\$netId\Connection").Name

            if ($name -like "*Npcap Loopback Adapter*") {
                "Found PCap Looback Interface, reconfiguring as an endpoint device."
                New-ItemProperty $node -Name '*NdisDeviceType' -PropertyType dword -Value 1 -ea 0 
            }
        }
    }

    Pop-Location

    Get-WmiObject Win32_NetworkAdapter | Where-Object {$_.Name -like "Npcap Loopback Adapter" } | ForEach-Object {  
        Write-Host -nonew "Disabling $($_.name) ... " 
        $result = $_.Disable()  
        if ($result.ReturnValue -eq -0) { Write-Host " success." } else { Write-Host " failed." }  
      
        Write-Host -nonew "Enabling $($_.name) ... " 
        $result = $_.Enable()  
        if ($result.ReturnValue -eq -0) { Write-Host " success." } else { Write-Host " failed." }  
    }
}

Export-ModuleMember Hide-PCapNetworkInterface
