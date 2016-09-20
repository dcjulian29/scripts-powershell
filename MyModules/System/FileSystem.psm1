Function Copy-File {
    [CmdletBinding()]
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

    $Destination = Get-FullFilePath $Destination

    if ((Test-Path $Destination) -and $Force) {
        Write-Verbose "Removing --> $Destination"

        Remove-Item $Destination -Force
    }

    Write-Verbose "Source --> $Path"
    Write-Verbose "Destination --> $Destination"

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

                if ($percent -gt 0) {
                    [int]$remainingTime = ((($elapsed / $percent) * 100) - $elapsed)
                } else {
                    [int]$remainingTime = 0
                }

                Write-Progress `
                    -Activity ("Copying file: {0}% @ " -f $percent + "{0:n2}" -f $xferrate + " MB/s") `
                    -status "$Path -> $Destination" `
                    -PercentComplete $percent `
                    -SecondsRemaining $remainingTime

                Write-Verbose ("Progress: {0}% @ " -f $percent + "{0:n2}" -f $xferrate + " MB/s")
            } while ($count -gt 0)

            $sw.Stop()
            $sw.Reset()
        }
        finally {
            $from.Dispose()
            $to.Dispose()
        }

        Write-Verbose "Copied --> $Destination"
    }
}

Function Download-File {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Url,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Destination,
        [switch]$Force
    )

    $Destination = Get-FullFilePath $Destination

    if ((Test-Path $Destination) -and $Force) {
        Write-Verbose "Removing --> $Destination"

        Remove-Item $Destination -Force
    }

    Write-Verbose "Downloading --> $Url"

    $uri = New-Object "System.Uri" "$Url" 

    $request = [System.Net.HttpWebRequest]::Create($uri) 
    $request.set_Timeout(15000)
    $response = $request.GetResponse() 
    $totalLength = $response.get_ContentLength() 

    $responseStream = $response.GetResponseStream() 

    $to = New-Object -TypeName System.IO.FileStream -ArgumentList $Destination, Create 

    try {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        [byte[]]$buffer = New-Object byte[] 4096
        [long]$total = [int]$count = 0

        do {
            $count = $responseStream.Read($buffer,0,$buffer.length) 
            $to.Write($buffer, 0, $count) 
            $total += $count

            [int]$percent = ([int]($total / $totalLength * 100))
            [int]$elapsed = [int]($sw.ElapsedMilliseconds.ToString()) / 1000

            if ( $elapsed -ne 0 ) {
                [single]$xferrate = (($total/$elapsed) / 1MB)
            } else {
                [single]$xferrate = 0.0
            }

            if ($percent -gt 0) {
                [int]$remainingTime = ((($elapsed / $percent) * 100) - $elapsed)
            } else {
                [int]$remainingTime = 0
            }

            Write-Progress `
                -Activity ("Downloading ${Url}: {0}% @ " -f $percent + "{0:n2}" -f $xferrate + " MB/s") `
                -status "To $Destination" `
                -PercentComplete $percent `
                -SecondsRemaining $remainingTime
                
            Write-Verbose ("Progress: {0}% @ " -f $percent + "{0:n2}" -f $xferrate + " MB/s")
        } while ($count -gt 0)

        $sw.Stop()
        $sw.Reset()
    } finally {
        $to.Flush()
        $to.Close() 
        $to.Dispose() 
        $responseStream.Dispose() 
    }

    Write-Verbose "Saved --> $Destination"
}

Function Unzip-File {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$File,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Destination,
        [switch]$RemoveDestinationFirst
    )

    $File = Get-FullFilePath $File
    $Destination = Get-FullDirectoryPath $Destination

    if ((Test-Path $Destination) -and $Force) {
        Write-Verbose "Removing --> $Destination"

        Remove-Item $Destination -Recurse -Force | Out-Null
    }

    if (-not (Test-Path $Destination)) {
        Write-Verbose "Creating --> $Destination"

        New-Item -Type Directory -Path $Destination | Out-Null
    }

    Write-Verbose "Source --> $File"
    Write-Verbose "Destination --> $Destination"

    [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
    
    [System.IO.Compression.ZipFile]::ExtractToDirectory($File, $Destination)
}

Function Get-FullFilePath {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Path
    )

    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}

Function Get-FullDirectoryPath {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    if ($Path.Substring($Path.Length) -ne [IO.Path]::DirectorySeparatorChar) {
        $Path = "$Path\"
    }

    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
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
Export-ModuleMember Download-File
Export-ModuleMember Unzip-File
Export-ModuleMember Get-FullFilePath
Export-ModuleMember Get-FullDirectoryPath
Export-ModuleMember Reset-Path