function Find-TShark {
    First-Path `
        (Find-ProgramFiles 'Wireshark\tshark.exe')
}

function Invoke-TShark {
    if (-not (Test-Path $(Find-TShark))) {
        Write-Output "Wireshark is not installed on this system."
    } else {
        $param = "$args"

        $ea = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"

        cmd.exe /c "`"$(Find-TShark)`"  $param"

        $ErrorActionPreference = $ea
    }
}

Set-Alias tshark Invoke-TShark

function Get-TSharkInterfaces {
    Invoke-TShark -D
}

Set-Alias tshark-showinterfaces Get-TSharkInterfaces

function Invoke-TSharkCapture {
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

    Start-Process -FilePath $(Find-TShark) -ArgumentList $param -Wait
}

Set-Alias tshark-capture Invoke-TSharkCapture
