function Find-NMap {
    First-Path `
        (Find-ProgramFiles 'Nmap\nmap.exe')
}

Function Invoke-Nmap {
    if (-not (Test-Path $(Find-NMap))) {
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

        cmd.exe /c "`"$(Find-NMap)`"  $param"

        $ErrorActionPreference = $ea
    }
}

Set-Alias nmap Invoke-Nmap

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

Set-Alias nmap-scan Invoke-ScanNetwork

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
