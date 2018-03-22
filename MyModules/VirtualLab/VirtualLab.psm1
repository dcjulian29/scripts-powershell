Function StopAndRemoveVM($ComputerName) {
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

Function NewLabWindowsServer {
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
    Set-VM -Name $computerName -AutomaticStartAction Nothing
    Set-Vm -Name $computerName -AutomaticStopAction Save
    Set-Vm -Name $computerName -AutomaticCheckpointsEnabled $false  

    Pop-Location

    Start-VM -VMName $computerName

    Start-Process -FilePath "vmconnect.exe" -ArgumentList "127.0.0.1 $computerName"

    $ErrorActionPreference = $ErrorPreviousAction
}

###############################################################################

Function New-LabUbuntuServer {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [string]$ISOFilePath
    )
    
    if ($ISOFilePath -eq "") {

        $isoDir = "$((Get-VMHost).VirtualHardDiskPath)\ISO"

        $latest = Get-ChildItem -Filter "ubuntu-16.04*" -Path $isoDir `
            | Sort-Object Name -Descending `
            | Select-Object -First 1

        $isoFile = $latest.name

        $ISOFilePath = "$isoDir\$isoFile"
    }

    New-LabVMFromISO -ComputerName $ComputerName -ISOFilePath $ISOFilePath
}

Function New-LabVMFromISO {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $ISOFilePath,
        [string] $Switch = "Internal"
    )

    $ErrorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";

    $computerName = $computerName.ToUpperInvariant()

    Push-Location $((Get-VMHost).VirtualHardDiskPath)

    $vhdx = "$ComputerName.vhdx"

    StopAndRemoveVM $ComputerName

    New-VHD -Path $vhdx -SizeBytes 80GB -Dynamic

    New-VirtualMachine -vhdxFile $vhdx -computerName $computerName -Generation 2 -Verbose

    Set-VMMemory -VMName $computerName -DynamicMemoryEnabled $true -StartupBytes 1GB
    Set-VMMemory -VMName $computerName -MinimumBytes 512MB
    
    Set-VM -Name $ComputerName -AutomaticStartAction Nothing
    Set-Vm -Name $ComputerName -AutomaticStopAction Save    
    Set-Vm -Name $computerName -AutomaticCheckpointsEnabled $false  

    Add-VMDvdDrive -VMName $computerName -Path $ISOFilePath
    Set-VMFirmware $computerName -FirstBootDevice $(Get-VMDvdDrive $computerName)
    Set-VMFirmware $computerName -EnableSecureBoot Off

    Connect-VMNetworkAdapter -VMName $computerName -SwitchName $Switch

    Pop-Location

    Start-VM -VMName $computerName

    Start-Process -FilePath "vmconnect.exe" -ArgumentList "127.0.0.1 $computerName"

    $ErrorActionPreference = $ErrorPreviousAction
}

Function New-LabFirewall {
    param (
        [string]$ComputerName = "FIREWALL"
    )

    $ErrorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    $isoDir = "$((Get-VMHost).VirtualHardDiskPath)\ISO"

    $latest = Get-ChildItem -Filter "pfSense-*" -Path $isoDir `
        | Sort-Object Name -Descending `
        | Select-Object -First 1

    $isoFile = $latest.name

    $iso = "$isoDir\$isoFile"

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
  
    Connect-VMNetworkAdapter -VMName $ComputerName -Name "LAN" -SwitchName "Internal"
    Connect-VMNetworkAdapter -VMName $ComputerName -Name "WAN" -SwitchName "vTRUNK"
  
    Pop-Location

    Set-VM -Name $ComputerName -AutomaticStartAction Nothing
    Set-Vm -Name $ComputerName -AutomaticStopAction Save    
    Set-Vm -Name $ComputerName -AutomaticCheckpointsEnabled $false  

    Write-Warning "Be sure to eject the ISO File after installation is complete."

    Start-VM -VMName $ComputerName

    vmconnect.exe localhost $computername

    $ErrorActionPreference = $ErrorPreviousAction
}

Function New-LabDomainController {
    param (
        [string]$ComputerName = "DC01",
        [string]$DomainName = "contoso.local",
        [psobject]$Credentials = $(Get-Credential -Message "Enter administrative credentials for Domain Controller...")
    )

    $ErrorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";

    $computerName = $computerName.ToUpperInvariant()
    $vhdx = "$((Get-VMHost).VirtualHardDiskPath)\$ComputerName.vhdx"
    $unattend = "${env:SYSTEMDRIVE}\etc\vm\unattend.firstdc.xml"

    $NetBIOS = $DomainName.Substring(0, $DomainName.IndexOf('.')).ToUpperInvariant()

    $Administrator = New-Object System.Management.Automation.PSCredential "$NetBIOS\Administrator", `
        $(ConvertTo-SecureString  $Credentials.GetNetworkCredential().password -AsPlainText -Force)

    StopAndRemoveVM $ComputerName

    New-DifferencingVHDX -referenceDisk "$((Get-VMHost).VirtualHardDiskPath)\Win2016ServerBase.vhdx" `
        -vhdxFile $vhdx

    $unattendFile = "$env:TEMP\$(Split-Path $unattend -Leaf)" 
    Copy-Item -Path $unattend -Destination $unattendFile  -Force

    (Get-Content $unattendFile).replace("P@ssw0rd", $Credentials.GetNetworkCredential().password) `
        | Set-Content $unattendFile

    Make-UnattendForStaticIp -vhdxFile $vhdx -unattendTemplate $unattendFile `
        -computerName $ComputerName -networkAddress "10.10.10.111/24" `
        -gatewayAddress "10.10.10.10"

    $script = @"
    Start-Transcript -OutputDirectory "C:\Windows\Setup\Scripts"

    Write-Output "Starting SetupComplete at `$([DateTime]::Now)..."

    Set-Content -Path "C:\Windows\Setup\Scripts\install1.ps1" -Encoding Ascii -Value  `@"
    Start-Transcript -OutputDirectory "C:\Windows\Setup\Scripts"

    Write-Output "Installing Windows Features..."
    Install-Windowsfeature AD-Domain-Services -IncludeManagementTools -Verbose

    Write-Output "Configuring Active Directory..."
    ```$password = ConvertTo-SecureString  -string '$($Credentials.GetNetworkCredential().password)' ````
        -AsPlainText  -Force
    
    Install-ADDSForest -DomainName '$DomainName' -SafeModeAdministratorPassword ```$password -InstallDns ````
        -Force -NoRebootOnCompletion -Verbose

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
    Add-DhcpServerInDC -DnsName $ComputerName.$DomainName -Verbose

    New-ADUser -SamAccountName 'labuser' -Enable ```$true ````
        -UserPrincipalName 'labuser@$DomainName' -Name 'Lab User Account' ````
        -AccountPassword ```$pass -ChangePasswordAtLogon ```$true

    Install-WindowsFeature Web-Scripting-Tools -IncludemanagementTools
    Install-WindowsFeature AD-Certificate, Adcs-Cert-Authority -IncludemanagementTools
    Install-WindowsFeature Adcs-Enroll-Web-Svc, Adcs-Web-Enrollment, Adcs-Enroll-Web-Pol -IncludemanagementTools

    ```$username   = "$NetBIOS\Administrator"
    ```$pass = ConvertTo-SecureString -String '$($Credentials.GetNetworkCredential().password)' -AsPlainText -Force
    ```$cred = New-Object System.Management.Automation.PSCredential ```$username,```$pass

    Write-Output "Installing CA using ```$(```$cred.UserName)"
    Install-AdcsCertificationAuthority -CACommonName 'VirtualsCA' -CAType 'EnterpriseRootCA' ````
        -KeyLength 2048 -Cred ```$cred -OverwriteExistingCAinDS -Force -Verbose 

    Write-Output 'Installing ADCS web enrollment feature'

    Install-AdcsWebEnrollment -Force -Verbose

    New-WebBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https

    Write-Output "Waiting for $ComputerName certificate to be created"
    Gpupdate /Target:Computer /Force | Out-Null
    Start-Sleep -Seconds 5

    While (! (Get-ChildItem Cert:\LocalMachine\My | Where Subject -Match $ComputerName)) {
      Write-Output "Sleeping for another 5 seconds waiting for $ComputerName certificate..."
      Start-sleep -seconds 5
    }

    ```$cert = (Get-ChildItem Cert:\localmachine\my | Where Subject -Match '$ComputerName')
    Write-Output "Certificate being used is: [```$(```$cert.thumbprint)]"

    Write-Output "Setting SSL bindings with this certificate"
    New-Item IIS:\SSLBindings\0.0.0.0!443 -value ```$cert

    Write-Output "######### Active Directory Configuration Complete.\n\n"

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

    Inject-VMStartUpScriptBlock -vhdxFile $vhdx -Scriptblock $scriptBlock

    New-VirtualMachine -vhdxFile $vhdx -computerName $ComputerName -virtualSwitch "Internal" 

    Set-VMMemory -VMName $computerName -MaximumBytes 1GB -MinimumBytes 512MB
    Set-VM -Name $computerName -AutomaticStartAction Nothing
    Set-Vm -Name $computerName -AutomaticStopAction Save  
    Set-Vm -Name $computerName -AutomaticCheckpointsEnabled $false  

    Start-VM -VMName $ComputerName

    $ErrorActionPreference = $ErrorPreviousAction
}

Function New-LabWorkstation {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        $Credentials,
        [Switch]$DomainJoin,
        $Switch = "Internal"
    )


    $ErrorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";

    $computerName = $computerName.ToUpperInvariant()
    $StartScript = "${env:SYSTEMDRIVE}\etc\vm\startup.ps1"
    $unattend = "${env:SYSTEMDRIVE}\etc\vm\unattend.workstation.domain.xml"
    $BaseImage = "$((Get-VMHost).VirtualHardDiskPath)\Win10Base.vhdx"
    $vhdx = "$((Get-VMHost).VirtualHardDiskPath)\$ComputerName.vhdx"
    $startLayout = "$($env:SYSTEMDRIVE)\etc\vm\StartScreenLayout.xml"

    StopAndRemoveVM $ComputerName
    
    if ($DomainJoin -and ($Credentials -eq $null)) {
        $Credentials = $(Get-Credentials -Message "Enter Lab Domain Administrator Account (UPN)")
    } else {
        $Credentials = $(Get-Credential -Message "Enter Password for VM..." -Username "Administrator")
    }

    Push-Location $((Get-VMHost).VirtualHardDiskPath)

    New-DifferencingVHDX -referenceDisk $BaseImage -vhdxFile "$vhdx"

    $unattendFile = "$env:TEMP\$(Split-Path $unattend -Leaf)" 
    Copy-Item -Path $unattend -Destination $unattendFile  -Force

    (Get-Content $unattendFile).replace("P@ssw0rd", $Credentials.GetNetworkCredential().password) `
        | Set-Content $unattendFile

    Make-UnattendForDhcpIp -vhdxFile $vhdx -unattendTemplate $unattendFile -computerName $computerName

    Inject-VMStartUpScriptFile -vhdxFile $vhdx -scriptFile $StartScript -argument "myvm-workstation"

    Inject-StartLayout -vhdxFile $vhdx -layoutFile $startLayout

    New-VirtualMachine -vhdxFile $vhdx -computerName $computerName `
        -virtualSwitch $Switch -memory 2GB -Verbose

    Set-VMMemory -VMName $computerName -MinimumBytes 1GB
    Set-Vm -Name $computerName -AutomaticStopAction Save    
    Set-Vm -Name $computerName -AutomaticCheckpointsEnabled $false  

    Pop-Location

    Start-VM -VMName $computerName

    Start-Sleep 5

    Start-Process -FilePath "vmconnect.exe" -ArgumentList "127.0.0.1 $computerName"

    $ErrorActionPreference = $ErrorPreviousAction
}

Function New-LabWindows2012R2Server {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [string]$UnattendFile
    )

    NewLabWindowsServerVM $ComputerName 2012R2 $UnattendFile
}

Function New-LabWindows2016Server {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [string]$UnattendFile
    )

    NewLabWindowsServerVM $ComputerName 2016 $UnattendFile
}

###############################################################################

Export-ModuleMember New-LabFirewall
Export-ModuleMember New-LabDomainController

Export-ModuleMember New-LabWorkstation

Export-ModuleMember New-LabWindows2012R2Server
Export-ModuleMember New-LabWindows2016Server

Export-ModuleMember New-LabUbuntuServer

Export-ModuleMember New-LabVMFromISO

#Export-ModuleMember New-LabWebServer

#Export-ModuleMember New-Lab3TierRedundantPlatform
