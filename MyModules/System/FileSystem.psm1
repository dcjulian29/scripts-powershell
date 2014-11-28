Function Copy-File {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Destination,
        [switch]$Force,
        [switch]$UseWin32
    )

    if ($Force) {
        if (Test-Path $Destination) {
            Remove-Item -Path $Destination -Force
        }
    }

    if ($UseWin32) {
        Add-Type -AssemblyName Microsoft.VisualBasic
        [Microsoft.VisualBasic.FileIO.FileSystem]::CopyFile( `
            $Path, `
            $Destination, `
            [Microsoft.VisualBasic.FileIO.UIOption]::AllDialogs, `
            [Microsoft.VisualBasic.FileIO.UICancelOption]::ThrowException)
    } else {    
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

Function Reset-Path {
    $windowsPath = "C:\WINDOWS;C:\WINDOWS\system32;C:\WINDOWS\System32\Wbem"
    $powershellPath = "C:\WINDOWS\System32\WindowsPowerShell\v1.0"
    $binaryPath = "C:\Tools\binaries"
    $chocolateyPath = "C:\ProgramData\chocolatey\bin"

    $path = "$binaryPath;$windowsPath;$powershellPath"

    $env:Path = $path
    setx.exe /m PATH $path
}

##############################################################################

Export-ModuleMember Copy-File
Export-ModuleMember Get-FullFilePath
Export-ModuleMember Reset-Path