function testDockerOrElevated {
    if (Get-Command "docker.exe" -ErrorAction SilentlyContinue) {
        return $true
    }
    
    Test-Elevation
}

#------------------------------------------------------------------------------

function Find-Nmap {
    if (Get-Command "docker.exe" -ErrorAction SilentlyContinue) {
        "docker.exe run -it dcjulian29/nmap"
    } else {
        First-Path `
            (Find-ProgramFiles 'Nmap\nmap.exe')
    }
}

function Invoke-Nmap {
    $nmap = Find-Nmap
    if (-not $nmap) {
        throw "NMap (or Docker) is not installed on this system."
    }
    
    $param = "$args"
    
    if ($nmap -notlike "*docker*") {
        if (Test-Elevation) {
            $param = "--privileged $param"
        } else {
             $param = "--unprivileged $param"
        }
    }

    cmd.exe /c "$nmap $param"
}

Set-Alias nmap Invoke-Nmap

function Invoke-PingScanNetwork {
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [String]$NetId,
        [Int]$NetMask = 24
    )

    Invoke-Nmap -R -sn $NetId/$NetMask
}

function Invoke-ScanHost {
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [String]$HostIP
    )

    Invoke-ScanNetwork -NetId $HostIP -NetMask 32
}

Set-Alias nmap-host Invoke-ScanHost

function Invoke-ScanLocalNetwork {
    $gw = Get-WmiObject -Class Win32_IP4RouteTable `
        | Where-Object { $_.destination -eq '0.0.0.0' -and $_.mask -eq '0.0.0.0'} `
        | Sort-Object metric1 | Select-Object InterfaceIndex

    $address = Get-NetIPAddress -InterfaceIndex $gw.InterfaceIndex
    $netID = ($address | Where {$_.AddressFamily -eq 'IPv4'}).IPAddress
    $netMask = ($address | Where {$_.AddressFamily -eq 'IPv4'}).PrefixLength

    Invoke-ScanNetwork -NetId $netId -NetMask $netMask
}

function Invoke-ScanNetwork {
    param (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [String]$NetId,
        [Int]$NetMask = 24
    )

    if (testDockerOrElevated) {
        Invoke-Nmap -v -R -sS -sV -A $NetId/$NetMask
    } else {
        Invoke-Nmap -v -R -sT -sV $NetId/$NetMask
    }
}

Set-Alias nmap-scan Invoke-ScanNetwork
