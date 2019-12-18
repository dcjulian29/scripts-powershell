﻿function StopAndRemoveVM($computerName) {
    $vm = Get-VM -Name $computerName -ErrorAction SilentlyContinue

    if ($vm) {
        if ($vm.state -ne "Off") {
            $vm | Stop-VM
        }

        $vm | Remove-VM
    }

    $vhdx = "$((Get-VMHost).VirtualHardDiskPath)\$computerName.vhdx"

    if (Test-Path "$vhdx") {
        Remove-Item -Confirm -Path $vhdx
    }

    if (Test-Path "$vhdx") {
        throw "VHDX File Still Exists! Can't Continue..."
    }
}

###############################################################################

function New-DevVM {
    $errorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";
    $startScript = "${env:SYSTEMDRIVE}\etc\vm\startup.ps1"
    $unattend = "${env:SYSTEMDRIVE}\etc\vm\unattend.xml"
    $baseImage = "$((Get-VMHost).VirtualHardDiskPath)\Win10BaseDevelopment.vhdx"
    $computerName = "$(($env:COMPUTERNAME).ToUpper())DEV"
    $vhdx = "$computerName.vhdx"
    $password = $(Get-Credential -Message "Enter Password for VM..." -UserName "julian")
    $startLayout = "$($env:SYSTEMDRIVE)\etc\vm\StartScreenLayout.xml"

    StopAndRemoveVM $computerName

    Push-Location $((Get-VMHost).VirtualHardDiskPath)

    New-DifferencingVHDX -ReferenceDisk $BaseImage -VhdxFile "$vhdx"

    $unattendFile = "$env:TEMP\$(Split-Path $unattend -Leaf)"
    Copy-Item -Path $unattend -Destination $unattendFile  -Force

    (Get-Content $unattendFile).replace("P@ssw0rd", $password.GetNetworkCredential().password) `
        | Set-Content $unattendFile

    New-UnattendFile -VhdxFile $vhdx -UnattendTemplate $unattendFile -ComputerName $computerName

    Move-VMStartUpScriptFileToVM -VhdxFile $vhdx -ScriptFile $startScript -Argument "myvm-development"

    Move-StartLayoutToVM -VhdxFile $vhdx -LayoutFile $startLayout

    $destination = "Windows\Setup\Scripts\"
    $source = "${env:SYSTEMDRIVE}\etc\syncthing"
    $c = "$source\$computerName"

    $files = @(
        "$c.id"
        "$source\server.id"
        "$source\server.name"
        "$c.key"
        "$c.cert"
    )

    Move-FilesToVM -VhdxFile $vhdx -Files $files -RelativeDestination $destination

    $numOfCpu = $(Get-WmiObject -Class Win32_processor | Select-Object NumberOfLogicalProcessors).NumberOfLogicalProcessors / 2
    $maxMem = $(Get-WMIObject -Class Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum `
        | Select-Object @{N="TotalRam"; E={$_.Sum}}).TotalRam * .60

    $maxMem = [Math]::Round($maxMem)
    $maxMem = $maxMem - ($maxMem % 2MB)

    if ($maxMem -gt 8GB) { $maxMem = 8GB }

    New-VirtualMachine -VhdxFile $vhdx -ComputerName $computerName `
        -Memory 4GB -MaximumMemory $maxMem -CPU $numOfCpu -verbose

    Set-VMMemory -VMName $computerName -MaximumBytes $maxMem -MinimumBytes 1GB
    Set-VM -Name $computerName -AutomaticStartAction Nothing
    Set-Vm -Name $computerName -AutomaticStopAction Save
    Set-Vm -Name $computerName -AutomaticCheckpointsEnabled $false

    Set-VMProcessor -VMName $computerName -ExposeVirtualizationExtensions $true

    Pop-Location

    Start-VM -VMName $computerName

    Start-Process -FilePath "vmconnect.exe" -ArgumentList "localhost $computerName"

    $ErrorActionPreference = $errorPreviousAction
}

function New-LinuxDevVM {
    [cmdletbinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(ParameterSetName = "Ubuntu")]
        [Switch]$UseUbuntu,
        [Parameter(ParameterSetName = "Xubuntu")]
        [Switch]$UseXubuntu,
        [Parameter(ParameterSetName = "LinuxMint")]
        [Switch]$UseMint,
        [Parameter(ParameterSetName="Default")]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$IsoFilePath
    )

    $ErrorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";

    $computerName = "$(($env:COMPUTERNAME).ToUpper())LNXDEV"
    $vhdx = "$computerName.vhdx"

    if (-not $IsoFilePath) {
        $isoDir = "$((Get-VMHost).VirtualMachinePath)\ISO"

        if ($UseXubuntu) {
            $latest = Get-ChildItem -Filter "xubuntu-*" -Path $isoDir `
                | Sort-Object Name -Descending `
                | Select-Object -First 1
        }

        if ($UseMint) {
            $latest = Get-ChildItem -Filter "linuxmint-*" -Path $isoDir `
                | Sort-Object Name -Descending `
                | Select-Object -First 1
        }

        if ($UseUbuntu -or ($null -eq $latest)) {
            $latest = Get-ChildItem -Filter "ubuntu-mate-*" -Path $isoDir `
                | Sort-Object Name -Descending `
                | Select-Object -First 1
        }

        $isoFile = $latest.name

        $IsoFilePath = "$isoDir\$isoFile"
    }

    StopAndRemoveVM $computerName

    $numOfCpu = $(Get-WmiObject -class Win32_processor `
        | Select-Object NumberOfLogicalProcessors).NumberOfLogicalProcessors / 2
    $maxMem = $(Get-WMIObject -class Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum `
        | Select-Object @{N="TotalRam"; E={$_.Sum}}).TotalRam * .60

    $maxMem = [Math]::Round($maxMem)
    $maxMem = $maxMem - ($maxMem % 2MB)

    if ($maxMem -gt 8GB) { $maxMem = 8GB }

    Push-Location $((Get-VMHost).VirtualHardDiskPath)

    New-VHD -Path $vhdx -SizeBytes 80GB -Dynamic

    New-VirtualMachine -VhdxFile $vhdx -ComputerName $computerName `
        -Memory 2GB -MaximumMemory $maxMem -CPU $numOfCpu

    Connect-IsoToVirtual $computerName $IsoFilePath

    Set-VMFirmware $computerName -FirstBootDevice $(Get-VMDvdDrive $computerName)
    Set-VMFirmware $computerName -EnableSecureBoot Off

    Set-VMMemory -VMName $computerName -MaximumBytes $maxMem -MinimumBytes 1GB
    Set-VM -Name $computerName -AutomaticStartAction Nothing
    Set-Vm -Name $computerName -AutomaticStopAction Save
    Set-Vm -Name $computerName -AutomaticCheckpointsEnabled $false

    Pop-Location

    Start-VM -VMName $computerName

    Start-Process -FilePath "vmconnect.exe" -ArgumentList "localhost $computerName"

    $ErrorActionPreference = $errorPreviousAction
}

function Install-DevVmPackage {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Package,
        [Alias("dv")]
        [switch] $DebugVerbose
    )

    $date = Get-Date -Format "yyyyMMdd-hhmm"

    $logFile = "$env:SYSTEMDRIVE\etc\logs\$($env:COMPUTERNAME)-$package.$date.log"

    if ($DebugVerbose) {
        $choco = "Invoke-Expression 'choco.exe install $Package -dv -y'"
    } else {
        $choco = "Invoke-Expression 'choco.exe install $Package -y'"
    }

    $Command = @"
        Start-Transcript "$logFile"

        # For some reason, my PSModules environment keeps getting reset installing packages,
        # so let explictly add it each and everytime
        `$env:PSModulePath = "`$(Split-Path `$profile)\Modules;`$(`$env:PSModulePath)"
        `$env:PSModulePath = "`$(Split-Path `$profile)\MyModules;`$(`$env:PSModulePath)"

        Get-Module -ListAvailable | Out-Null

        $choco

        Stop-Transcript
"@

    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Command)
    $encodedCommand = [Convert]::ToBase64String($Bytes)

    powershell.exe -encodedCommand $encodedCommand

    # Now lets check for errors...
    if (Get-Content $logFile | Select-String -Pattern "^Failures|ERROR:") {
        Write-Warning "An error occurred during the last package ($package) install..."
        Write-Warning "Review the log file: $logFile"
        Write-Warning "And then decide whether to continue..."
    }

    if (Test-PendingReboot) {
        Write-Warning "One of the packages recently installed has set the PendingReboot flag..."
        Write-Warning "This may cause future packages to fail silently if it check this flag."

        Read-Host "Press Enter to Restart Computer"
        Restart-Computer -Force
    }
}

function Update-DevVmPackages {
    param(
        [Alias("dv")]
        [switch] $DebugVerbose
    )

    $date = Get-Date -Format "yyyyMMdd-hhmm"

    $logFile = "$env:SYSTEMDRIVE\etc\logs\$($env:COMPUTERNAME)-upgrade.$date.log"

    if ($DebugVerbose) {
        $choco = "Invoke-Expression 'choco.exe upgrade all -dv -y'"
    } else {
        $choco = "Invoke-Expression 'choco.exe upgrade all -y'"
    }

    $Command = @"
        Start-Transcript "$logFile"
        $choco
        Stop-Transcript
"@

    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Command)
    $encodedCommand = [Convert]::ToBase64String($Bytes)

    powershell.exe -encodedCommand $encodedCommand

    if (Test-PendingReboot) {
        Write-Warning "One of the packages recently upgraded has set the PendingReboot flag..."
    }
}

###############################################################################

Export-ModuleMember Install-DevVmPackage
Export-ModuleMember Update-DevVmPackages

Export-ModuleMember New-DevVM
Export-ModuleMember New-LinuxDevVM
