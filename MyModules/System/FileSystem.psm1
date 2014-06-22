Function Copy-File {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Destination,
        [switch]$Force
    )

    if ($Force) {
        if (Test-Path $Destination) {
            Remove-Item -Path $Destination -Force
        }
    }

    $from = [IO.File]::OpenRead($Path)
    $to = [IO.File]::OpenWrite($Destination)

    Write-Progress -Activity "Copying file" -status "$Path -> $Destination" -PercentComplete 0

    try {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        [byte[]]$buff = New-Object byte[] 4096
        [long]$total = [int]$count = 0

        do {
            $count = $from.Read($buff, 0, $buff.Length)
            $to.Write($buff, 0, $count)
            $total += $count

            [int]$percent = ([int]($total / $from.Length * 100))
            [int]$elapsed = [int]($sw.ElapsedMilliseconds.ToString()) / 1000

            if ( $elapsed -ne 0 ) {
                [single]$xferrate = (($total/$elapsed) / 1MB)
            } else {
                [single]$xferrate = 0.0
            }

            if ($total % 1mb -eq 0) {
                if($percent -gt 0) {
                    [int]$remainingTime = ((($elapsed / $percent) * 100) - $elapsed)
                } else {
                    [int]$remainingTime = 0
                }

                Write-Progress `
                    -Activity ("Copying file: {0}% @ " -f $percent + "{0:n2}" -f $xferrate + " MB/s") `
                    -status "$Path -> $Destination" `
                    -PercentComplete $percent `
                    -SecondsRemaining $remainingTime
            }
        } while ($count -gt 0)

        $sw.Stop()
        $sw.Reset()
    }
    finally {
        $from.Dispose()
        $to.Dispose()
    }
}

Function Get-FullFilePath {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $Path
    )

    if (Test-Path $Path) {
        "$((Get-Item -Path $Path).Directory.FullName.TrimEnd('\'))\$((Get-Item -Path $Path).Name)"
    }
}

##############################################################################

Export-ModuleMember Copy-File
Export-ModuleMember Get-FullFilePath