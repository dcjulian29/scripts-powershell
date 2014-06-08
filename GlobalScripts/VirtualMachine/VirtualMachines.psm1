Function Check-Elevation {
    Write-Verbose "Checking for elevation... "
    $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    if (($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) -eq $false)  {
        Write-Verbose "Not an administrator session!"
        Write-Error "This command requires elevation"
        "$false"
    } else {
        Write-Verbose "Yes, this is an elevated session."
        "$true"
    }
}

Function Get-FullPath {
    param ( [string] $file )

    "$((Get-Item -Path $file).Directory.FullName.TrimEnd('\'))\$((Get-Item -Path $file).Name)"
}

Function Mount-VHDX {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path
    )

    Mount-DiskImage -ImagePath $fullPath | Out-Null

    Get-PSDrive | Out-Null # Work around to "force" drive letter to be available

    $disk = Get-DiskImage -ImagePath $fullPath | Get-Disk
    $partitions = Get-Partition -DiskNumber $disk.Number
    $partition = $partitions | where { $_.DriveLetter -match '[^\W]' }
    $driveLetter = ([regex]"[^A-Z]").Replace($partition.DriveLetter, "")

    "$($driveLetter):"
}

Function Create-ReferenceVHDX {
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

    if (-not $(Check-Elevation)) { return }

    Set-Content $vhdxFile "TEMP"
    $fullPath = Get-FullPath $vhdxFile
    Remove-Item $vhdxFile

    Write-Verbose "Reference VHDX file will be $($fullPath)"

    if (-not ([string]::IsNullOrEmpty($edition))) {
        Convert-WindowsImage -SourcePath $isoFile `
            -VHDPath $fullPath -VHDFormat VHDX -VHDPartitionStyle GPT `
            -SizeBytes $diskSize -Edition $edition
    } else {
        Convert-WindowsImage -SourcePath $isoFile `
            -VHDPath $fullPath -VHDFormat VHDX -VHDPartitionStyle GPT `
            -SizeBytes $diskSize
    }
    
    Write-Verbose "Created Reference Disk [$($vhdxFile)]"
}

Function Create-DifferencingVHDX {
    [Cmdletbinding()]
    param (
      [string] $referenceDisk,
      [string] $vhdxFile
    )

    if (-not $(Check-Elevation)) { return }

    Write-Verbose "Creating a Differencing Disk [$($vhdxFile)] based on [$($referenceDisk)]"

    New-VHD –Path $vhdxFile -Differencing –ParentPath $referenceDisk
}

Function Create-DataVHDX {
    [Cmdletbinding()]
    param (
      [string] $vhdxFile,
      [UInt64] $diskSize = 80GB
    )

    if (-not $(Check-Elevation)) { return }

    Write-Verbose "Creating a Data Disk [$($vhdxFile)] sized [$($diskSize)]"
    New-VHD -Path $vhdxFile -SizeBytes $diskSize -Dynamic

    $fullPath = Get-FullPath $vhdxFile

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

    if (-not $(Check-Elevation)) { return }

    Set-VMDvdDrive -VMName $virtualMachineName `
        -ControllerNumber 1  -ControllerLocation 0 `
        -Path $isoFile
}

Function Make-UnattendForDhcpIp {
    [Cmdletbinding()]
    param (
        [string] $vhdxFile,
        [string] $unattendTemplate,
        [string] $computerName
    )

    if (-not $(Check-Elevation)) { return }

    $fullPath = Get-FullPath $vhdxFile

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

    if (-not $(Check-Elevation)) { return }

    $fullPath = Get-FullPath $vhdxFile

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

Function Inject-VMStartUpScriptFile {
    [Cmdletbinding()]
    param (
        [string] $vhdxFile,
        [string] $scriptFile
    )

    if (-not $(Check-Elevation)) { return }

    $fullPath = Get-FullPath $vhdxFile

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
    $pshellcmd = "%WINDIR%\Setup\Scripts\$($scriptName)"

    Set-Content -Path $virtualCommand -Encoding Ascii `
        -Value "@$($pshellexe) -ExecutionPolicy unrestricted -NoLogo -Command $($pshellcmd)" 
  
    Dismount-DiskImage -ImagePath $fullPath
}

Function Inject-VMStartUpScriptBlock {
    [Cmdletbinding()]
    param (
        [parameter(Mandatory=$true)]
        [string] $vhdxFile,
        [parameter(Mandatory=$true)]
        [ScriptBlock] $scriptBlock
    )

    $scriptFile =  `
        [IO.Path]::GetTempFileName() | Rename-Item -NewName { $_ -replace 'tmp$', 'ps1' } –PassThru

    Write-Verbose "Creating temporary script file for injection: $($scriptFile.FullName)"
    Write-Output $scriptBlock | Out-File $scriptFile.FullName -Encoding Ascii

    Inject-VMStartUpScriptFile -vhdxFile $vhdxFile -ScriptFile $scriptFile

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

    for ($i = 1; $i -lt $totalPasses; $i++) {
        Write-Progress -Activity "Processing Updates From: $updatesPath" `
            -Status ("Loop {0} of {1}" -f $i, $totalPasses)
        for ($j = 1; $j -le $totalUpdates; $j++) {
            $update = $updates[$j]
            $patchProgress = ($j / $totalUpdates) * 100
            Write-Progress -Id  1 `
                -Activity "Injecting Patches To: $($fullPath)" `
                -Status "Injecting Update: $($update.FullName)" `
                -PercentComplete $patchProgress
            Invoke-Expression "dism /image:$drive /add-package /packagepath:'$($update.fullname)'"
        }
    }

    Invoke-Expression "dism /image:$drive /Cleanup-Image /spsuperseded"

    Dismount-DiskImage -ImagePath $fullPath
}

Function Create-VirtualMachine {
    [Cmdletbinding()]
    param (
        [string] $vhdxFile,
        [string] $computerName,
        [string] $virtualSwitch = "External",
        [Int64] $memory = 1024MB,
        [Int64] $maximumMemory = 8GB,
        [Int32] $cpu = 2
    )

    if (-not $(Check-Elevation)) { return }

    $fullPath = Get-FullPath $vhdxFile

    New-VM –Name $computerName –VHDPath $fullPath -Generation 2
    Connect-VMNetworkAdapter -VMName $computerName –Switch $virtualSwitch 
    Set-VMProcessor -VMName $computerName -Count $cpu
    Set-VMMemory -VMName $computerName -DynamicMemoryEnabled $true -StartupBytes $memory
    Set-VMMemory -VMName $computerName -MaximumBytes $maximumMemory -MinimumBytes $memory
    Set-VM -Name $computerName -AutomaticStartAction Nothing 
    Set-Vm -Name $computerName -AutomaticStopAction ShutDown 
}

Function Create-VirtualMachineFromCsv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [Alias("CSV")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $csvFile,  
        [string] $virtualSwitch = "Internal",
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
        Create-DifferencingVHDX -referenceDisk $baseDisk -vhdxFile "$($vm.ComputerName).vhdx"
        Create-DataVHDX -vhdxFile "$($vm.ComputerName)-DATA.vhdx" -diskSize (0 + $vm.DataDrive)

        Make-UnattendForStaticIp -vhdxFile "$($vm.ComputerName).vhdx" -unattendTemplate $unattend `
            -computerName "$($vm.ComputerName)" -networkAddress "$($vm.IP)" `
            -gatewayAddress "$($vm.Gateway)" -nameServer "$($vm.DNS)"

        Create-VirtualMachine -vhdxFile "$($vm.ComputerName).vhdx" -computerName "$($vm.ComputerName)" `
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

Function Create-VirtualMachineFromName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $computerName,  
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $isoFile,
        [string] $virtualSwitch = "Internal",
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

    Create-ReferenceVHDX -isoFile $isoFile -vhdxFile "$($computerName).vhdx" `
        -edition "ServerStandardEval"

    Create-DataVHDX -vhdxFile "$($computerName)-DATA.vhdx"

    Make-UnattendForStaticIp -vhdxFile "$($computerName).vhdx" -unattendTemplate $unattend `
        -computerName "$($computerName)" -networkAddress "$($networkAddress)" `
        -gatewayAddress "$($gateway)" -nameServer "$($nameServer)"

    Create-VirtualMachine -vhdxFile "$($computerName).vhdx" -computerName "$($computerName)" `
        -virtualSwitch $virtualSwitch

    Add-VMHardDiskDrive -VMName "$($computerName)" -Path "$($computerName)-DATA.vhdx"

    Pop-Location
}

Export-ModuleMember Create-ReferenceVHDX
Export-ModuleMember Create-DifferencingVHDX
Export-ModuleMember Create-DataVHDX
Export-ModuleMember Connect-IsoToVirtual
Export-ModuleMember Make-UnattendForDhcpIp
Export-ModuleMember Make-UnattendForStaticIp
Export-ModuleMember Inject-VMStartUpScriptFile
Export-ModuleMember Inject-VMStartUpScriptBlock
Export-ModuleMember Inject-UpdatesToVhdx
Export-ModuleMember Create-VirtualMachine
Export-ModuleMember Create-VirtualMachineFromCsv
Export-ModuleMember Create-VirtualMachineFromName

Set-Alias New-SystemVHDX Create-ReferenceVHDX
Export-ModuleMember -Alias New-SystemVHDX
