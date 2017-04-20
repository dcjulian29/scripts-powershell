Function Hide-InternalVirtualSwitches {
    Write-Output "Looking for Hyper-V Internal vSwitch to configure as endpoint device..."
    $adapters = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
    $networks = "HKLM:\SYSTEM\CurrentControlSet\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}"

    Push-Location $adapters

    Get-ChildItem -ErrorAction 0  | ForEach-Object {  
        $node = $_.pspath  
        $desc =  (Get-ItemProperty $node).DriverDesc
        if ($desc -like "*Hyper-V Virtual Ethernet Adapter*") {  
            $netId = (Get-ItemProperty $node).NetCfgInstanceId
            $name = (Get-ItemProperty "$networks\$netId\Connection").Name
            if ($name -like "*vEthernet (Internal)*") {
                "Found Hyper-V Internal Switch, reconfiguring as an endpoint device."
                New-ItemProperty $node -Name '*NdisDeviceType' -PropertyType dword -Value 1 -ea 0 
            }

            if ($name -like "*vEthernet (DockerNAT)*") {
                "Found Docker Internal Switch, reconfiguring as an endpoint device."
                New-ItemProperty $node -Name '*NdisDeviceType' -PropertyType dword -Value 1  -ea 0
            }

            if ($name -like "*vEthernet (HNS Internal NIC)*") {
                "Found Host Network Services Internal Switch, reconfiguring as an endpoint device."
                New-ItemProperty $node -Name '*NdisDeviceType' -PropertyType dword -Value 1  -ea 0
            }
        }  
    }

    Pop-Location

    Get-WmiObject win32_networkadapter | Where-Object {$_.name -like "Hyper-V Virtual Ethernet Adapter #*" } | ForEach-Object {  
        Write-Host -nonew "Disabling $($_.name) ... " 
        $result = $_.Disable()  
        if ($result.ReturnValue -eq -0) { Write-Host " success." } else { Write-Host " failed." }  
      
        Write-Host -nonew "Enabling $($_.name) ... " 
        $result = $_.Enable()  
        if ($result.ReturnValue -eq -0) { Write-Host " success." } else { Write-Host " failed." }  
    }
}

Export-ModuleMember Hide-InternalVirtualSwitches