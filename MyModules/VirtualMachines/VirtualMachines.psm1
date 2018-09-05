. $PSScriptRoot\Convert-WindowsImage.ps1
. $PSScriptRoot\Get-HyperVReport.ps1

Function Mount-VHDX {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path
    )

    $fullPath = Get-FullFilePath $Path

    Mount-DiskImage -ImagePath $fullPath | Out-Null

    Get-PSDrive | Out-Null # Work around to "force" drive letter to be available

    $disk = Get-DiskImage -ImagePath $fullPath | Get-Disk
    $partitions = Get-Partition -DiskNumber $disk.Number
    $partition = $partitions | where { $_.DriveLetter -match '[^\W]' }
    $driveLetter = ([regex]"[^A-Z]").Replace($partition.DriveLetter, "")

    "$($driveLetter):"
}

Function New-SystemVHDX {
    [Cmdletbinding()]
    param (
      [string] $isoFile,
      [string] $vhdxFile,
      [string] $edition = $null,
      [uint64] $diskSize = 80GB
    )

    if (-not (Test-Path $isoFile)) {
        Write-Error "ISO File does not exist!"
        return
    }

    if (-not $(Assert-Elevation)) { return }

    Set-Content $vhdxFile "TEMP"
    $fullPath = Get-FullFilePath $vhdxFile
    Remove-Item $vhdxFile

    Write-Verbose "System VHDX file will be $($fullPath)"

    if (-not ([string]::IsNullOrEmpty($edition))) {
        Convert-WindowsImage -SourcePath $isoFile `
            -VHDPath $fullPath -VHDFormat VHDX -VHDPartitionStyle GPT `
            -SizeBytes $diskSize -Edition $edition
    } else {
        Convert-WindowsImage -SourcePath $isoFile `
            -VHDPath $fullPath -VHDFormat VHDX -VHDPartitionStyle GPT `
            -SizeBytes $diskSize
    }

    Write-Verbose "Created System Disk [$($vhdxFile)]"
}

Function New-DifferencingVHDX {
    [Cmdletbinding()]
    param (
      [string] $referenceDisk,
      [string] $vhdxFile
    )

    if (-not $(Assert-Elevation)) { return }

    Write-Verbose "Creating a Differencing Disk [$($vhdxFile)] based on [$($referenceDisk)]"

    New-VHD –Path $vhdxFile -Differencing –ParentPath $referenceDisk
}

Function New-DataVHDX {
    [Cmdletbinding()]
    param (
      [string] $vhdxFile,
      [UInt64] $diskSize = 80GB
    )

    if (-not $(Assert-Elevation)) { return }

    Write-Verbose "Creating a Data Disk [$($vhdxFile)] sized [$($diskSize)]"
    New-VHD -Path $vhdxFile -SizeBytes $diskSize -Dynamic

    $fullPath = Get-FullFilePath $vhdxFile

    Mount-DiskImage -ImagePath $fullPath

    $diskNumber = (Get-DiskImage -ImagePath $fullPath | Get-Disk).Number

    Write-Verbose "Initializing Data Disk..."

    Initialize-Disk -Number $diskNumber -PartitionStyle GPT
    $partition = New-Partition -DiskNumber $diskNumber -UseMaximumSize `
        -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}'

    Write-Verbose "Formatting Data Disk..."

    Format-Volume -FileSystem NTFS -Partition $partition -Confirm:$false

    Dismount-DiskImage -ImagePath $fullPath
}

Function Connect-IsoToVirtual {
    [Cmdletbinding()]
    param (
        [string] $virtualMachineName,
        [string] $isoFile
    )

    if (-not $(Assert-Elevation)) { return }

    Add-VMDvdDrive -VMName $virtualMachineName
    
    Set-VMDvdDrive -VMName $virtualMachineName -Path $isoFile
}

Function Make-UnattendForDhcpIp {
    [Cmdletbinding()]
    param (
        [string] $vhdxFile,
        [string] $unattendTemplate,
        [string] $computerName
    )

    if (-not $(Assert-Elevation)) { return }

    $fullPath = Get-FullFilePath $vhdxFile

    Write-Verbose "Injecting unattend.xml into $($fullPath)"

    $drive = Mount-VHDX $fullPath

    $xml = [xml](Get-Content $unattendTemplate)

    # Change ComputerName
    $xml.unattend.settings.component | Where-Object { $_.Name -eq "Microsoft-Windows-Shell-Setup" } |
        ForEach-Object {
            if ($_.ComputerName) {
                $_.ComputerName = $computerName
            }
        }

    $xml.Save("$($drive)\unattend.xml")

    Dismount-DiskImage -ImagePath $fullPath
}

Function Make-UnattendForStaticIp {
    [Cmdletbinding()]
    param (
        [string] $vhdxFile,
        [string] $unattendTemplate,
        [string] $computerName,
        [string] $networkAddress,
        [string] $gatewayAddress,
        [string] $nameServer
    )

    if (-not $(Assert-Elevation)) { return }

    $fullPath = Get-FullFilePath $vhdxFile

    Write-Verbose "Injecting unattend.xml into $($fullPath)"

    $drive = Mount-VHDX $fullPath

    $xml = [xml](Get-Content $unattendTemplate)

    # Change ComputerName
    $xml.unattend.settings.component | Where-Object { $_.Name -eq "Microsoft-Windows-Shell-Setup" } |
        ForEach-Object {
            if ($_.ComputerName) {
                $_.ComputerName = $computerName
            }
        }

    # Change IP address
    $xml.unattend.settings.component | Where-Object { $_.Name -eq "Microsoft-Windows-TCPIP" } |
        ForEach-Object {
            if ($_.Interfaces) {
                $ht='#text'
                $_.interfaces.interface.unicastIPaddresses.ipaddress.$ht = $networkAddress
                $_.interfaces.interface.routes.route.nexthopaddress = $gatewayAddress
            }
        }

    # Change DNS Server address
    $xml.Unattend.Settings.Component | Where-Object { $_.Name -eq "Microsoft-Windows-DNS-Client" } |
        ForEach-Object {
            if ($_.Interfaces) {
                $ht='#text'
                $_.Interfaces.Interface.DNSServerSearchOrder.Ipaddress.$ht = $nameServer
            }
        }

    $xml.Save("$($drive)\unattend.xml")

    Dismount-DiskImage -ImagePath $fullPath
}

Function Inject-FileToVM {
    [Cmdletbinding()]
    param (
        [string] $vhdxFile,
        [string] $File,
        [string] $RelativeDestination
    )

    if (-not $(Assert-Elevation)) { return }

    $fullPath = Get-FullFilePath $vhdxFile
    $drive = Mount-VHDX $fullPath

    Write-Verbose "VHDX file mounted on $($drive)..."

    $File = Get-FullFilePath $File
    Copy-Item -Path $File -Destination "$drive\$RelativeDestination"

    Dismount-DiskImage -ImagePath $fullPath
}

Function Inject-FilesToVM {
    [Cmdletbinding()]
    param (
        [string] $vhdxFile,
        [string[]] $Files,
        [string] $RelativeDestination
    )

    if (-not $(Assert-Elevation)) { return }

    $fullPath = Get-FullFilePath $vhdxFile
    $drive = Mount-VHDX $fullPath

    Write-Verbose "VHDX file mounted on $($drive)..."

    foreach ($file in $files) {
        $File = Get-FullFilePath $File
        Copy-Item -Path $File -Destination "$drive\$RelativeDestination"
    }

    Dismount-DiskImage -ImagePath $fullPath
}

Function Inject-StartLayout {
    [Cmdletbinding()]
    param (
        [string] $vhdxFile,
        [string] $layoutFile
    )

    if (-not $(Assert-Elevation)) { return }

    $fullPath = Get-FullFilePath $vhdxFile
    $layoutPath = Get-FullFilePath $layoutFile

    $drive = Mount-VHDX $fullPath

    Write-Verbose "VHDX file mounted on $($drive)..."

    if (Test-Path $layoutPath ) {
        Import-StartLayout -LayoutPath $layoutPath -MountPath $drive
    }

    Dismount-DiskImage -ImagePath $fullPath
}

Function Inject-VMStartUpScriptFile {
    [Cmdletbinding()]
    param (
        [string] $vhdxFile,
        [string] $scriptFile,
        [string] $arguments
    )

    if (-not $(Assert-Elevation)) { return }

    $fullPath = Get-FullFilePath $vhdxFile

    $drive = Mount-VHDX $fullPath

    Write-Verbose "VHDX file mounted on $($drive)..."

    $scriptPath = "$((Get-Item -Path $scriptFile).Directory.FullName.TrimEnd('\'))"
    $scriptName = "$((Get-Item -Path $scriptFile).Name)"

    $virtualRoot = "$($drive)\Windows\Setup\Scripts"
    $virtualCommand = "$($virtualRoot)\SetupComplete.cmd"
    $virtualScript = "$($virtualRoot)\$($scriptName)"

    if (-not (Test-Path $virtualRoot)) {
        New-Item -Type Directory -Path $drive -Name "\Windows\Setup\Scripts" | Out-Null
    }

    Copy-Item -Path $scriptFile -Destination $virtualScript

    $pshellexe = "%WINDIR%\System32\WindowsPowerShell\v1.0\powershell.exe"
    $pshellcmd = "%WINDIR%\Setup\Scripts\$($scriptName) $arguments"

    Set-Content -Path $virtualCommand -Encoding Ascii `
        -Value "@$($pshellexe) -ExecutionPolicy unrestricted -NoLogo -Command $($pshellcmd)"

    Dismount-DiskImage -ImagePath $fullPath
}

Function Inject-VMStartUpScriptBlock {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory=$true)]
        [string] $vhdxFile,
        [string] $arguments,
        [parameter(Mandatory=$true)]
        [ScriptBlock] $scriptBlock
    )

    $scriptFile =  `
        [IO.Path]::GetTempFileName() | Rename-Item -NewName { $_ -replace 'tmp$', 'ps1' } –PassThru

    Write-Verbose "Creating temporary script file for injection: $($scriptFile.FullName)"
    Write-Output $scriptBlock | Out-File $scriptFile.FullName -Encoding Ascii

    Inject-VMStartUpScriptFile -vhdxFile $vhdxFile -ScriptFile $scriptFile -Arguments $arguments

    Remove-Item $scriptFile
}

Function Inject-UpdatesToVhdx {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$vhdx,
        [Parameter(Mandatory=$true)]
        [string]$updatesPath
    )

    $fullPath = Get-FullFilePath $vhdx

    $drive = Mount-VHDX $fullPath

    Write-Output "VHDX file mounted on drive: $drive"

    $updates = Get-ChildItem -path $updatesPath | `
        where {($_.extension -eq ".msu") -or ($_.extension -eq ".cab")} | `
        Select-Object fullname

    $totalPasses = 3
    $totalUpdates = $updates.Length

    for ($i = 1; $i -le $totalPasses; $i++) {
        Write-Progress -Activity "Processing Updates From: $updatesPath" `
            -Status ("Pass {0} of {1}" -f $i, $totalPasses)
        for ($j = 1; $j -lt $totalUpdates; $j++) {
            $update = $updates[$j]
            $patchProgress = ($j / $totalUpdates) * 100
            Write-Progress -Id  1 `
                -Activity "Injecting Patches To: $($fullPath)" `
                -Status "Injecting Update: $($update.FullName)" `
                -PercentComplete $patchProgress
            Invoke-Expression "dism /image:$drive /add-package /packagepath:'$($update.fullname)'" | Out-Null
        }
    }

    Invoke-Expression "dism /image:$drive /Cleanup-Image /spsuperseded" | Out-Null

    Dismount-DiskImage -ImagePath $fullPath
}

Function New-VirtualMachine {
    [Cmdletbinding()]
    param (
        [string] $vhdxFile,
        [string] $computerName,
        [string] $virtualSwitch = "Default Switch",
        [Int64] $memory = 1024MB,
        [Int64] $maximumMemory = 4GB,
        [Int32] $cpu = 2,
        [string] $RemoteHost = "$($env:COMPUTERNAME)"
    )

    if (-not $(Assert-Elevation)) { return }

    New-VM –Name $computerName –VHDPath $vhdxFile -Generation 2 -ComputerName $RemoteHost
    Connect-VMNetworkAdapter -VMName $computerName –Switch $virtualSwitch  -ComputerName $RemoteHost
    Set-VMProcessor -VMName $computerName -Count $cpu -ComputerName $RemoteHost
    Set-VMMemory -VMName $computerName -DynamicMemoryEnabled $true -StartupBytes $memory -ComputerName $RemoteHost
    Set-VMMemory -VMName $computerName -MaximumBytes $maximumMemory -MinimumBytes $memory -ComputerName $RemoteHost
    Set-VM -Name $computerName -AutomaticStartAction Nothing -ComputerName $RemoteHost
    Set-Vm -Name $computerName -AutomaticStopAction ShutDown -ComputerName $RemoteHost
}

Function New-VirtualMachineFromCsv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [Alias("CSV")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $csvFile,
        [string] $virtualSwitch = "LAB",
        [Parameter(Mandatory=$true)]
        [string] $isoFile,
        [Parameter(Mandatory=$true)]
        [string] $baseDisk,
        [Parameter(Mandatory=$true)]
        [string] $unattend,
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $virtualStorage = "C:\Virtual Machines"
    )

    Push-Location $virtualStorage

    foreach ($vm in (Import-Csv -Path $csvFile)) {
        New-DifferencingVHDX -referenceDisk $baseDisk -vhdxFile "$($vm.ComputerName).vhdx"
        New-DataVHDX -vhdxFile "$($vm.ComputerName)-DATA.vhdx" -diskSize (0 + $vm.DataDrive)

        Make-UnattendForStaticIp -vhdxFile "$($vm.ComputerName).vhdx" -unattendTemplate $unattend `
            -computerName "$($vm.ComputerName)" -networkAddress "$($vm.IP)" `
            -gatewayAddress "$($vm.Gateway)" -nameServer "$($vm.DNS)"

        New-VirtualMachine -vhdxFile "$($vm.ComputerName).vhdx" -computerName "$($vm.ComputerName)" `
            -virtualSwitch $virtualSwitch -memory (0 + $vm.Memory) #-cpu (0 + $vm.Cpu)

        if (-not ([string]::IsNullOrEmpty($vm.DataDrive))) {
            Add-VMHardDiskDrive -VMName "$($vm.ComputerName)" `
                -Path "$($vm.ComputerName)-DATA.vhdx" -diskSize (0 + $vm.DataDrive)
        }

        if (-not ([string]::IsNullOrEmpty($vm.StartupScript))) {
            Inject-VMStartUpScriptFile -vhdxFile "$($vm.ComputerName).vhdx" -scriptFile $vm.StartupScript
        }
    }

    Pop-Location
}

Function New-VirtualMachineFromName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $computerName,
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $isoFile,
        [string] $virtualSwitch = "LAB",
        [Parameter(Mandatory=$true)]
        [string] $networkAddress,
        [string] $gateway,
        [Parameter(Mandatory=$true)]
        [string] $nameServer,
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $unattend,
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $virtualStorage = "C:\Virtual Machines"
    )

    Push-Location $virtualStorage

    New-SystemVHDX -isoFile $isoFile -vhdxFile "$($computerName).vhdx" `
        -edition "ServerStandardEval"

    New-DataVHDX -vhdxFile "$($computerName)-DATA.vhdx"

    Make-UnattendForStaticIp -vhdxFile "$($computerName).vhdx" -unattendTemplate $unattend `
        -computerName "$($computerName)" -networkAddress "$($networkAddress)" `
        -gatewayAddress "$($gateway)" -nameServer "$($nameServer)"

    New-VirtualMachine -vhdxFile "$($computerName).vhdx" -computerName "$($computerName)" `
        -virtualSwitch $virtualSwitch

    Add-VMHardDiskDrive -VMName "$($computerName)" -Path "$($computerName)-DATA.vhdx"

    Pop-Location
}

Function New-ClusteredVirtualMachineFromISO {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory=$true)]
        [string] $Name,
        [parameter(Mandatory=$true)]
        [string] $ClusterNode,
        [parameter(Mandatory=$true)]
        [string] $ISOPath,
        [string] $VirtualSwitch = "vTRUNK",
        [Int64] $StartupMemory = 1024MB,
        [Int64] $MaximumMemory = 4GB,
        [Int32] $ProcessorCount = 2,
        [Int64] $DiskSize = 80GB,
        [Int32] $VLAN = 0,
        [Int32] $ClusterVolume = 1,
        [System.Management.Automation.Runspaces.PSSession]$Session
    )

    $Name = $Name.ToUpperInvariant()
    $clusterDirectory = "C:\ClusterStorage\Volume$ClusterVolume"

    if (-not $Session) {
        $Session = New-PSSession -ComputerName $ClusterNode
    }

    if ($ClusterNode -ne $Session.ComputerName) {
        throw "Remote Session does not match Cluster Node Name." 
    }

    $script = @"    
    if (Test-Path "$clusterDirectory\$Name") {
        Remove-Item -Recurse -Force "$clusterDirectory\$Name"
    }

    New-Item -ItemType Directory -Path "$clusterDirectory\$Name"
    New-Item -ItemType Directory -Path "$clusterDirectory\$Name\Snapshots"
    New-Item -ItemType Directory -Path "$clusterDirectory\$Name\Virtual Hard Disks"
    New-Item -ItemType Directory -Path "$clusterDirectory\$Name\Virtual Machines"    

    New-VM -Name $Name ``
        -NewVHDPath "$clusterDirectory\$Name\Virtual Hard Disks\$Name.VHDX" ``
        -NewVHDSizeBytes $DiskSize -Generation 2 -Path "$clusterDirectory"

    Set-VMMemory -VMName $Name -DynamicMemoryEnabled `$true -StartupBytes $StartupMemory
    Set-VMMemory -VMName $Name -MinimumBytes 1GB -MaximumBytes $MaximumMemory
    
    Set-VM -Name $Name -AutomaticStartAction Start
    Set-VM -Name $Name -AutomaticStopAction Save

    Set-VMProcessor -VMName $Name -CompatibilityForMigrationEnabled 1

    Connect-VMNetworkAdapter -VMName $Name –Switch $VirtualSwitch

    if ($VLAN -gt 0) {
        Set-VMNetworkAdapterVlan -VMName $Name -Access -VlanId $VLAN
    }
    
    Set-VMProcessor -VMName $Name -Count $ProcessorCount
   
    Add-VMDvdDrive -VMName $Name -Path $ISOPath
    Set-VMFirmware $Name -FirstBootDevice `$(Get-VMDvdDrive $Name)
    Set-VMFirmware $Name -EnableSecureBoot Off

    Get-VM -Name $Name | Add-ClusterVirtualMachineRole
"@

    $scriptBlock = [Scriptblock]::Create($script) 

    if (-not $session) {
        throw "No Session to Cluster Node $ClusterNode!"
    } else {
        Invoke-Command -Session $session -ScriptBlock $scriptBlock
    }
}

Function New-ClusteredVMFromWindowsBaseDisk {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory=$true)]
        [string] $Name,
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

    $Name = $Name.ToUpperInvariant()
    $clusterDirectory = "C:\ClusterStorage\Volume$ClusterVolume"

    if (-not $Session) {
        $Session = New-PSSession -ComputerName $ClusterNode
    }

    if ($ClusterNode -ne $Session.ComputerName) {
        throw "Remote Session does not match Cluster Node Name." 
    }

    $script = @"    
    if (Test-Path "$clusterDirectory\$Name") {
        Remove-Item -Recurse -Force "$clusterDirectory\$Name"
    }

    New-Item -ItemType Directory -Path "$clusterDirectory\$Name"
    New-Item -ItemType Directory -Path "$clusterDirectory\$Name\Snapshots"
    New-Item -ItemType Directory -Path "$clusterDirectory\$Name\Virtual Hard Disks"
    New-Item -ItemType Directory -Path "$clusterDirectory\$Name\Virtual Machines"    

    #UseCore
    if ("$UseCore" -eq "True") {
        `$BaseImage = "`$((Get-ChildItem -Path "$clusterDirectory\Win$OsVersion*ServerCoreBase*.vhdx").FullName)"
    } else {
        `$BaseImage = "`$((Get-ChildItem -Path "$clusterDirectory\Win$OsVersion*ServerBase*.vhdx").FullName)"
    }

    if (-not `$BaseImage) {
        throw "Unable to find the base image disk."
    }

    Write-Output "Using `$BaseImage..."

    #CopyDiskFile
    if ("$CopyDiskFile" -eq "True") {
        Copy-Item -Path `$BaseImage -Destination "$clusterDirectory\$Name\Virtual Hard Disks\$Name.VHDX" -Verbose
    } else {
        New-VHD –Path "$clusterDirectory\$Name\Virtual Hard Disks\$Name.VHDX" ``
            -Differencing –ParentPath `$BaseImage
    }

    New-VM -Name $Name ``
        –VHDPath "$clusterDirectory\$Name\Virtual Hard Disks\$Name.VHDX" ``
        -Generation 2 -Path "$clusterDirectory"

    Set-VMMemory -VMName $Name -DynamicMemoryEnabled `$true -StartupBytes $StartupMemory
    Set-VMMemory -VMName $Name -MinimumBytes 1GB -MaximumBytes $MaximumMemory
    
    Set-VM -Name $Name -AutomaticStartAction Start
    Set-VM -Name $Name -AutomaticStopAction Save

    Set-VMProcessor -VMName $Name -CompatibilityForMigrationEnabled 1

    Connect-VMNetworkAdapter -VMName $Name –Switch $VirtualSwitch

    if ($VLAN -gt 0) {
        Set-VMNetworkAdapterVlan -VMName $Name -Access -VlanId $VLAN
    }
    
    Set-VMProcessor -VMName $Name -Count $ProcessorCount
    
    Get-VM -Name $Name | Add-ClusterVirtualMachineRole
"@

    $scriptBlock = [Scriptblock]::Create($script) 

    if (-not $session) {
        throw "No Session to Cluster Node $ClusterNode!"
    } else {
        Invoke-Command -Session $session -ScriptBlock $scriptBlock
    }
}

Function Compact-VHDX {
    [Cmdletbinding()]
    param (
      [ValidateScript({ Test-Path $(Resolve-Path $_) })]
      [string] $vhdxFile
    )

    if (-not $(Assert-Elevation)) { return }

    Write-Output "Attempting to mount $vhdxFile..."
    Mount-VHD -Path $vhdxFile -ReadOnly

    Write-Output "Attempting to compact $vhdxFile"
    Optimize-VHD -Path $vhdxFile -Mode Full 

    Write-Output "Attempting to dismount $vhdxFile"
    Dismount-VHD -path $vhdxFile
}

Function Initialize-WorkstationHyperV {
    $vm = "${env:SYSTEMDRIVE}\Virtual Machines"
    
    if (-not (Test-Path -Path $vm)) {
        New-Item -Path $vm -ItemType Directory | Out-Null
    }

    if (-not (Test-Path -Path "$vm\ISO")) {
        New-Item -Path "$vm\ISO" -ItemType Directory | Out-Null
    }
    
    Set-VMHost -VirtualMachinePath "${env:SYSTEMDRIVE}\" -VirtualHardDiskPath $vm
}

###############################################################################

Export-ModuleMember Convert-WindowsImage
Export-ModuleMember Get-HyperVReport
Export-ModuleMember New-SystemVHDX
Export-ModuleMember New-DifferencingVHDX
Export-ModuleMember New-DataVHDX
Export-ModuleMember Connect-IsoToVirtual
Export-ModuleMember Make-UnattendForDhcpIp
Export-ModuleMember Make-UnattendForStaticIp
Export-ModuleMember Inject-FileToVM
Export-ModuleMember Inject-FilesToVM
Export-ModuleMember Inject-StartLayout
Export-ModuleMember Inject-VMStartUpScriptFile
Export-ModuleMember Inject-VMStartUpScriptBlock
Export-ModuleMember Inject-UpdatesToVhdx
Export-ModuleMember New-VirtualMachine
Export-ModuleMember New-VirtualMachineFromCsv
Export-ModuleMember New-VirtualMachineFromName
Export-ModuleMember New-ClusteredVirtualMachineFromISO
Export-ModuleMember New-ClusteredVMFromWindowsBaseDisk
Export-ModuleMember Compact-VHDX
Export-ModuleMember Initialize-HyperV

Set-Alias New-ReferenceVHDX New-SystemVHDX
Export-ModuleMember -Alias New-ReferenceVHDX
