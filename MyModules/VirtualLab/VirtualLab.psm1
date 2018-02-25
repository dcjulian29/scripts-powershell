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

Function NewLabServer {
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

    New-VirtualMachine -vhdxFile $vhdx -computerName $computerName -memory 4GB -Verbose

    Set-VMMemory -VMName $computerName -MinimumBytes 1GB
    Set-Vm -Name $computerName -AutomaticStopAction Save    

    Pop-Location

    Start-VM -VMName $computerName

    Start-Process -FilePath "vmconnect.exe" -ArgumentList "127.0.0.1 $computerName"

    $ErrorActionPreference = $ErrorPreviousAction
}

Function New-LabLinuxServer {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [string]$iso = "$((Get-VMHost).VirtualHardDiskPath)\ISO\ubuntu-16.04.3-server-amd64.iso"
    )

    $ErrorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";

    $computerName = $computerName.ToUpperInvariant()
    $vhdx = "$ComputerName.vhdx"

    StopAndRemoveVM $ComputerName

    New-VM -Name $computerName -NewVHDPath $vhdx -NewVHDSizeBytes 40GB -Generation 2
    Add-VMDvdDrive -VMName $computerName -Path $iso
    Set-VMFirmware $computerName -FirstBootDevice $(Get-VMDvdDrive $computerName)
    Set-VMFirmware $computerName -EnableSecureBoot Off

    Connect-VMNetworkAdapter -VMName $computerName -SwitchName "Internal"

    Set-VMMemory -VMName $computerName -DynamicMemoryEnabled $true -StartupBytes 1GB
    Set-VMMemory -VMName $computerName -MinimumBytes 512MB

    Start-VM -VMName $computerName

    Start-Process -FilePath "vmconnect.exe" -ArgumentList "127.0.0.1 $computerName"

    $ErrorActionPreference = $ErrorPreviousAction
}

Function New-LabFirewall {
    param (
        [string]$ComputerName = "FIREWALL",
        [string]$iso = "$((Get-VMHost).VirtualHardDiskPath)\ISO\ipfire-2.19.i586-full-core118.iso"
    )

    $ErrorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";

    $computerName = $computerName.ToUpperInvariant()
    $vhdx = "$ComputerName.vhdx"

    StopAndRemoveVM $ComputerName

    New-VM -Name $computerName -MemoryStartupBytes 512MB -NewVHDPath $vhdx -NewVHDSizeBytes 10GB
    Add-VMDvdDrive -VMName $computerName -Path $iso
    Set-Vm -Name $computerName -AutomaticCheckpointsEnabled $false  

    Remove-VMNetworkAdapter -VMName $computerName -Name "Network Adapter"

    Add-VMNetworkAdapter -VMName $computerName -Name "green0"
    Add-VMNetworkAdapter -VMName $computerName -Name "red0"
  
    Connect-VMNetworkAdapter -VMName $computerName -Name "green0" -SwitchName "Internal"
    Connect-VMNetworkAdapter -VMName $computerName -Name "red0" -SwitchName "vTRUNK"
  
    Pop-Location

    Start-VM -VMName $computerName

    vmconnect.exe localhost $computername

    $ErrorActionPreference = $ErrorPreviousAction
}

Function New-LabDomainController {
    param (
        [string]$ComputerName = "DC01",
        [string]$DomainName = "contoso.local"
    )

    $ErrorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";

    $computerName = $computerName.ToUpperInvariant()
    $vhdx = "$((Get-VMHost).VirtualHardDiskPath)\$ComputerName.vhdx"
    $unattend = "${env:SYSTEMDRIVE}\etc\vm\unattend.firstdc.xml"

    $cred = $(Get-Credential -Message "Enter credentials for Lab Domain Controller...")

    $NetBIOS = $DomainName.Substring(0, $DomainName.IndexOf('.')).ToUpperInvariant()

    $Administrator = New-Object System.Management.Automation.PSCredential "$NetBIOS\Administrator", `
        $(ConvertTo-SecureString  $cred.GetNetworkCredential().password -AsPlainText -Force)

    StopAndRemoveVM $ComputerName

    New-DifferencingVHDX -referenceDisk "$((Get-VMHost).VirtualHardDiskPath)\Win2016ServerBase.vhdx" `
        -vhdxFile $vhdx

    $unattendFile = "$env:TEMP\$(Split-Path $unattend -Leaf)" 
    Copy-Item -Path $unattend -Destination $unattendFile  -Force

    (Get-Content $unattendFile).replace("P@ssw0rd", $cred.GetNetworkCredential().password) `
        | Set-Content $unattendFile

    Make-UnattendForStaticIp -vhdxFile $vhdx -unattendTemplate $unattendFile `
        -computerName $ComputerName -networkAddress "10.10.10.111/24" `
        -gatewayAddress "10.10.10.10" -nameServer "10.10.10.111"

    $script = {
    Start-Transcript -OutputDirectory "C:\Windows\Setup\Scripts"
    Install-Windowsfeature AD-Domain-Services -IncludeManagementTools
    $password = ConvertTo-SecureString  -string 'P@ssw0rd' -AsPlainText -Force
    Install-ADDSForest -DomainName "contoso.local" -SafeModeAdministratorPassword $password `
        -InstallDns -Force -NoRebootOnCompletion
    Stop-Computer -Force
    Stop-Transcript
    }

    $script = $script -replace 'P@ssw0rd', $cred.GetNetworkCredential().password
    $script = $script -replace 'contoso.local', $DomainName

    $scriptBlock = [Scriptblock]::Create($script)

    Inject-VMStartUpScriptBlock -vhdxFile $vhdx -Scriptblock $scriptBlock `
        -arguments $cred.GetNetworkCredential().password

    New-VirtualMachine -vhdxFile $vhdx -computerName $ComputerName -virtualSwitch "Internal" 

    Set-VMMemory -VMName $computerName -MaximumBytes 1GB -MinimumBytes 512MB
    Set-VM -Name $computerName -AutomaticStartAction Nothing
    Set-Vm -Name $computerName -AutomaticStopAction Save  

    Start-VM -VMName $ComputerName

    Write-Output "Waiting for Domain Controller VM to complete initial install of Active Directory..."
    While ((Get-VM -name $ComputerName).State -ne "Off" ) {
        Start-Sleep -Seconds 5
    }

    Write-Output "Restarting Domain Controller VM..."
    Start-VM -VMName $ComputerName

    Write-Output "Waiting for Domain Controller VM to finish starting..."

    Start-Sleep -Seconds 30

    While ($true) {
        try {
            Invoke-Command -ComputerName "$ComputerName.$DomainName" -Scriptblock {ipconfig} -Credential $Administrator -ErrorAction Stop | Out-Null
            break
        }
        Catch [system.exception] {
            Write-Output "Not Yet!!!    ---    $(Get-Date)"
            Start-Sleep -Seconds 15
        }
    }

    $script = {
    Start-Transcript -OutputDirectory "C:\Windows\Setup\Scripts"
    Install-WindowsFeature Rsat-AD-PowerShell, Web-Server -IncludeManagementTools 
    Install-WindowsFeature DHCP -IncludeManagementTools

    Add-DhcpServerV4Scope -Name "contoso.local" `
        -StartRange 10.10.10.200 -EndRange 10.10.10.225 -SubnetMask 255.255.255.0
    Set-DhcpServerV4OptionValue -DnsDomain contoso.local -DnsServer 10.10.10.111
    Add-DhcpServerInDC -DnsName DC01.contoso.local -Verbose

    $username   = "CONTOSO\Administrator"
    $pass = ConvertTo-SecureString -String 'P@ssw0rd' -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential $username,$pass

    New-ADUser -SamAccountName 'labuser' -Enable $true `
        -UserPrincipalName 'labuser@contoso.local' -Name 'Lab User Account' `
        -AccountPassword $pass -PasswordNeverExpires $true -ChangePasswordAtLogon $false

    Install-WindowsFeature Web-Scripting-Tools -IncludemanagementTools
    Install-WindowsFeature AD-Certificate, Adcs-Cert-Authority -IncludemanagementTools
    Install-WindowsFeature Adcs-Enroll-Web-Svc, Adcs-Web-Enrollment, Adcs-Enroll-Web-Pol -IncludemanagementTools

    Write-Output "Installing CA using $($cred.UserName)"
    Install-AdcsCertificationAuthority -CACommonName 'VirtualsCA' -CAType 'EnterpriseRootCA' `
        -KeyLength 2048 -Cred $cred -OverwriteExistingCAinDS -Force -Verbose 

    Write-Output 'Installing ADCS web enrollment feature'
     Install-AdcsWebEnrollment -Force -Verbose
    New-WebBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https

    Write-Output "Waiting for DC01 certificate to be created"
    Gpupdate /Target:Computer /Force #| Out-Null
    Start-Sleep -Seconds 5

    While (! (Get-ChildItem Cert:\LocalMachine\My | Where Subject -Match 'DC01')) {
      Write-Output "Sleeping for another 5 seconds waiting for DC01 certificate..."
      Start-sleep -seconds 5
    }

    $cert = (Get-ChildItem Cert:\localmachine\my | Where Subject -Match 'DC01')
    Write-Output "Certificate being used is: [$($cert.thumbprint)]"

    Write-Output "Setting SSL bindings with this certificate"
    New-Item IIS:\SSLBindings\0.0.0.0!443 -value $cert      
    Stop-Transcript
    }

    $script = $script -replace 'P@ssword', $cred.GetNetworkCredential().password
    $script = $script -replace 'labuser', $cred.UserName
    $script = $script -replace 'DC01', $ComputerName
    $script = $script -replace 'contoso.local', $DomainName
    $script = $script -replace 'CONTOSO\\', "$NetBIOS\"

    $scriptBlock = [Scriptblock]::Create($script)

    Invoke-Command -ComputerName $ComputerName -Scriptblock $scriptBlock -Credential $Administrator -verbose

    $ErrorActionPreference = $ErrorPreviousAction
}

Function New-LabWorkstation {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        $Credentials = $(Get-Credentials -Message "Enter Lab Domain Administrator Account (UPN)")
    )


    #TODO Update script to copy/inject/info similar to DC...
    #     Update unattend to do domain admin login to run choco commands ???

    $ErrorPreviousAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop";

    $computerName = $computerName.ToUpperInvariant()
    $StartScript = "${env:SYSTEMDRIVE}\etc\vm\startup.ps1"
    $unattend = "${env:SYSTEMDRIVE}\etc\vm\unattend.workstation.domain.xml"
    $BaseImage = "$((Get-VMHost).VirtualHardDiskPath)\Win10Base.vhdx"
    $vhdx = "$((Get-VMHost).VirtualHardDiskPath)\$ComputerName.vhdx"
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

Function New-LabServer2012R2VM {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [string]$UnattendFile
    )

    NewLabServerVM $ComputerName 2012R2 $UnattendFile
}

Function New-LabServer2016VM {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [string]$UnattendFile
    )

    NewLabServerVM $ComputerName 2016 $UnattendFile
}

###############################################################################

Export-ModuleMember New-LabFirewall
Export-ModuleMember New-LabDomainController

Export-ModuleMember New-LabWorkstation
Export-ModuleMember New-Lab2012R2Server
Export-ModuleMember New-Lab2016Server

Export-ModuleMember New-LabLinuxServer

#Export-ModuleMember New-LabWebServer

#Export-ModuleMember New-Lab3TierRedundantPlatform
