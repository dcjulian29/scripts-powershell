function StopAndRemoveVM($ComputerName) {
    $vm = Get-VM -Name $ComputerName -ErrorAction SilentlyContinue

    if ($vm) {
        if ($vm.state -ne "Off") {
            $vm | Stop-VM -Force
        }

        $vm | Remove-VM -Force
    }

    $vhdx = "$((Get-VMHost).VirtualHardDiskPath)\$ComputerName.vhdx"

    if (Test-Path "$vhdx") {
        Remove-Item -Confirm -Path $vhdx
    }

    if (Test-Path "$vhdx") {
        throw "VHDX File Still Exists! Can't Continue..."
    }
}

function LatestIsoFile {
    param (
        [string]$Pattern
    )

    $isoDir = "$((Get-VMHost).VirtualMachinePath)\ISO"

    $latest = Get-ChildItem -Path $IsoDir `
        | Where-Object { $_.Name -match "$($Pattern).*" } `
        | Sort-Object Name -Descending `
        | Select-Object -First 1

    $isoFile = $latest.name

    "$isoDir\$isoFile"
}

###############################################################################

function New-LabCentOSServer {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [switch]$UseDefaultSwitch
    )

    $IsoFilePath = LatestIsoFile "CentOS-"
    New-LabVMFromISO -ComputerName $ComputerName -IsoFilePath $IsoFilePath `
        -UseDefaultSwitch:$UseDefaultSwitch.IsPresent
}

function New-LabDebianServer {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [switch]$UseDefaultSwitch
    )

    $IsoFilePath = LatestIsoFile "debian-"
    New-LabVMFromISO -ComputerName $ComputerName -IsoFilePath $IsoFilePath `
        -UseDefaultSwitch:$UseDefaultSwitch.IsPresent
}

function New-LabDomainController {
    param (
        [string]$ComputerName = "DC01",
        [string]$DomainName = "contoso.local",
        [psobject]$Credentials = $(Get-Credential `
            -Message "Enter administrative credentials for Domain Controller..." -Username "Administrator")
    )

    $errorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";

    $ComputerName = $ComputerName.ToUpperInvariant()
    $vhdx = "$((Get-VMHost).VirtualHardDiskPath)\$ComputerName.vhdx"
    $unattend = "${env:SYSTEMDRIVE}\etc\vm\unattend.firstdc.xml"

    $netBios = $DomainName.Substring(0, $DomainName.IndexOf('.')).ToUpperInvariant()

    StopAndRemoveVM $ComputerName

    New-DifferencingVHDX -ReferenceDisk "$((Get-VMHost).VirtualHardDiskPath)\Win2016ServerBase.vhdx" `
        -VhdxFile $vhdx

    $unattendFile = "$env:TEMP\$(Split-Path $unattend -Leaf)"
    Copy-Item -Path $unattend -Destination $unattendFile  -Force

    (Get-Content $unattendFile).replace("P@ssw0rd", $Credentials.GetNetworkCredential().password) `
        | Set-Content $unattendFile

    New-UnattendFile -VhdxFile $vhdx -UnattendTemplate $unattendFile `
        -ComputerName $ComputerName -NetworkAddress "10.10.10.111/24" `
        -GatewayAddress "10.10.10.10"

    $script = @"
    Start-Transcript -OutputDirectory "C:\Windows\Setup\Scripts"

    Write-Output "Starting SetupComplete at `$([DateTime]::Now)..."

    Set-Content -Path "C:\Windows\Setup\Scripts\install1.ps1" -Encoding Ascii -Value  `@"
    Start-Transcript -OutputDirectory "C:\Windows\Setup\Scripts"

    Write-Output "Disabling IPv6 Tunnels..."
    ```$view = [Microsoft.Win32.RegistryView]::Registry64

    ```$key = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, ```$view)

    ```$subKey =  ```$key.OpenSubKey("SYSTEM\CurrentControlSet\services\TCPIP6\Parameters", ```$true)
    ```$subKey.SetValue("DisabledComponents", 1)

    Write-Output "Installing Windows Features..."
    Install-Windowsfeature AD-Domain-Services -IncludeManagementTools -Verbose

    Write-Output "Configuring Active Directory..."
    ```$password = ConvertTo-SecureString  -string '$($Credentials.GetNetworkCredential().password)' ````
        -AsPlainText  -Force

    Install-ADDSForest -DomainName '$DomainName' -SafeModeAdministratorPassword ```$password -InstallDns ````
        -Force -NoRebootOnCompletion -Verbose

    Set-DnsServerForwarder -IPAddress "10.10.10.10" -PassThru

    Set-Content -Path "C:\Windows\Setup\Scripts\startup.bat" -Encoding Ascii -Value  `@"
    powershell.exe -NoProfile -NoLogo -NoExit -Command "& C:\Windows\Setup\Scripts\install2.ps1"
"``@

    Stop-Transcript

    Restart-Computer -Force -Verbose
"`@

    Set-Content -Path "C:\Windows\Setup\Scripts\install2.ps1" -Encoding Ascii -Value  `@"
    Start-Transcript -OutputDirectory "C:\Windows\Setup\Scripts"

    Install-WindowsFeature Rsat-AD-PowerShell, Web-Server -IncludeManagementTools
    Install-WindowsFeature DHCP -IncludeManagementTools

    Add-DhcpServerV4Scope -Name $DomainName ````
        -StartRange 10.10.10.200 -EndRange 10.10.10.225 -SubnetMask 255.255.255.0
    Set-DhcpServerV4OptionValue -DnsDomain $DomainName -DnsServer 10.10.10.111
    Set-DhcpServerV4OptionValue -Router 10.10.10.10
    Add-DhcpServerInDC -DnsName $ComputerName.$DomainName -Verbose

    New-ADUser -SamAccountName 'labuser' -Enable ```$true ````
        -UserPrincipalName 'labuser@$DomainName' -Name 'Lab User Account' ````
        -AccountPassword '$($Credentials.GetNetworkCredential().password)' `
        -ChangePasswordAtLogon ```$true

    Install-WindowsFeature Web-Scripting-Tools -IncludemanagementTools
    Install-WindowsFeature AD-Certificate, Adcs-Cert-Authority -IncludemanagementTools
    Install-WindowsFeature Adcs-Enroll-Web-Svc, Adcs-Web-Enrollment, Adcs-Enroll-Web-Pol -IncludemanagementTools

    ```$username   = "$netBios\Administrator"
    ```$pass = ConvertTo-SecureString -String '$($Credentials.GetNetworkCredential().password)' -AsPlainText -Force
    ```$cred = New-Object System.Management.Automation.PSCredential ```$username,```$pass

    Write-Output "Installing CA using ```$(```$cred.UserName)"
    Install-AdcsCertificationAuthority -CACommonName 'ContosoCA' -CAType 'EnterpriseRootCA' ````
        -KeyLength 2048 -Cred ```$cred -OverwriteExistingCAinDS -Force -Verbose

    Write-Output 'Installing ADCS web enrollment feature'

    Install-AdcsWebEnrollment -Force -Verbose

    New-WebBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https

    Write-Output "Waiting for $ComputerName certificate to be created"
    Gpupdate /Target:Computer /Force | Out-Null
    Start-Sleep -Seconds 5

    While (! (Get-ChildItem Cert:\LocalMachine\My | Where Subject -Match 'CN=$ComputerName.$DomainName')) {
      Write-Output "Sleeping for another 5 seconds waiting for $ComputerName certificate..."
      Start-sleep -seconds 5
    }

    ```$cert = (Get-ChildItem Cert:\localmachine\my | Where Subject -Match 'CN=$ComputerName.$DomainName')
    Write-Output "Certificate being used is: [```$(```$cert.thumbprint)]"

    Write-Output "Setting SSL bindings with this certificate"
    New-Item IIS:\SSLBindings\0.0.0.0!443 -value ```$cert

    Write-Output "######### Active Directory Configuration Complete."

    Write-Output "Removing Auto-Logon Registry Keys..."
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /f
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoLogonCount /f
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoLogonSID /f
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultDomainName /f
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /f

    Remove-Item C:\Windows\Setup\Scripts\*.ps1 -Verbose -Force
    Remove-Item C:\Windows\Setup\Scripts\*.bat -Verbose -Force
    Remove-Item C:\Windows\Setup\Scripts\*.cmd -Verbose -Force
    Remove-Item "`$(`$env:SYSTEMDRIVE)\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Start.bat" ````
        -Verbose -Force

    Write-Output "Turning UAC back on..."
    reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System ````
        /v EnableLUA /t REG_DWORD /d 1 /f

    Stop-Transcript

    Restart-Computer -Force -Verbose
"`@

    Write-Output "Install Scripts Written..."

    Write-Output "Removing 'unattend' Files..."

    if (Test-Path `$env:SYSTEMDRIVE\unattend.xml) {
        Remove-Item `$env:SYSTEMDRIVE\unattend.xml -Force
    }

    if (Test-Path `$env:SYSTEMDRIVE\Convert-WindowsImageInfo.txt) {
        Remove-Item `$env:SYSTEMDRIVE\Convert-WindowsImageInfo.txt -Force
    }

    Write-Output "Setting PowerShell Execution Policy..."
    reg add HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell ``
        /v ExecutionPolicy /t REG_SZ /d RemoteSigned /f

    Write-Output "Turning off UAC while startup scripts are running..."
    reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System ``
        /v EnableLUA /t REG_DWORD /d 0 /f

    Set-Content -Path "C:\Windows\Setup\Scripts\startup.bat" -Encoding Ascii -Value  `@"
    powershell.exe -NoProfile -NoLogo -NoExit -Command "``& C:\Windows\Setup\Scripts\install1.ps1"
"`@

    Write-Output "Waiting for Global 'Start-Up' Directory to be created..."

    `$fileNotFound = `$true
    while (`$fileNotFound) {
        Write-Output "Current Time is `$([DateTime]::Now)..."
        if (Test-Path "`$(`$env:SYSTEMDRIVE)\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp") {
            Write-Output "Found Global 'Start-Up' Directory, Inserting Start Script..."
            Set-Content "`$(`$env:SYSTEMDRIVE)\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Start.bat" ``
                "@cmd.exe /c C:\Windows\Setup\Scripts\startup.bat"
            `$fileNotFound = `$false
        }

        Start-Sleep -Seconds 1
    }

    Write-Output "Finish SetupComplete at `$([DateTime]::Now)..."

    Stop-Transcript

    Restart-Computer -Force
"@

    $scriptBlock = [Scriptblock]::Create($script)

    Move-VMStartUpScriptBlockToVM -VhdxFile $vhdx -ScriptBlock $scriptBlock

    New-VirtualMachine -VhdxFile $vhdx -ComputerName $ComputerName -VirtualSwitch "LAB"

    Set-VMMemory -VMName $ComputerName -MaximumBytes 1GB -MinimumBytes 512MB
    Set-VM -Name $ComputerName -AutomaticStartAction Nothing
    Set-Vm -Name $ComputerName -AutomaticStopAction Save
    Set-Vm -Name $ComputerName -AutomaticCheckpointsEnabled $false

    Start-VM -VMName $ComputerName

    Start-Sleep 5

    Start-Process -FilePath "vmconnect.exe" -ArgumentList "127.0.0.1 $ComputerName"

    $ErrorActionPreference = $errorPreviousAction
}

function New-LabFirewall {
    param (
        [string]$ComputerName = "FIREWALL"
    )

    $errorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    $iso = LatestIsoFile("pfSense-")

    $ComputerName = $ComputerName.ToUpperInvariant()
    $vhdx = "$ComputerName.vhdx"

    StopAndRemoveVM $ComputerName

    New-VM -Name $ComputerName -MemoryStartupBytes 512MB -NewVHDPath $vhdx -NewVHDSizeBytes 10GB -Generation 2

    Add-VMDvdDrive -VMName $ComputerName -Path $iso
    Set-VMFirmware $ComputerName -FirstBootDevice $(Get-VMDvdDrive $ComputerName)
    Set-VMFirmware $ComputerName -EnableSecureBoot Off

    Remove-VMNetworkAdapter -VMName $ComputerName -Name "Network Adapter"

    Add-VMNetworkAdapter -VMName $ComputerName -Name "LAN"
    Add-VMNetworkAdapter -VMName $ComputerName -Name "WAN"

    Connect-VMNetworkAdapter -VMName $ComputerName -Name "LAN" -SwitchName "LAB"
    Connect-VMNetworkAdapter -VMName $ComputerName -Name "WAN" -SwitchName "Default Switch"

    Pop-Location

    Set-VM -Name $ComputerName -AutomaticStartAction Nothing
    Set-Vm -Name $ComputerName -AutomaticStopAction Save
    Set-Vm -Name $ComputerName -AutomaticCheckpointsEnabled $false

    Write-Warning "Be sure to eject the ISO File after installation is complete."

    Start-VM -VMName $ComputerName

    vmconnect.exe localhost $ComputerName

    $ErrorActionPreference = $errorPreviousAction
}

function New-LabMintWorkstation {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [switch]$UseDefaultSwitch
    )

    $IsoFilePath = LatestIsoFile "linuxmint-"
    New-LabVMFromISO -ComputerName $ComputerName -IsoFilePath $IsoFilePath `
        -UseDefaultSwitch:$UseDefaultSwitch.IsPresent
}

function New-LabUbuntuServer {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [switch]$UseDefaultSwitch
    )

    $IsoFilePath = LatestIsoFile "ubuntu-\d"
    New-LabVMFromISO -ComputerName $ComputerName -IsoFilePath $IsoFilePath `
        -UseDefaultSwitch:$UseDefaultSwitch.IsPresent
}

function New-LabUbuntuWorkstation {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [switch]$UseDefaultSwitch
    )

    $IsoFilePath = LatestIsoFile "ubuntu-mate-"
    New-LabVMFromISO -ComputerName $ComputerName -IsoFilePath $IsoFilePath `
        -UseDefaultSwitch:$UseDefaultSwitch.IsPresent
}

function New-LabVMFromISO {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$IsoFilePath,
        [string]$VirtualSwitch = "LAB",
        [switch]$UseDefaultSwitch
    )

    $errorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";

    if ($UseDefaultSwitch) {
        $VirtualSwitch = "Default Switch"
    }

    $ComputerName = $ComputerName.ToUpperInvariant()

    Push-Location $((Get-VMHost).VirtualHardDiskPath)

    $vhdx = "$ComputerName.vhdx"

    StopAndRemoveVM $ComputerName

    New-VHD -Path $vhdx -SizeBytes 80GB -Dynamic

    Write-Output "Creating Virtual Machine...`n"
    New-VM -Name $ComputerName -VHDPath $vhdx -Generation 2

    Set-VMMemory -VMName $ComputerName -DynamicMemoryEnabled $true -StartupBytes 1GB
    Set-VMMemory -VMName $ComputerName -MinimumBytes 512MB

    Set-VM -Name $ComputerName -AutomaticStartAction Nothing
    Set-VM -Name $ComputerName -AutomaticStopAction Save
    Set-VM -Name $ComputerName -AutomaticCheckpointsEnabled $false

    Add-VMDvdDrive -VMName $ComputerName -Path $IsoFilePath
    Set-VMFirmware $ComputerName -FirstBootDevice $(Get-VMDvdDrive $ComputerName)
    Set-VMFirmware $ComputerName -EnableSecureBoot Off

    Connect-VMNetworkAdapter -VMName $ComputerName -SwitchName $VirtualSwitch

    Pop-Location

    Write-Output "Starting Virtual Macine..."
    Start-VM -VMName $ComputerName

    Start-Sleep -Seconds 2

    Start-Process -FilePath "vmconnect.exe" -ArgumentList "${env:COMPUTERNAME} $ComputerName"

    $ErrorActionPreference = $errorPreviousAction
}

function New-LabVMSwitch {
    $lab = Get-VMSwitch -Name LAB -ErrorAction SilentlyContinue

    if (-not $lab) {
        New-VMSwitch -Name LAB -SwitchType Internal

        New-NetIPAddress -IPAddress 10.10.10.11 -PrefixLength 24 -InterfaceAlias "vEthernet (LAB)"
    } else {
        Write-Warning "Lab VMSwitch already exists..."
    }
}

function New-LabWindowsServer {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [psobject]$Credentials,
        [switch]$DomainJoin,
        [switch]$UseDefaultSwitch,
        [alias("UseDesktop", "WithGui", "Gui")]
        [switch]$UseDesktopExperience
    )

    $errorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";

    $ComputerName = $ComputerName.ToUpperInvariant()
    $vhdx = "$ComputerName.vhdx"

    StopAndRemoveVM $ComputerName

    if ($UseDefaultSwitch) {
        $switch = "Default Switch"
    } else {
        $switch = "LAB"
    }

    $baseImage = "$((Get-ChildItem -Path "Win2019ServerCoreBase.vhdx").FullName)"

    if ($UseDesktopExperience) {
        $baseImage = "$((Get-ChildItem -Path "Win2019ServerBase.vhdx").FullName)"
    }

    Push-Location $((Get-VMHost).VirtualHardDiskPath)

    New-DifferencingVHDX -referenceDisk $baseImage -vhdxFile "$vhdx"

    if ($DomainJoin) {
        if ($null -eq $Credentials) {
            $Credentials = $(Get-Credentials -Message "Enter Lab Domain Administrator Account (UPN)")
        }

        $unattend = "${env:SYSTEMDRIVE}\etc\vm\unattend.server.domain.xml"
        $unattendFile = "$env:TEMP\$(Split-Path $unattend -Leaf)"
        Copy-Item -Path $unattend -Destination $unattendFile  -Force

        (Get-Content $unattendFile).Replace("P@ssw0rd", $Credentials.GetNetworkCredential().password) `
            | Set-Content $unattendFile

        (Get-Content $unattendFile).Replace("Administrator", $Credentials.UserName) `
            | Set-Content $unattendFile
    } else {
        $unattendFile = "${env:SYSTEMDRIVE}\etc\vm\unattend.server.xml"
    }

    Write-Output "Inserting Unattend File...`n"
    New-UnattendFile -VhdxFile $vhdx -UnattendTemplate $unattendFile -ComputerName $ComputerName | Out-Null

    Write-Output "Creating Virtual Machine...`n"
    New-VirtualMachine -vhdxFile $vhdx -computerName $ComputerName `
        -virtualSwitch $switch -memory 2GB  -Verbose

    Set-VMMemory -VMName $ComputerName -MinimumBytes 1GB
    Set-VM -Name $ComputerName -AutomaticStartAction Nothing
    Set-Vm -Name $ComputerName -AutomaticStopAction Save
    Set-Vm -Name $ComputerName -AutomaticCheckpointsEnabled $false

    Pop-Location

    Write-Output "Starting Virtual Macine..."
    Start-VM -VMName $ComputerName

    Start-Sleep -Seconds 2

    Start-Process -FilePath "vmconnect.exe" -ArgumentList "${env:COMPUTERNAME} $ComputerName"

    $ErrorActionPreference = $errorPreviousAction
}

function New-LabWindowsWorkstation {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [psobject]$Credentials,
        [switch]$DomainJoin,
        [switch]$UseDefaultSwitch
    )

    $errorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";

    $ComputerName = $ComputerName.ToUpperInvariant()
    $startScript = "${env:SYSTEMDRIVE}\etc\vm\startup.ps1"
    $baseImage = "$((Get-VMHost).VirtualHardDiskPath)\Win10Base.vhdx"
    $vhdx = "$((Get-VMHost).VirtualHardDiskPath)\$ComputerName.vhdx"
    $startLayout = "$($env:SYSTEMDRIVE)\etc\vm\StartScreenLayout.xml"

    StopAndRemoveVM $ComputerName

    if ($UseDefaultSwitch) {
        $Switch = "Default Switch"
    } else {
        $Switch = "LAB"
    }

    if ($null -eq $Credentials) {
        if ($DomainJoin) {
            $Credentials = $(Get-Credentials -Message "Enter Lab Domain Administrator Account (UPN)")
        } else {
            $Credentials = $(Get-Credential -Message "Enter Username and Password for VM default user...")
        }
    }

    Push-Location $((Get-VMHost).VirtualHardDiskPath)

    New-DifferencingVHDX -ReferenceDisk $baseImage -VhdxFile "$vhdx"

    if ($DomainJoin) {
        $unattend = "${env:SYSTEMDRIVE}\etc\vm\unattend.workstation.domain.xml"
    } else {
        $unattend = "${env:SYSTEMDRIVE}\etc\vm\unattend.workstation.xml"
    }

    $unattendFile = "$env:TEMP\$(Split-Path $unattend -Leaf)"
    Copy-Item -Path $unattend -Destination $unattendFile  -Force

    (Get-Content $unattendFile).Replace("P@ssw0rd", $Credentials.GetNetworkCredential().password) `
        | Set-Content $unattendFile

    (Get-Content $unattendFile) -Replace "\bAdministrator\b", $Credentials.UserName `
        | Set-Content $unattendFile

    Write-Output "Inserting unattend file, start script, and start layout...`n"
    New-UnattendFile -VhdxFile $vhdx -UnattendTemplate $unattendFile -ComputerName $ComputerName | Out-Null

    Move-VMStartUpScriptFileToVM -VhdxFile $vhdx -ScriptFile $StartScript -Argument "myvm-workstation" | Out-Null

    Move-StartLayoutToVM -VhdxFile $vhdx -LayoutFile $startLayout | Out-Null

    Write-Output "Creating Virtual Machine...`n"
    New-VirtualMachine -VhdxFile $vhdx -ComputerName $ComputerName `
        -virtualSwitch $Switch -memory 2GB -Verbose

    Set-VMMemory -VMName $ComputerName -MinimumBytes 1GB
    Set-Vm -Name $ComputerName -AutomaticStopAction Save
    Set-Vm -Name $ComputerName -AutomaticCheckpointsEnabled $false

    Pop-Location

    Write-Output "Starting Virtual Macine..."
    Start-VM -VMName $ComputerName

    Start-Sleep -Seconds 2

    Start-Process -FilePath "vmconnect.exe" -ArgumentList "${env:COMPUTERNAME} $ComputerName"

    $ErrorActionPreference = $errorPreviousAction
}

function Remove-LabVMSwitch {
    $lab = Get-VMSwitch -Name LAB -ErrorAction SilentlyContinue

    if ($lab) {
        Remove-VMSwitch -Name LAB -Force
    } else {
        Write-Warning "Lab VMSwitch does not exist..."
    }
}
