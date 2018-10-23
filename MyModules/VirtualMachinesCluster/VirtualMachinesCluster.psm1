function New-ClusteredVirtualMachineFromISO {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory=$true)]
        [string] $ComputerName,
        [parameter(Mandatory=$true)]
        [string] $ClusterNode,
        [parameter(Mandatory=$true)]
        [string] $IsoPath,
        [string] $VirtualSwitch = "vTRUNK",
        [Int64] $StartupMemory = 1024MB,
        [Int64] $MaximumMemory = 4GB,
        [Int32] $ProcessorCount = 2,
        [Int64] $DiskSize = 80GB,
        [Int32] $VLAN = 0,
        [Int32] $ClusterVolume = 1,
        [System.Management.Automation.Runspaces.PSSession]$Session
    )

    $ComputerName = $ComputerName.ToUpperInvariant()
    $clusterDirectory = "C:\ClusterStorage\Volume$ClusterVolume"

    if (-not $Session) {
        $Session = New-PSSession -ComputerName $ClusterNode
    }

    if ($ClusterNode -ne $Session.ComputerName) {
        throw "Remote Session does not match Cluster Node Name." 
    }

    $script = @"    
    if (Test-Path "$clusterDirectory\$ComputerName") {
        Remove-Item -Recurse -Force "$clusterDirectory\$ComputerName"
    }

    New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName"
    New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName\Snapshots"
    New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName\Virtual Hard Disks"
    New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName\Virtual Machines"    

    New-VM -Name $ComputerName ``
        -NewVHDPath "$clusterDirectory\$ComputerName\Virtual Hard Disks\$ComputerName.Vhdx" ``
        -NewVHDSizeBytes $DiskSize -Generation 2 -Path "$clusterDirectory"

    Set-VMMemory -VMName $ComputerName -DynamicMemoryEnabled `$true -StartupBytes $StartupMemory
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
    Set-VMFirmware $ComputerName -FirstBootDevice `$(Get-VMDvdDrive $ComputerName)
    Set-VMFirmware $ComputerName -EnableSecureBoot Off

    Get-VM -Name $ComputerName | Add-ClusterVirtualMachineRole
"@

    $scriptBlock = [Scriptblock]::Create($script) 

    if (-not $session) {
        throw "No Session to Cluster Node $ClusterNode!"
    } else {
        Invoke-Command -Session $session -ScriptBlock $scriptBlock
    }
}

function New-ClusteredVMFromExistingDisk {
    [Cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [string] $ComputerName,
        [parameter(Mandatory=$true)]
        [string] $ClusterNode,
        [parameter(Mandatory=$true)]
        [string] $Vhdx,
        [switch] $KeepExistingDisk,
        [string] $VirtualSwitch = "vTRUNK",
        [Int64] $StartupMemory = 1024MB,
        [Int64] $MaximumMemory = 4GB,
        [Int32] $ProcessorCount = 2,
        [Int32] $VLAN,
        [Int32] $ClusterVolume = 1,
        [System.Management.Automation.Runspaces.PSSession]$Session
    )
    
    $ComputerName = $ComputerName.ToUpperInvariant()
    $clusterDirectory = "C:\ClusterStorage\Volume$ClusterVolume"

    if (-not $Session) {
        $Session = New-PSSession -ComputerName $ClusterNode
    }

    if ($ClusterNode -ne $Session.ComputerName) {
        throw "Remote Session does not match Cluster Node Name." 
    }

    $script = @"
    `$ErrorActionPreference = "Stop"

    if (`$$KeepExistingDisk) {
        Remove-Item -Recurse -Force "$clusterDirectory\$ComputerName\Snapshots" -ErrorAction SilentlyContinue
        Remove-Item -Recurse -Force -Path "$clusterDirectory\$ComputerName\Virtual Machines" -ErrorAction SilentlyContinue

        New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName\Snapshots"
        New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName\Virtual Machines"    

        if (-not (Test-Path "$clusterDirectory\$ComputerName\Virtual Hard Disks")) {
            New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName\Virtual Hard Disks"
        }
    } else {
        Remove-Item -Recurse -Force "$clusterDirectory\$ComputerName"

        New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName"
        New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName\Snapshots"
        New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName\Virtual Hard Disks"
        New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName\Virtual Machines"    
   }

    `$ErrorActionPreference = "Stop"

    if (-not (Test-Path "$Vhdx")) {
        throw "Unable to find the image disk."
    }

    Write-Output "Using $Vhdx..."

    if (-not `$$KeepExistingDisk) {
        Copy-Item -Path "$Vhdx" -Destination "$clusterDirectory\$ComputerName\Virtual Hard Disks\$ComputerName.Vhdx" -Force -Verbose
    }

    New-VM -Name $ComputerName ``
        –VHDPath "$clusterDirectory\$ComputerName\Virtual Hard Disks\$ComputerName.Vhdx" ``
        -Generation 2 -Path "$clusterDirectory"

    Set-VMMemory -VMName $ComputerName -DynamicMemoryEnabled `$true -StartupBytes $StartupMemory
    Set-VMMemory -VMName $ComputerName -MinimumBytes 1GB -MaximumBytes $MaximumMemory
    
    Set-VM -Name $ComputerName -AutomaticStartAction Start
    Set-VM -Name $ComputerName -AutomaticStopAction Save

    Set-VMProcessor -VMName $ComputerName -CompatibilityForMigrationEnabled 1

    Connect-VMNetworkAdapter -VMName $ComputerName –Switch $VirtualSwitch

    if ($VLAN -gt 0) {
        Set-VMNetworkAdapterVlan -VMName $ComputerName -Access -VlanId $VLAN
    }
    
    Set-VMProcessor -VMName $ComputerName -Count $ProcessorCount
    
    Get-VM -Name $ComputerName | Add-ClusterVirtualMachineRole
"@

    $scriptBlock = [Scriptblock]::Create($script) 

    if (-not $session) {
        throw "No Session to Cluster Node $ClusterNode!"
    } else {
        Invoke-Command -Session $session -ScriptBlock $scriptBlock
    }
}

function New-ClusteredVMFromWindowsBaseDisk {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory=$true)]
        [string] $ComputerName,
        [parameter(Mandatory=$true)]
        [string] $ClusterNode,
        [string] $VirtualSwitch = "vTRUNK",
        [Int64] $StartupMemory = 1024MB,
        [Int64] $MaximumMemory = 4GB,
        [Int32] $ProcessorCount = 2,
        [Int32] $VLAN,
        [Int32] $ClusterVolume = 1,
        [Int32] $OsVersion = 2016,
        [switch] $UseCore,
        [switch] $CopyDiskFile,
        [System.Management.Automation.Runspaces.PSSession]$Session
    )

    $ComputerName = $ComputerName.ToUpperInvariant()
    $clusterDirectory = "C:\ClusterStorage\Volume$ClusterVolume"

    if (-not $Session) {
        $Session = New-PSSession -ComputerName $ClusterNode
    }

    if ($ClusterNode -ne $Session.ComputerName) {
        throw "Remote Session does not match Cluster Node Name." 
    }

    $script = @"    
    if (Test-Path "$clusterDirectory\$ComputerName") {
        Remove-Item -Recurse -Force "$clusterDirectory\$ComputerName"
    }

    New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName"
    New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName\Snapshots"
    New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName\Virtual Hard Disks"
    New-Item -ItemType Directory -Path "$clusterDirectory\$ComputerName\Virtual Machines"    

    if ("$UseCore" -eq "True") {
        `$BaseImage = "`$((Get-ChildItem -Path "$clusterDirectory\Win$OsVersion*ServerCoreBase*.vhdx").FullName)"
    } else {
        `$BaseImage = "`$((Get-ChildItem -Path "$clusterDirectory\Win$OsVersion*ServerBase*.vhdx").FullName)"
    }

    if (-not `$BaseImage) {
        throw "Unable to find the base image disk."
    }

    Write-Information "Using `$BaseImage..."

    if ("$CopyDiskFile" -eq "True") {
        Copy-Item -Path `$BaseImage -Destination "$clusterDirectory\$ComputerName\Virtual Hard Disks\$ComputerName.Vhdx" -Verbose
    } else {
        New-VHD –Path "$clusterDirectory\$ComputerName\Virtual Hard Disks\$ComputerName.Vhdx" ``
            -Differencing –ParentPath `$BaseImage
    }

    New-VM -Name $ComputerName ``
        –VHDPath "$clusterDirectory\$ComputerName\Virtual Hard Disks\$ComputerName.Vhdx" ``
        -Generation 2 -Path "$clusterDirectory"

    Set-VMMemory -VMName $ComputerName -DynamicMemoryEnabled `$true -StartupBytes $StartupMemory
    Set-VMMemory -VMName $ComputerName -MinimumBytes 1GB -MaximumBytes $MaximumMemory
    
    Set-VM -Name $ComputerName -AutomaticStartAction Start
    Set-VM -Name $ComputerName -AutomaticStopAction Save

    Set-VMProcessor -VMName $ComputerName -CompatibilityForMigrationEnabled 1

    Connect-VMNetworkAdapter -VMName $ComputerName –Switch $VirtualSwitch

    if ($VLAN -gt 0) {
        Set-VMNetworkAdapterVlan -VMName $ComputerName -Access -VlanId $VLAN
    }
    
    Set-VMProcessor -VMName $ComputerName -Count $ProcessorCount
    
    Get-VM -Name $ComputerName | Add-ClusterVirtualMachineRole
"@

    $scriptBlock = [Scriptblock]::Create($script) 

    if (-not $session) {
        throw "No Session to Cluster Node $ClusterNode!"
    } else {
        Invoke-Command -Session $session -ScriptBlock $scriptBlock
    }
}

###############################################################################

Export-ModuleMember New-ClusteredVirtualMachineFromISO
Export-ModuleMember New-ClusteredVMFromWindowsBaseDisk
Export-ModuleMember New-ClusteredVMFromExistingDisk
