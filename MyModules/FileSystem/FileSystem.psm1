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
        [switch]$Force,
        [switch]$ShowHostOnly
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
    $totalMB = "{0:n2}" -f ($totalLength / 1MB)
    
    Write-Verbose "Total Length: $totalLength bytes"

    $responseStream = $response.GetResponseStream() 

    $to = New-Object -TypeName System.IO.FileStream -ArgumentList $Destination, Create 

    if (-not $ShowHostOnly) {
        $Url = "from $($request.Address.Host)"
    }
    
    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    [byte[]]$buffer = New-Object byte[] 1MB
    [long]$total = [int]$count = [int]$iteration = 0

    Write-Progress -Id 0 `
        -Activity "Downloading ${Url}: 0% @ 0.00 MB/s" -Status "To $Destination" -PercentComplete 0

    try {
        do {
            $count = $responseStream.Read($buffer,0,$buffer.length) 
            $to.Write($buffer, 0, $count) 
            $total += $count

            if ($iteration % 25) {
                [int]$percent = ($total / $totalLength * 100)
                [int]$elapsed = ($sw.ElapsedMilliseconds / 1000)

                if ( $elapsed -ne 0 ) {
                    [single]$xferrate = (($total / 1MB) / $elapsed)
                } else {
                    [single]$xferrate = 0.0
                }

                if ($percent -lt 0) {
                    $percent = 0
                }

                $transferMB = "{0:n2}" -f ($total / 1MB)

                $activity = "Downloading ${Url}: $percent% @ {0:n2} MB/s $transferMB MB of $totalMB MB " -f $xferrate

                Write-Progress -Id 0 -Activity  $activity -status "To $Destination" -PercentComplete $percent
            }

            $iteration++
        } while ($count -gt 0)

        Write-Progress -Id 0 -Activity "Downloading ${Url}" -Completed -Status "All done."
    } finally {
        $sw.Stop()
        $sw.Reset()
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

Function Find-ProgramFiles {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$folderName
    )

    $location1 = "C:\Program Files\$folderName"
    
    if (!(Test-Path $location1)) {
        $location2 = "C:\Program Files (x86)\$folderName"
        
        if (!(Test-Path $location2)) {
            ""
        } else {
            $location2
        }
    } else {
        $location1
    }
}

Function First-Path {
    $result = $null
  
    foreach ($arg in $args) {
        if ($arg -is [ScriptBlock]) {
            $result = & $arg
        } else {
            $result = $arg
        }
    
        if ($result) {
            if (Test-Path "$result") {
                break
            }
        }
    }
  
    $result
}

Function Purge-Files {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]        
        [string]$Folder,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]        
        [string]$Filter,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]        
        [int]$Age,
        [switch]$Quiet
    )

    if (Test-Path $folder) {
        $attemps = 0
        $done = $false

        while (($attempts -lt 20) -and (-not $done)) {
            $files = 	Get-ChildItem -Path $folder -Filter $filter -Recurse `
                | where { [Datetime]::Now -gt $_.LastWriteTime.AddDays($age) }

            if ($files -eq $null) {
                $done = $true
            } else {
                if (-not $Quiet) {
                    Write-Output "Attempt $($attempts + 1)..."
                }
                
                $files | Remove-Item  -Force -Recurse -ErrorAction SilentlyContinue
                $attempts++
            }
        }

        if ($attempts -eq 20) {
            if (-not $Quiet) {
                Write-Output ""
                Write-Warning "Unable to complete the purge process... The following file were not purged:"
                $files = 	Get-ChildItem -Path $folder -Filter $filter -Recurse `
                    | where { [Datetime]::Now -gt $_.LastWriteTime.AddDays($age) }
          
                foreach ($file in $files) {
                    Write-Warning "   $($file.FullName)"
                }
            }
        } else {
            if (-not $Quiet) {
                Write-Output ""
                Write-Output "Purge operation complete..."
            }
        }
    }
}

Function Get-Sha1 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$File
    )

    $File = Get-FullFilePath $File

    Write-Verbose "Calculating SHA1 for $File..."

    (Get-FileHash -Path $file -Algorithm SHA1).Hash
}

Function Get-Sha256 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$File
    )

    $File = Get-FullFilePath $File

    Write-Verbose "Calculating SHA256 for $File..."

    (Get-FileHash -Path $file -Algorithm SHA256).Hash
}

Function Get-Md5 {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$File
    )

    $File = Get-FullFilePath $File

    Write-Verbose "Calculating MD5 for $File..."

    (Get-FileHash -Path $file -Algorithm MD5).Hash
}

##############################################################################

Export-ModuleMember Copy-File
Export-ModuleMember Download-File
Export-ModuleMember Unzip-File
Export-ModuleMember Get-FullFilePath
Export-ModuleMember Get-FullDirectoryPath
Export-ModuleMember Reset-Path
Export-ModuleMember Find-ProgramFiles
Export-ModuleMember First-Path
Export-ModuleMember Purge-Files
Export-ModuleMember Get-Sha1
Export-ModuleMember Get-Sha256
Export-ModuleMember Get-Md5

Set-Alias -Name sha1 -Value Get-Sha1
Set-Alias -Name sha256 -Value Get-Sha1
Set-Alias -Name md5 -Value Get-Sha1

Export-ModuleMember -Alias sha1
Export-ModuleMember -Alias sha256
Export-ModuleMember -Alias md5
