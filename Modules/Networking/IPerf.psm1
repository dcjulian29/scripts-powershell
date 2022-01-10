function Find-Iperf {
    First-Path `
        ("${env:SystemDrive}\tools\iperf\iperf3.exe")
}

function Invoke-IPerf {
    if (-not (Test-Path $(Find-IPerf))) {
        Write-Output "iPerf is not installed on this system."
    } else {
        $param = "$args"

        $ea = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"

        Start-Process -FilePath $(Find-Iperf) -ArgumentList $param -Wait -NoNewWindow

        $ErrorActionPreference = $ea
    }
}

Set-Alias iperf Invoke-IPerf

function Invoke-IPerfClient {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$IperfServer,
        [int]$Seconds = "30"
    )

    Invoke-IPerf -c $IperfServer -i 1 -t $Seconds
}

Set-Alias iperf-client Invoke-IPerfClient

function Invoke-IPerfServer {
    Write-Output "Press Ctrl-C to stop IPerf Server."
    Invoke-IPerf -s -i 1
}

Set-Alias iperf-server Invoke-IPerfServer
