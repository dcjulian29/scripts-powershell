$ComputerName = "TEST1"
$IsoPath = "C:\ISO\ubuntu-mate-19.04-desktop-amd64.iso"
$VirtualSwitch = "vTRUNK"
$StartupMemory = 2GB
$MaximumMemory = 6GB
$ProcessorCount = 4
$DiskSize = 300GB
$VLAN = 192
$ClusterVolume = 2


    $ComputerName = $ComputerName.ToUpperInvariant()
    $clusterDirectory = "C:\ClusterStorage\Volume$ClusterVolume"



    if (Test-Path "$clusterDirectory\$ComputerName") {
        Remove-Item -Recurse -Force "$clusterDirectory\$ComputerName"
    }

    New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName" | Out-Null
    New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName\Snapshots" | Out-Null
    New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName\Virtual Hard Disks" | Out-Null
    New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName\Virtual Machines" | Out-Null

    New-VM -Name $ComputerName `
        -NewVHDPath "$clusterDirectory\$ComputerName\Virtual Hard Disks\$ComputerName.Vhdx" `
        -NewVHDSizeBytes $DiskSize -Generation 2 -Path "$clusterDirectory"

    Set-VMMemory -VMName $ComputerName -DynamicMemoryEnabled $true -StartupBytes $StartupMemory
    Set-VMMemory -VMName $ComputerName -MinimumBytes 1GB -MaximumBytes $MaximumMemory

    Set-VM -Name $ComputerName -AutomaticStartAction Start
    Set-VM -Name $ComputerName -AutomaticStopAction Save

    Set-VMProcessor -VMName $ComputerName -CompatibilityForMigrationEnabled 1

    Connect-VMNetworkAdapter -VMName $ComputerName –Switch $VirtualSwitch

    if ($VLAN -gt 0) {
        Set-VMNetworkAdapterVlan -VMName $ComputerName -Access -VlanId $VLAN
    }

    Set-VMProcessor -VMName $ComputerName -Count $ProcessorCount

    Add-VMDvdDrive -VMName $ComputerName -Path $IsoPath
    Set-VMFirmware $ComputerName -FirstBootDevice $(Get-VMDvdDrive $ComputerName)
    Set-VMFirmware $ComputerName -EnableSecureBoot Off

    Get-VM -Name $ComputerName | Add-ClusterVirtualMachineRole
