Function StopAndRemoveVM($ComputerName) {
    $vm = Get-VM -Name $ComputerName -ErrorAction SilentlyContinue

    if ($vm) {
        if ($vm.state -ne "Off") {
            $vm | Stop-VM
        }
    
        $vm | Remove-VM
    }

    $vhdx = "$((Get-VMHost).VirtualHardDiskPath)\$ComputerName.vhdx"

    if (Test-Path "$vhdx") {
        Remove-Item -Confirm -Path $vhdx
    }

    if (Test-Path "$vhdx") {
        throw "VHDX File Still Exists! Can't Continue..."
    }
}

Function New-DevVM {
    $ErrorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";
    $StartScript = "${env:SYSTEMDRIVE}\etc\vm\startup.ps1"
    $unattend = "${env:SYSTEMDRIVE}\etc\vm\unattend.xml"
    $BaseImage = "$((Get-VMHost).VirtualHardDiskPath)\Win10Base.vhdx"
    $ComputerName = "$(($env:COMPUTERNAME).ToUpper())DEV"
    $vhdx = "$ComputerName.vhdx"
    $password = $(Get-Credential -Message "Enter Password for VM...")
    $startLayout = "$($env:SYSTEMDRIVE)\etc\vm\StartScreenLayout.xml"

    StopAndRemoveVM $ComputerName

    Push-Location $((Get-VMHost).VirtualHardDiskPath)

    New-DifferencingVHDX -referenceDisk $BaseImage -vhdxFile "$vhdx"

    $unattendFile = "$env:TEMP\$(Split-Path $unattend -Leaf)" 
    Copy-Item -Path $unattend -Destination $unattendFile  -Force

    (Get-Content $unattendFile).replace("P@ssw0rd", $password.GetNetworkCredential().password) `
        | Set-Content $unattendFile

    Make-UnattendForDhcpIp -vhdxFile $vhdx -unattendTemplate $unattendFile -computerName $computerName

    Inject-VMStartUpScriptFile -vhdxFile $vhdx -scriptFile $StartScript -argument "myvm-development"

    Inject-StartLayout -vhdxFile $vhdx -layoutFile $startLayout

    $Destination = "Windows\Setup\Scripts\"
    $Source = "${env:SYSTEMDRIVE}\etc\syncthing"
    $c = "$Source\$ComputerName"

    $files = @(
        "$c.id"
        "$Source\server.id"
        "$Source\server.name"
        "$c.key"
        "$c.cert"
    )

    Inject-FilesToVM -vhdxFile $vhdx -Files $files -RelativeDestination $Destination

    $numOfCpu = $(Get-WmiObject -class Win32_processor | Select-Object NumberOfLogicalProcessors).NumberOfLogicalProcessors / 2
    $maxMem = $(Get-WMIObject -class Win32_PhysicalMemory | Measure-Object -Property capacity -Sum `
        | Select-Object @{N="TotalRam"; E={$_.Sum}}).TotalRam * .60

    $maxMem = [Math]::Round($maxMem)
    $maxMem = $maxMem - ($maxMem % 2MB)

    if ($maxMem -gt 8GB) { $maxMem = 8GB }

    New-VirtualMachine -vhdxFile $vhdx -computerName $computerName `
        -memory 2GB -maximumMemory $maxMem -cpu $numOfCpu -verbose

    Set-VMMemory -VMName $computerName -MaximumBytes $maxMem -MinimumBytes 1GB
    Set-VM -Name $computerName -AutomaticStartAction Nothing
    Set-Vm -Name $computerName -AutomaticStopAction Save    

    Pop-Location

    Start-VM -VMName $computerName

    Start-Process -FilePath "vmconnect.exe" -ArgumentList "127.0.0.1 $computerName"

    $ErrorActionPreference = $ErrorPreviousAction
}

Function Install-DevVmPackage {
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
        $Choco += "Invoke-Expression 'choco.exe install $Package -dv -y'"
    } else {
        $Choco += "Invoke-Expression 'choco.exe install $Package -y'"
    }

    $Command = @"
        `$logFile = "$logFile"

        Start-Transcript `$logFile

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
    if (Get-Content $logFile | Select-String -Pattern "^Failures$") {
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

Function New-WorkstationVM {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName
    )

    $computerName = $computerName.ToUpperInvariant()

    $ErrorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";
    $StartScript = "${env:SYSTEMDRIVE}\etc\vm\startup.ps1"
    $unattend = "${env:SYSTEMDRIVE}\etc\vm\unattend.xml"
    $BaseImage = "$((Get-VMHost).VirtualHardDiskPath)\Win10Base.vhdx"
    $vhdx = "$ComputerName.vhdx"
    $password = $(Get-Credential -Message "Enter Password for VM...")
    $startLayout = "$($env:SYSTEMDRIVE)\etc\vm\StartScreenLayout.xml"

    StopAndRemoveVM $ComputerName

    Push-Location $((Get-VMHost).VirtualHardDiskPath)

    New-DifferencingVHDX -referenceDisk $BaseImage -vhdxFile "$vhdx"

    $unattendFile = "$env:TEMP\$(Split-Path $unattend -Leaf)" 
    Copy-Item -Path $unattend -Destination $unattendFile  -Force

    (Get-Content $unattendFile).replace("P@ssw0rd", $password.GetNetworkCredential().password) `
        | Set-Content $unattendFile

    Make-UnattendForDhcpIp -vhdxFile $vhdx -unattendTemplate $unattendFile -computerName $computerName

    Inject-VMStartUpScriptFile -vhdxFile $vhdx -scriptFile $StartScript -argument "myvm-workstation"

    Inject-StartLayout -vhdxFile $vhdx -layoutFile $startLayout

    New-VirtualMachine -vhdxFile $vhdx -computerName $computerName -memory 2GB -Verbose

    Set-VMMemory -VMName $computerName -MinimumBytes 1GB
    Set-Vm -Name $computerName -AutomaticStopAction Save    

    Pop-Location

    Start-VM -VMName $computerName

    Start-Sleep 5

    Start-Process -FilePath "vmconnect.exe" -ArgumentList "127.0.0.1 $computerName"

    $ErrorActionPreference = $ErrorPreviousAction
}

Function New-ServerVM {
    param (
        [string]$ComputerName,
        [Int32]$OsVersion,
        [string]$UnattendFile ="${env:SYSTEMDRIVE}\etc\vm\unattend.server.xml"
    )

    $ErrorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";

    Push-Location $((Get-VMHost).VirtualHardDiskPath)

    $BaseImage = "$((Get-ChildItem -Path "Win$OsVersion*ServerBase*.vhdx").FullName)"

    $computerName = $computerName.ToUpperInvariant()
    $vhdx = "$ComputerName.vhdx"

    StopAndRemoveVM $ComputerName

    New-DifferencingVHDX -referenceDisk $BaseImage -vhdxFile "$vhdx"

    Make-UnattendForDhcpIp -vhdxFile $vhdx -unattendTemplate $unattendFile -computerName $computerName

    New-VirtualMachine -vhdxFile $vhdx -computerName $computerName -memory 2GB -Verbose

    Set-VMMemory -VMName $computerName -MinimumBytes 1GB
    Set-Vm -Name $computerName -AutomaticStopAction Save    

    Pop-Location

    Start-VM -VMName $computerName

    Start-Process -FilePath "vmconnect.exe" -ArgumentList "127.0.0.1 $computerName"

    $ErrorActionPreference = $ErrorPreviousAction
}

Function New-Server2012VM {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName
    )

    New-ServerVM $ComputerName 2012
}

Function New-Server2016VM {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName
    )

    New-ServerVM $ComputerName 2016
}

Function New-VMFromISO {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $ISOFilePath
    )

    $ErrorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";

    $computerName = $computerName.ToUpperInvariant()

    Push-Location $((Get-VMHost).VirtualHardDiskPath)

    $vhdx = "$ComputerName.vhdx"

    StopAndRemoveVM $ComputerName

    New-VHD -Path $vhdx -SizeBytes 80GB -Dynamic

    New-VirtualMachine -vhdxFile $vhdx -computerName $computerName -memory 4GB -Verbose

    Set-VMMemory -VMName $computerName -MinimumBytes 1GB
    Set-Vm -Name $computerName -AutomaticStopAction Save

    Add-VMDvdDrive -VMName $computerName -Path $ISOFilePath
    Set-VMFirmware $computerName -FirstBootDevice $(Get-VMDvdDrive $computerName)
    Set-VMFirmware $computerName -EnableSecureBoot Off

    Pop-Location

    Start-VM -VMName $computerName

    Start-Process -FilePath "vmconnect.exe" -ArgumentList "127.0.0.1 $computerName"

    $ErrorActionPreference = $ErrorPreviousAction
}

Export-ModuleMember Install-DevVmPackage
Export-ModuleMember New-DevVM

Export-ModuleMember New-WorkstationVM
Export-ModuleMember New-Server2012VM
Export-ModuleMember New-Server2016VM

Export-ModuleMember New-VMFromISO
