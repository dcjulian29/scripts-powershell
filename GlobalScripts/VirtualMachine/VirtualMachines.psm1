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

Function Create-ReferenceVHDX {
    [Cmdletbinding()]
    param (
      [string] $isoFile,
      [string] $vhdxFile,
      [string] $edition = $null,
      [uint64] $diskSize = 80GB
    )

    If   (-not (Test-Path $isoFile)) {
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

    Mount-DiskImage -ImagePath $fullPath

    $disk = Get-DiskImage -ImagePath $fullPath | Get-Disk
    $drive = (([string](Get-Partition -DiskNumber $disk.Number).DriveLetter) -split '\s')[2] + ":"

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

    Mount-DiskImage -ImagePath $fullPath

    $disk = Get-DiskImage -ImagePath $fullPath | Get-Disk
    $drive = (([string](Get-Partition -DiskNumber $disk.Number).DriveLetter) -split '\s')[2] + ":"

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

    Mount-DiskImage -ImagePath $fullPath

    $disk = Get-DiskImage -ImagePath $fullPath | Get-Disk
    $drive = (([string](Get-Partition -DiskNumber $disk.Number).DriveLetter) -split '\s')[2] + ":"

    Get-PSDrive | Out-Null # Work around to "force" drive letter to be available
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

Export-ModuleMember Create-ReferenceVHDX
Export-ModuleMember Create-DifferencingVHDX
Export-ModuleMember Create-DataVHDX
Export-ModuleMember Connect-IsoToVirtual
Export-ModuleMember Make-UnattendForDhcpIp
Export-ModuleMember Make-UnattendForStaticIp
Export-ModuleMember Inject-VMStartUpScriptFile
Export-ModuleMember Inject-VMStartUpScriptBlock
Export-ModuleMember Create-VirtualMachine
