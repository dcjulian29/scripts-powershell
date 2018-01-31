$script:nmapexe = Find-ProgramFiles 'Nmap\nmap.exe'
$script:tsharkexe = Find-ProgramFiles 'Wireshark\tshark.exe'
$script:iperfexe = "${env:SystemDrive}\tools\iperf\iperf3.exe"

Function Invoke-NetshAdvFirewall {
    [CmdletBinding()]
    [OutputType([System.String])]

    Param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,
        [parameter(Mandatory = $true)]
        [ValidateSet("add","del","show")]
        [String]$Operation,
        [String]$Protocol,
        [String]$LocalPort,
        [ValidateSet("Inbound", "Outbound")]
        [String]$Direction,
        [ValidateSet("Allow", "Block", "Bypass")]
        [String]$Action
    )

    $argumentList = @('advfirewall', 'firewall', $Operation, 'rule', "name=""${Name}""")

    if ($Direction) {
        $dir = switch ($Direction) {
            "Inbound" { "in" }
            "Outbound" { "out" }
        }

        $argumentList += "dir=$dir"
    }

    if ($Protocol) {
        $argumentList += "protocol=$Protocol"
    }

    if ($LocalPort) {
        $argumentList += "localport=$LocalPort"
    }

    if ($Action) {
        $argumentList += "action=$Action"
    }

    $outputPath = "${env:TEMP}\netsh.out"

    $process = Start-Process netsh -ArgumentList $argumentList -Wait -NoNewWindow -RedirectStandardOutput $outputPath -Passthru

    if ($process.ExitCode -ne 0) {
        throw "Error Performing Operation '$Operation' For Firewall Rule"
    }

    return ((Get-Content $outputPath) -join "`n")
}

Function Invoke-NetshUrlAcl {
    [CmdletBinding()]
    [OutputType([System.String])]

    Param (
        [String]$Protocol = "http",
        [ValidateSet("add","del","show")]
        [String]$Operation,
        [String]$Url,
        [String]$User
    )

    $argumentList = @($Protocol, $Operation, 'urlacl', "url=""${Url}""")

    if ($user) {
        $argumentList += "user=""${User}"""
    }

    $outputPath = "${env:TEMP}\netsh.out"

    $process = Start-Process netsh -ArgumentList $argumentList `
        -Wait -NoNewWindow -RedirectStandardOutput $outputPath -Passthru

    if ($process.ExitCode -ne 0) {
        throw "Error Performing Operation '${Operation}' For Reserved URL"
    }

    return ((Get-Content $outputPath) -join "`n")
} 

Function Get-Url {
    [CmdletBinding()]

    Param (
        [String]$Protocol = "http",
        [String]$Hostname = "*",
        [String]$Port
    )

    return "${Protocol}://${Hostname}:${Port}/"
}

###############################################################################

Function Invoke-Http {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=1)]
        [string] $Url,
        [Parameter(Mandatory=$True,Position=2)]
        [ValidateSet("GET", "POST", "HEAD")]
        [string] $Verb,      
        [Parameter(Mandatory=$False,Position=3)]
        [string] $Content
    )

    $webRequest = [System.Net.WebRequest]::Create($url)
    $encodedContent = [System.Text.Encoding]::UTF8.GetBytes($content)
    $webRequest.Method = $verb.ToUpperInvariant()
  
    if ($encodedContent.length -gt 0) {
        $webRequest.ContentLength = $encodedContent.length
        $requestStream = $webRequest.GetRequestStream()
        $requestStream.Write($encodedContent, 0, $encodedContent.length)
        $requestStream.Close()
    }
  
    [System.Net.WebResponse] $resp = $webRequest.GetResponse();

    if ($resp -ne $null) {
        $rs = $resp.GetResponseStream();
        [System.IO.StreamReader] $sr = New-Object System.IO.StreamReader -argumentList $rs;
        [string] $results = $sr.ReadToEnd();
  
        return $results
    }
}

Function New-NetFirewallRule {
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,
        [String]$Protocol,
        [String]$LocalPort,
        [ValidateSet("Inbound", "Outbound")]
        [String]$Direction,
        [ValidateSet("Allow", "Block", "Bypass")]
        [String]$Action
    )

    Invoke-NetshAdvFirewall -Name $Name `
        -Operation "add" `
        -Protocol $Protocol `
        -LocalPort $LocalPort `
        -Direction $Direction `
        -Action $Action
}

Function Remove-NetFirewallRule {
    Param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Name
    )

    Invoke-NetshAdvFirewall -Name $Name -Operation "del"
}

Function New-UrlReservation {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Protocol = "http",
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Hostname = "*",
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Port,
        [ValidateNotNullOrEmpty()]
        [String]$User
    )

    $url = Get-Url $Protocol $Hostname $Port
    
    Invoke-NetshUrlAcl -Protocol $Protocol -Operation "add" -Url $url -User $User
}

Function Remove-UrlReservation {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Protocol = "http",
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Hostname = "*",
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Port
    )

    $url = Get-Url $Protocol $Hostname $Port

    Invoke-NetshUrlAcl -Protocol $Protocol -Operation "del" -Url $url
}

Function Show-UrlReservation {
    [CmdletBinding()]
    Param (
        [ValidateNotNullOrEmpty()]
        [String]$Protocol = "http",
        [ValidateNotNullOrEmpty()]
        [String]$Hostname = "*",
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [String]$Port,
        [ValidateNotNullOrEmpty()]
        [String]$User
    )

    $url = Get-Url $Protocol $Hostname $Port
    
    Invoke-NetshUrlAcl -Operation "show" -Url $url -User $User
}

Function Invoke-Nmap {
    if (-not (Test-Path $script:nmapexe)) {
        Write-Output "NMap is not installed on this system."
    } else {
        $param = "$args"

        $ea = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"

        if (Test-Elevation) {
            $param = "--privileged $param"
        } else {
             $param = "--unprivileged $param"
        }

        cmd.exe /c "`"$script:nmapexe`"  $param"

        $ErrorActionPreference = $ea
    }
}

Function Invoke-ScanNetwork {
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [String]$NetId,
        [Int]$NetMask = 24
    )

    if (Test-Elevation) {
        Invoke-Nmap -v -R -sS -sV -A $NetId/$NetMask
    } else {
        Invoke-Nmap -v -R -sT -sV $NetId/$NetMask
    }
}

Function Invoke-ScanHost {
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [String]$HostIP
    )

    Invoke-ScanNetwork -NetId $HostIP -NetMask 32
}

Function Invoke-ScanLocalNetwork {
    $gw = Get-WmiObject -Class Win32_IP4RouteTable `
        | Where-Object { $_.destination -eq '0.0.0.0' -and $_.mask -eq '0.0.0.0'} `
        | Sort-Object metric1 | Select-Object InterfaceIndex

    $address = Get-NetIPAddress -InterfaceIndex $gw.InterfaceIndex
    $netID = ($address | Where {$_.AddressFamily -eq 'IPv4'}).IPAddress
    $netMask = ($address | Where {$_.AddressFamily -eq 'IPv4'}).PrefixLength

    Invoke-ScanNetwork -NetId $netId -NetMask $netMask
}

Function Invoke-PingScanNetwork {
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [String]$NetId,
        [Int]$NetMask = 24
    )

    Invoke-Nmap -R -sn $NetId/$NetMask
}

Function Hide-PCapNetworkInterface {
    $adapters = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
    $networks = "HKLM:\SYSTEM\CurrentControlSet\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}"

    Push-Location $adapters

    Get-ChildItem -ErrorAction 0  | ForEach-Object {  
        $node = $_.pspath  
        $netId = (Get-ItemProperty $node).NetCfgInstanceId
        if ($netId) {
            $name = (Get-ItemProperty "$networks\$netId\Connection").Name

            if ($name -like "*Npcap Loopback Adapter*") {
                "Found PCap Looback Interface, reconfiguring as an endpoint device."
                New-ItemProperty $node -Name '*NdisDeviceType' -PropertyType dword -Value 1 -ea 0 
            }
        }
    }

    Pop-Location

    Get-WmiObject Win32_NetworkAdapter | Where-Object {$_.Name -like "Npcap Loopback Adapter" } | ForEach-Object {  
        Write-Host -nonew "Disabling $($_.name) ... " 
        $result = $_.Disable()  
        if ($result.ReturnValue -eq -0) { Write-Host " success." } else { Write-Host " failed." }  
      
        Write-Host -nonew "Enabling $($_.name) ... " 
        $result = $_.Enable()  
        if ($result.ReturnValue -eq -0) { Write-Host " success." } else { Write-Host " failed." }  
    }
}

Function Invoke-TShark {
    if (-not (Test-Path $script:tsharkexe)) {
        Write-Output "Wireshark is not installed on this system."
    } else {
        $param = "$args"

        $ea = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"

        cmd.exe /c "`"$script:tsharkexe`"  $param"

        $ErrorActionPreference = $ea
    }
}

Function Get-TSharkInterfaces {
    Invoke-TShark -D
}

Function Invoke-TSharkCapture {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int]$Interface,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Filter,
        [Parameter(Mandatory=$true)]
        [string]$FileName
    )

    Write-Output "Capture will start in new window... Press Ctrl-C to stop capture."

    $param = "-i $Interface -f `"$Filter`" -w $FileName -N mt"

    Start-Process -FilePath $script:tsharkexe -ArgumentList $param -Wait
}

Function Invoke-IPerf {
    if (-not (Test-Path $script:iperfexe)) {
        Write-Output "iPerf is not installed on this system."
    } else {
        $param = "$args"

        $ea = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"

        #cmd.exe /c "`"$script:iperfexe`"  $param"
        Start-Process -FilePath $script:iperfexe -ArgumentList $param -Wait -NoNewWindow

        $ErrorActionPreference = $ea
    }
}

Function Invoke-IPerf {
    if (-not (Test-Path $script:iperfexe)) {
        Write-Output "iPerf is not installed on this system."
    } else {
        $param = "$args"

        $ea = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"

        #cmd.exe /c "`"$script:iperfexe`"  $param"
        Start-Process -FilePath $script:iperfexe -ArgumentList $param -Wait -NoNewWindow

        $ErrorActionPreference = $ea
    }
}

Function Invoke-IPerfServer {
    Write-Output "Press Ctrl-C to stop IPerf Server."
    Invoke-IPerf -s -i 1
}

Function Invoke-IPerfClient {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$IperfServer,
        [int]$Seconds = "30"        
    )

    Invoke-IPerf -c $IperfServer -i 1 -t $Seconds
}

###############################################################################

Export-ModuleMember Invoke-Http
Export-ModuleMember New-NetFirewallRule
Export-ModuleMember Remove-NetFirewallRule
Export-ModuleMember New-UrlReservation
Export-ModuleMember Remove-UrlReservation

Export-ModuleMember Invoke-Nmap
Export-ModuleMember Invoke-ScanNetwork
Export-ModuleMember Invoke-ScanHost
Export-ModuleMember Invoke-ScanLocalNetwork
Export-ModuleMember Invoke-PingScanNetwork

Set-Alias nmap Invoke-Nmap
Export-ModuleMember -Alias nmap

Set-Alias nmap-scan Invoke-ScanNetwork
Export-ModuleMember -Alias nmap-scan

Export-ModuleMember Hide-PCapNetworkInterface

Export-ModuleMember Invoke-TShark
Export-ModuleMember Get-TSharkInterfaces
Export-ModuleMember Invoke-TSharkCapture

Set-Alias tshark Invoke-TShark
Export-ModuleMember -Alias tshark

Set-Alias tshark-showinterfaces Get-TSharkInterfaces
Export-ModuleMember -Alias tshark-showinterfaces

Set-Alias tshark-capture Invoke-TSharkCapture
Export-ModuleMember -Alias tshark-capture


Export-ModuleMember Invoke-IPerf
Export-ModuleMember Invoke-IPerfServer
Export-ModuleMember Invoke-IPerfClient

Set-Alias iperf Invoke-IPerf
Export-ModuleMember -Alias iperf

Set-Alias iperf-server Invoke-IPerfServer
Export-ModuleMember -Alias iperf-server

Set-Alias iperf-client Invoke-IPerfClient
Export-ModuleMember -Alias iperf-client
