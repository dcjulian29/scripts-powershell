function pm {
    Start-Process -FilePath "$env:WinDir\System32\PktMon.exe" `
        -ArgumentList $args -NoNewWindow -Wait
}

#------------------------------------------------------------------------------

function Add-PacketFilter {
    param (
        [string] $Name,
        [int] $Port,
        [ValidateSet("IPv4", "IPv6", "ARP")]
        [string] $Protocol,
        [ValidateSet("TCP", "UDP", "ICMP", "ICMPv6")]
        [string] $ProtocolType,
        [string] $IpAddress
    )

    $parameter = "filter add"

    if ($Name) {
        $parameter = "$parameter $Name"
    }

    if ($Protocol) {
        $parameter = "$parameter -d $Protocol"
    }

    if ($ProtocolType) {
        $parameter = "$parameter -t $ProtocolType"
    }

    if ($IpAddress) {
        $parameter = "$parameter -i $IPAddress"
    }

    if ($Port) {
        $parameter = "$parameter -p $Port"
    }

    pm $parameter
}

function Clear-PacketFilter {
    pm filter remove
}

function Convert-PacketCaptureFile {
    param (
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $Path = "PktMon.etl",
        [switch] $TextFormat
    )

    $info = Get-Item $(Resolve-Path $Path)
    $file = Join-Path $info.Directory $info.BaseName
    $pcap =  & "$env:WinDir\System32\PktMon.exe" pcapng help 2> $null

    if ($TextFormat -or (-not $pcap)) {
        pm format "$info" -o "$file.txt"
    } else {
        pm pcapng "$info" -o "$file.pcap"
    }
}

function Get-PacketFilter {
    pm filter list
}

function Start-PacketCapture {
    param (
        [string] $Path = "PktMon.etl",
        [long] $Size = 1GB
    )

    pm start --etw -p 0 -f $Path -s ($Size / 1MB)
}

function Stop-PacketCapture {
    pm stop
}
