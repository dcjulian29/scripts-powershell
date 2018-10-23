. $PSScriptRoot\Convert-WindowsImage.ps1

function Mount-Vhdx {
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
    $partition = $partitions | Where-Object { $_.DriveLetter -match '[^\W]' }
    $driveLetter = ([regex]"[^A-Z]").Replace($partition.DriveLetter, "")

    "$($driveLetter):"
}

function New-SystemVhdx {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $IsoFile,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $VhdxFile,
        [string] $Edition = $null,
        [uint64] $DiskSize = 80GB
    )

    if (-not (Test-Path $IsoFile)) {
        Write-Error "ISO File does not exist!"
        return
    }

    if (-not $(Assert-Elevation)) { return }

    Set-Content $VhdxFile "TEMP"
    $fullPath = Get-FullFilePath $VhdxFile
    Remove-Item $VhdxFile

    Write-Information "System Vhdx file will be $($fullPath)"

    if (-not ([string]::IsNullOrEmpty($Edition))) {
        Convert-WindowsImage -SourcePath $IsoFile `
            -VHDPath $fullPath -VHDFormat Vhdx -VHDPartitionStyle GPT `
            -SizeBytes $DiskSize -Edition $Edition
    } else {
        Convert-WindowsImage -SourcePath $IsoFile `
            -VHDPath $fullPath -VHDFormat Vhdx -VHDPartitionStyle GPT `
            -SizeBytes $DiskSize
    }

    Write-Information "Created System Disk [$($VhdxFile)]"
}

function New-DifferencingVhdx {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $ReferenceDisk,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $VhdxFile
    )

    if (-not $(Assert-Elevation)) { return }

    Write-Info "Creating a Differencing Disk [$($VhdxFile)] based on [$($ReferenceDisk)]"

    New-VHD –Path $VhdxFile -Differencing –ParentPath $ReferenceDisk
}

function New-DataVhdx {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $VhdxFile,
        [UInt64] $DiskSize = 80GB
    )

    if (-not $(Assert-Elevation)) { return }

    Write-Info "Creating a Data Disk [$($VhdxFile)] sized [$($DiskSize)]"
    New-VHD -Path $VhdxFile -SizeBytes $DiskSize -Dynamic

    $fullPath = Get-FullFilePath $VhdxFile

    Mount-DiskImage -ImagePath $fullPath

    $diskNumber = (Get-DiskImage -ImagePath $fullPath | Get-Disk).Number

    Write-Info "Initializing Data Disk..."

    Initialize-Disk -Number $diskNumber -PartitionStyle GPT
    $partition = New-Partition -DiskNumber $diskNumber -UseMaximumSize `
        -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}'

    Write-Info "Formatting Data Disk..."

    Format-Volume -FileSystem NTFS -Partition $partition -Confirm:$false

    Dismount-DiskImage -ImagePath $fullPath
}
function New-SqlDataVhdx {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $VhdxFile,
        [UInt64] $DiskSize = 100GB
    )

    if (-not $(Assert-Elevation)) { return }

    Write-Info "Creating a SQL Data Disk [$($VhdxFile)] sized [$($DiskSize)]"
    New-VHD -Path $VhdxFile -SizeBytes $DiskSize -Dynamic

    $fullPath = Get-FullFilePath $VhdxFile

    Mount-DiskImage -ImagePath $fullPath

    $diskNumber = (Get-DiskImage -ImagePath $fullPath | Get-Disk).Number

    Write-Info "Initializing SQL Data Disk..."

    Initialize-Disk -Number $diskNumber -PartitionStyle GPT
    $partition = New-Partition -DiskNumber $diskNumber -UseMaximumSize `
        -GptType '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}'

    Write-Info "Formatting SQL Data Disk..."

    Format-Volume -FileSystem ReFS -Partition $partition -Confirm:$false -AllocationUnitSize 64KB

    Dismount-DiskImage -ImagePath $fullPath
}

function Connect-IsoToVirtual {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $VirtualMachineName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $IsoFile
    )

    if (-not $(Assert-Elevation)) { return }

    Add-VMDvdDrive -VMName $VirtualMachineName
    
    Set-VMDvdDrive -VMName $VirtualMachineName -Path $IsoFile
}

function New-UnattendFile {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $VhdxFile,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $UnattendTemplate,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $ComputerName,
        [string] $NetworkAddress = $null,
        [string] $GatewayAddress = $null,
        [string] $NameServer = $null
    )

    if (-not $(Assert-Elevation)) { return }

    $fullPath = Get-FullFilePath $VhdxFile

    Write-Verbose "Injecting unattend.xml into $($fullPath)"

    $drive = Mount-Vhdx $fullPath

    $xml = [xml](Get-Content $UnattendTemplate)

    # Change ComputerName
    $xml.unattend.settings.component | Where-Object { $_.Name -eq "Microsoft-Windows-Shell-Setup" } |
        ForEach-Object {
            if ($_.ComputerName) {
                $_.ComputerName = $ComputerName
            }
        }

    if ($null -ne $NetworkAddress) {
        # Change IP address
        $xml.unattend.settings.component | Where-Object { $_.Name -eq "Microsoft-Windows-TCPIP" } |
            ForEach-Object {
                if ($_.Interfaces) {
                    $ht='#text'
                    $_.interfaces.interface.unicastIPaddresses.ipaddress.$ht = $NetworkAddress
                    $_.interfaces.interface.routes.route.nexthopaddress = $GatewayAddress
                }
            }
    }

    if ($null -ne $NameServer) {
        # Change DNS Server address
        $xml.Unattend.Settings.Component | Where-Object { $_.Name -eq "Microsoft-Windows-DNS-Client" } |
            ForEach-Object {
                if ($_.Interfaces) {
                    $ht='#text'
                    $_.Interfaces.Interface.DNSServerSearchOrder.Ipaddress.$ht = $NameServer
                }
            }
    }

    $xml.Save("$($drive)\unattend.xml")

    Dismount-DiskImage -ImagePath $fullPath
}

function Move-FileToVM {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $VhdxFile,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $File,
        [string] $RelativeDestination = ""
    )

    if (-not $(Assert-Elevation)) { return }

    $fullPath = Get-FullFilePath $VhdxFile
    $drive = Mount-Vhdx $fullPath

    Write-Verbose "Vhdx file mounted on $($drive)..."

    $File = Get-FullFilePath $File
    Copy-Item -Path $File -Destination "$drive\$RelativeDestination"

    Dismount-DiskImage -ImagePath $fullPath
}

function Move-FilesToVM {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $VhdxFile,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]] $Files,
        [string] $RelativeDestination = ""
    )

    if (-not $(Assert-Elevation)) { return }

    $fullPath = Get-FullFilePath $VhdxFile
    $drive = Mount-Vhdx $fullPath

    Write-Verbose "Vhdx file mounted on $($drive)..."

    foreach ($file in $files) {
        $File = Get-FullFilePath $File
        Copy-Item -Path $File -Destination "$drive\$RelativeDestination"
    }

    Dismount-DiskImage -ImagePath $fullPath
}

function Move-StartLayoutToVM {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $VhdxFile,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $LayoutFile
    )

    if (-not $(Assert-Elevation)) { return }

    $fullPath = Get-FullFilePath $VhdxFile
    $layoutPath = Get-FullFilePath $LayoutFile

    $drive = Mount-Vhdx $fullPath

    Write-Verbose "Vhdx file mounted on $($drive)..."

    if (Test-Path $layoutPath ) {
        Import-StartLayout -LayoutPath $layoutPath -MountPath $drive
    }

    Dismount-DiskImage -ImagePath $fullPath
}

function Move-VMStartUpScriptFileToVM {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $VhdxFile,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $ScriptFile,
        [string] $Arguments
    )

    if (-not $(Assert-Elevation)) { return }

    $fullPath = Get-FullFilePath $VhdxFile

    $drive = Mount-Vhdx $fullPath

    Write-Verbose "Vhdx file mounted on $($drive)..."

    $scriptName = "$((Get-Item -Path $ScriptFile).Name)"
    $virtualRoot = "$($drive)\Windows\Setup\Scripts"
    $virtualCommand = "$($virtualRoot)\SetupComplete.cmd"
    $virtualScript = "$($virtualRoot)\$($scriptName)"

    if (-not (Test-Path $virtualRoot)) {
        New-Item -Type Directory -Path $drive -Name "\Windows\Setup\Scripts" | Out-Null
    }

    Copy-Item -Path $ScriptFile -Destination $virtualScript

    $pshellexe = "%WINDIR%\System32\WindowsPowerShell\v1.0\powershell.exe"
    $pshellcmd = "%WINDIR%\Setup\Scripts\$($scriptName) $Arguments"

    Set-Content -Path $virtualCommand -Encoding Ascii `
        -Value "@$($pshellexe) -ExecutionPolicy unrestricted -NoLogo -Command $($pshellcmd)"

    Dismount-DiskImage -ImagePath $fullPath
}

function Move-VMStartUpScriptBlockToVM {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory=$true)]
        [string] $VhdxFile,
        [string] $Arguments,
        [parameter(Mandatory=$true)]
        [ScriptBlock] $ScriptBlock
    )

    $ScriptFile =  `
        [IO.Path]::GetTempFileName() | Rename-Item -NewName { $_ -replace 'tmp$', 'ps1' } –PassThru

    Write-Verbose "Creating temporary script file for injection: $($ScriptFile.FullName)"
    Write-Output $ScriptBlock | Out-File $ScriptFile.FullName -Encoding Ascii

    Move-VMStartUpScriptFileToVM -VhdxFile $VhdxFile -ScriptFile $ScriptFile -Arguments $Arguments

    Remove-Item $ScriptFile
}

function New-VirtualMachine {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $VhdxFile,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $ComputerName,
        [string] $VirtualSwitch = "Default Switch",
        [Int64] $Memory = 1024MB,
        [Int64] $MaximumMemory = 4GB,
        [Int32] $CPU = 2,
        [string] $RemoteHost = "$($env:COMPUTERNAME)"
    )

    if (-not $(Assert-Elevation)) { return }

    New-VM –Name $ComputerName –VHDPath $VhdxFile -Generation 2 -ComputerName $RemoteHost
    Connect-VMNetworkAdapter -VMName $ComputerName –Switch $VirtualSwitch  -ComputerName $RemoteHost
    Set-VMProcessor -VMName $ComputerName -Count $CPU -ComputerName $RemoteHost
    Set-VMMemory -VMName $ComputerName -DynamicMemoryEnabled $true -StartupBytes $Memory -ComputerName $RemoteHost
    Set-VMMemory -VMName $ComputerName -MaximumBytes $MaximumMemory -MinimumBytes $Memory -ComputerName $RemoteHost
    Set-VM -Name $ComputerName -AutomaticStartAction Nothing -ComputerName $RemoteHost
    Set-Vm -Name $ComputerName -AutomaticStopAction ShutDown -ComputerName $RemoteHost
}

function Compress-Vhdx {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $VhdxFile
    )

    if (-not $(Assert-Elevation)) { return }

    Write-Output "Attempting to mount $VhdxFile..."
    Mount-VHD -Path $VhdxFile -ReadOnly

    Write-Output "Attempting to compact $VhdxFile"
    Optimize-VHD -Path $VhdxFile -Mode Full 

    Write-Output "Attempting to dismount $VhdxFile"
    Dismount-VHD -path $VhdxFile
}

function Initialize-WorkstationHyperV {
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
Export-ModuleMember New-SystemVhdx
Export-ModuleMember New-DifferencingVhdx
Export-ModuleMember New-DataVhdx
Export-ModuleMember Connect-IsoToVirtual
Export-ModuleMember New-UnattendFile
Export-ModuleMember Move-FileToVM
Export-ModuleMember Move-FilesToVM
Export-ModuleMember Move-StartLayoutToVM
Export-ModuleMember Move-VMStartUpScriptFileToVM
Export-ModuleMember Move-VMStartUpScriptBlockToVM
Export-ModuleMember New-VirtualMachine
Export-ModuleMember New-VirtualMachineFromName
Export-ModuleMember Compress-Vhdx
Export-ModuleMember Initialize-WorkstationHyperV

Set-Alias New-ReferenceVhdx New-SystemVhdx
Export-ModuleMember -Alias New-ReferenceVhdx
