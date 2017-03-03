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

Function New-NanoServerVhdx {
<#
    .SYNOPSIS
        Prepares an Hyper-V Vhdx file ready-to-boot Windows Server 2016 Technical Preview 3 - Nano Server

    .PARAMETER IsoPath
    This is the path to the Windows Server 2016 Technical Preview 3 ISO downloaded from:
    https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-technical-preview

    .PARAMETER VhdxFile
    This is the path and name of the new Nano Server VHDX File.

    .PARAMETER StoragePackage
        Adds support of the File Server role and other storage components

    .PARAMETER FailoverClusterPackage
        Adds support of Failover Clustering

    .PARAMETER ComputerName
    This is the Computer Name for the new Nano Server.

    .PARAMETER AdministratorPassword
    This is the Administrator account password for the new Nano Server.

    .PARAMETER IPAddress
    This is a Static IP address to assign to the first ethernet card in this Nano Server. If not passed it will use DHCP.

    .PARAMETER RegisteredOwner
    This is the Registered Owner that will be set for the Nano Server.

    .PARAMETER RegisteredCorporation
    This is the Registered Corporation name that will be set for the Nano Server.
#>
#Requires -Version 4.0

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ })]
        [String]$IsoPath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$VhdxFile,

        [switch]$StoragePackage,
        [switch]$FailoverClusterPackage,

        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 15)]
        [String]$ComputerName = "NanoServer",

        [ValidateNotNullOrEmpty()]
        [String]$AdministratorPassword = "P@ssw0rd",
        [String]$IPAddress,
        [string]$RegisteredOwner = "Contoso",
        [string]$RegisteredCorporation = "Contoso"
    )

    $WorkFolder = Join-Path -Path $env:TEMP -ChildPath 'NanoServer'
    $DismFolder = Join-Path -Path $WorkFolder -ChildPath "dism"
    $MountFolder = Join-Path -Path $WorkFolder -ChildPath "mount"
    $TempVHDName = Join-Path -Path $WorkFolder -ChildPath "NanoServer.vhdx"
    $dism = Join-Path -Path $DismFolder -ChildPath "Dism.exe"

    if (-not (Test-Path -Path $WorkFolder -PathType Container)) {
        New-Item -Path $WorkFolder -ItemType Directory | Out-Null
    }

    Mount-DiskImage -ImagePath $IsoPath

    $DriveLetter = (Get-Diskimage -ImagePath $IsoPath | Get-Volume).DriveLetter

    If (-not (Test-Path -Path $DismFolder -PathType Container)) {
        New-Item -Path $DismFolder -ItemType Directory | Out-Null
    }

    while (-not (Test-Path "${DriveLetter}:\")) {
        Sleep 2
    }

    Copy-Item -Path "$($DriveLetter):\Sources\api*downlevel*.dll" -Destination $DismFolder -Force
    Copy-Item -Path "$($DriveLetter):\Sources\*dism*" -Destination $DismFolder -Force
    Copy-Item -Path "$($DriveLetter):\Sources\*provider*" -Destination $DismFolder -Force

    Convert-WindowsImage -SourcePath "$($DriveLetter):\NanoServer\NanoServer.wim" -Edition 1 `
        -VHDPartitionStyle 'GPT' -VHDFormat VHDX -SizeBytes 10GB -VHDPath $TempVHDName

    If (-not (Test-Path -Path $MountFolder -PathType Container)) {
        New-Item -Path $MountFolder -ItemType Directory | Out-Null
    }

    Invoke-Expression "$dism /Mount-Image /ImageFile:$TempVHDName /Index:1 /MountDir:$MountFolder"

    Invoke-Expression "$dism /Add-Package /PackagePath:$($DriveLetter):\NanoServer\packages\Microsoft-NanoServer-OEM-Drivers-Package.cab /Image:$MountFolder"
    Invoke-Expression "$dism /Add-Package /PackagePath:$($DriveLetter):\NanoServer\packages\en-US\Microsoft-NanoServer-OEM-Drivers-Package.cab /Image:$MountFolder"

    if ($FailoverClusterPackage) {
        Invoke-Expression "$dism /Add-Package /PackagePath:$($DriveLetter):\NanoServer\packages\Microsoft-NanoServer-FailoverCluster-Package.cab /Image:$MountFolder"
        Invoke-Expression "$dism /Add-Package /PackagePath:$($DriveLetter):\NanoServer\packages\en-US\Microsoft-NanoServer-FailoverCluster-Package.cab /Image:$MountFolder"
    }

    if ($StoragePackage) {
        Invoke-Expression "$dism /Add-Package /PackagePath:$($DriveLetter):\NanoServer\packages\Microsoft-NanoServer-Storage-Package.cab /Image:$MountFolder"
        Invoke-Expression "$dism /Add-Package /PackagePath:$($DriveLetter):\NanoServer\packages\en-US\Microsoft-NanoServer-Storage-Package.cab /Image:$MountFolder"
    }

    Invoke-Expression "$dism /Add-Package /PackagePath:$($DriveLetter):\NanoServer\packages\Microsoft-NanoServer-Defender-Package.cab /Image:$MountFolder"
    Invoke-Expression "$dism /Add-Package /PackagePath:$($DriveLetter):\NanoServer\packages\en-US\Microsoft-NanoServer-Defender-Package.cab /Image:$MountFolder"

    Invoke-Expression "$dism /Add-Package /PackagePath:$($DriveLetter):\NanoServer\packages\Microsoft-OneCore-ReverseForwarders-Package.cab /Image:$MountFolder"
    Invoke-Expression "$dism /Add-Package /PackagePath:$($DriveLetter):\NanoServer\packages\en-US\Microsoft-OneCore-ReverseForwarders-Package.cab /Image:$MountFolder"

    Invoke-Expression "$dism /Add-Package /PackagePath:$($DriveLetter):\NanoServer\packages\Microsoft-NanoServer-Guest-Package.cab /Image:$MountFolder"
    Invoke-Expression "$dism /Add-Package /PackagePath:$($DriveLetter):\NanoServer\packages\en-US\Microsoft-NanoServer-Guest-Package.cab /Image:$MountFolder"

    $UnattendedContent = @"
<?xml version='1.0' encoding='utf-8'?>
<unattend xmlns="urn:schemas-microsoft-com:unattend" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <settings pass="offlineServicing">
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
      <ComputerName>$ComputerName</ComputerName>
    </component>
  </settings>
  <settings pass="oobeSystem">
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
      <UserAccounts>
        <AdministratorPassword>
           <Value>$AdministratorPassword</Value>
           <PlainText>true</PlainText>
        </AdministratorPassword>
      </UserAccounts>
      <TimeZone>Eastern Standard Time</TimeZone>
    </component>
  </settings>
  <settings pass="specialize">
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
      <RegisteredOwner>$RegisteredOwner</RegisteredOwner>
      <RegisteredOrganization>$RegisteredCorporation</RegisteredOrganization>
    </component>
  </settings>
</unattend>
"@

    $UnattendFile = Join-Path -Path $WorkFolder -ChildPath 'Unattend.xml'

    Set-Content -Path $UnattendFile -Value $UnattendedContent

    Invoke-Expression "$dism /Image:$MountFolder /Apply-Unattend:$UnattendFile"

    New-Item -Path "$MountFolder\windows\panther" -ItemType Directory | Out-Null

    Copy-Item -Path $UnattendFile -Destination "$MountFolder\windows\panther"

    If ($IPaddress -ne $null) {
        New-Item "$MountFolder\Windows\Setup\Scripts" -ItemType Directory | Out-Null
        Set-Content -Path "$MountFolder\Windows\Setup\Scripts\SetupComplete.cmd" `
            -Value @"
@echo off
netsh int ip set address name="Ethernet" source=static address=$IPAddress
netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
schtasks /Create /TN IPBootDisplay /SC ONSTART /RU SYSTEM /Delay 0000:30 /TR ipconfig > nul
cls
ping localhost -n 30 > nul 2>&1
ipconfig
"@
    }

    Invoke-Expression "$dism /Unmount-Image /MountDir:$MountFolder /Commit"

    Dismount-DiskImage -ImagePath $IsoPath

    Move-Item -Path $TempVHDName -Destination $VhdxFile -Force -Verbose

    Remove-Item -Path $WorkFolder -Recurse -Force

    Write-Output "NanoServer VHDX is ready for deployment..."
}

Function Connect-IsoToVirtual {
    [Cmdletbinding()]
    param (
        [string] $virtualMachineName,
        [string] $isoFile
    )

    if (-not $(Assert-Elevation)) { return }

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
    $Path = Get-FullFilePath $File

    $drive = Mount-VHDX $fullPath

    Write-Verbose "VHDX file mounted on $($drive)..."

    Copy-File -Path $File -Destination "$drive\$RelativeDestination"

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
        [string] $virtualSwitch = "External",
        [Int64] $memory = 1024MB,
        [Int64] $maximumMemory = 8GB,
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

Function Install-DevVmPackage {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $package
    )

    $logFile = "$env:SYSTEMDRIVE\etc\logs\$($env:COMPUTERNAME)-$package.log"

    if (Test-Path "$env:SYSTEMDRIVE\etc\logs\$($env:COMPUTERNAME)-$package.log") {
        Move-Item "$env:SYSTEMDRIVE\etc\logs\$($env:COMPUTERNAME)-$package.log" `
            "$env:SYSTEMDRIVE\etc\logs\$($env:COMPUTERNAME)-$package.old.log" -Force
    }

    Start-Transcript $logFile -Verbose

    # For some reason, my PSModules environment keeps getting reset installing packages,
    # so let explictly add it each and everytime
    $env:PSModulePath = "$(Split-Path $profile)\Modules;$($env:PSModulePath)"
    $env:PSModulePath = "$(Split-Path $profile)\MyModules;$($env:PSModulePath)"

    Get-Module -ListAvailable | Out-Null

    Invoke-Expression "$env:ChocolateyInstall\chocolateyinstall\chocolatey.ps1 install $package -y"

    Stop-Transcript

    # Now lets check for errors...
    if (Get-Content $logFile | Select-String -Pattern "Write-Error") {
        Write-Warning "An error occurred during the last package ($package) install..."
        Write-Warning "Review the log file: $logFile"
        Write-Warning "And then decide whether to continue..."

        Read-Host "Press Enter to continue with next package"
    }
}

Function Create-DevVM {
    $StartScript = "${env:SYSTEMDRIVE}\etc\vm\startup.ps1"
    $unattend = "${env:SYSTEMDRIVE}\etc\vm\unattend.xml"
    $BaseImage = "$((Get-VMHost).VirtualHardDiskPath)\Win10Base.vhdx"
    $Computer = "$(($env:COMPUTERNAME).ToUpper())DEV"
    $vhdx = "$Computer.vhdx"
    $password = $(Get-Credential -Message "Enter Password for VM...")
    $startLayout = "$($env:SYSTEMDRIVE)\home\vm\etc\StartScreenLayout.xml"

    Push-Location $((Get-VMHost).VirtualHardDiskPath)

    $vm = Get-VM -Name $computerName -ErrorAction SilentlyContinue

    if ($vm) {
        if ($vm.state -ne "Off") {
            $vm | Stop-VM
        }
    
        $vm | Remove-VM
    }

    if (Test-Path "$vhdx") {
        Remove-Item -Confirm -Path $vhdx
    }

    if (Test-Path "$vhdx") {
        throw "VHDX File Still Exists! Can't Continue..."
    }

    New-DifferencingVHDX -referenceDisk $Base10 -vhdxFile "$vhdx"

    $unattendFile = "$env:TEMP\$(Split-Path $unattend -Leaf)" 
    Copy-Item -Path $unattend -Destination $unattendFile  -Force

    (Get-Content $unattendFile).replace("P@ssw0rd", $password.GetNetworkCredential().password) `
        | Set-Content $unattendFile

    Make-UnattendForDhcpIp -vhdxFile $vhdx -unattendTemplate $unattendFile -computerName $computerName

    Inject-VMStartUpScriptFile -vhdxFile $vhdx -scriptFile $StartScript -argument "myvm-development"

    Inject-StartLayout -vhdxFile $vhdx -layoutFile $startLayout

    $Destination = "${env:SystemRoot}\Setup\Scripts"
    $Source = "${env:SYSTEMDRIVE}\etc\vm"
    $c = "$Source\${env:COMPUTERNAME}DEV"

    Inject-FileToVM -vhdxFile $vhdx -File "$c.id" -RelativeDestination $Destination
    Inject-FileToVM -vhdxFile $vhdx -File "$Source\server.id" -RelativeDestination $Destination
    Inject-FileToVM -vhdxFile $vhdx -File "$Source\server.name" -RelativeDestination $Destination
    Inject-FileToVM -vhdxFile $vhdx -File "$c.key" -RelativeDestination $Destination
    Inject-FileToVM -vhdxFile $vhdx -File "$c.cert" -RelativeDestination $Destination

    $numOfCpu = $(Get-WmiObject -class Win32_processor | Select-Object NumberOfLogicalProcessors).NumberOfLogicalProcessors / 2
    $maxMem = $(Get-WMIObject -class Win32_PhysicalMemory | Measure-Object -Property capacity -Sum `
        | Select-Object @{N="TotalRam"; E={$_.Sum}}).TotalRam * .60

    $maxMem = [Math]::Round($maxMem)
    $maxMem = $maxMem - ($maxMem % 2MB)

    if ($maxMem -gt 8GB) { $maxMem = 8GB }

    New-VirtualMachine -vhdxFile $vhdx -computerName $computerName `
        -memory 2GB -maximumMemory $maxMem -virtualSwitch "VTRUNK" -cpu $numOfCpu -verbose

    Set-VMMemory -VMName $computerName -MaximumBytes $maxMem -MinimumBytes 1GB
    Set-VM -Name $computerName -AutomaticStartAction Nothing
    Set-Vm -Name $computerName -AutomaticStopAction Save    

    Pop-Location

    Start-VM -VMName $computerName

    Start-Sleep 5

    & vmconnect.exe localhost $computerName
}

Export-ModuleMember Install-DevVmPackage
Export-ModuleMember Create-DevVM
Export-ModuleMember Convert-WindowsImage
Export-ModuleMember Get-HyperVReport
Export-ModuleMember New-SystemVHDX
Export-ModuleMember New-DifferencingVHDX
Export-ModuleMember New-DataVHDX
Export-ModuleMember New-NanoServerVhdx
Export-ModuleMember Connect-IsoToVirtual
Export-ModuleMember Make-UnattendForDhcpIp
Export-ModuleMember Make-UnattendForStaticIp
Export-ModuleMember Inject-FileToVM
Export-ModuleMember Inject-StartLayout
Export-ModuleMember Inject-VMStartUpScriptFile
Export-ModuleMember Inject-VMStartUpScriptBlock
Export-ModuleMember Inject-UpdatesToVhdx
Export-ModuleMember New-VirtualMachine
Export-ModuleMember New-VirtualMachineFromCsv
Export-ModuleMember New-VirtualMachineFromName

Set-Alias New-ReferenceVHDX New-SystemVHDX
Export-ModuleMember -Alias New-ReferenceVHDX
