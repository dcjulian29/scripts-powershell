function Copy-File {
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

function Find-FirstPath {
    foreach ($arg in $args) {
        if ($arg -is [ScriptBlock]) {
            $path = & $arg
        } else {
            $path = $arg
        }

        if ($path) {
            if (Test-Path "$path") {
                return $path
            }
        }
    }
}

Set-Alias -Name First-Path -Value Find-FirstPath

function Find-ProgramFiles {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    if  (Test-Path "$env:ProgramFiles\$Path") {
        return "$env:ProgramFiles\$Path"
    }

    if  (Test-Path "${env:ProgramFiles(x86)}\$Path") {
        return "${env:ProgramFiles(x86)}\$Path"
    }
}

function Get-FullDirectoryPath {
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

function Get-FullFilePath {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Path
    )

    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}

function Get-FileEncoding {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [Alias("File")]
        [string]$Path
    )

    $bytes = [byte[]](Get-Content $Path -Encoding byte -ReadCount 4 -TotalCount 4)

    if (!$bytes) { return 'utf8' }

    switch -regex ('{0:x2}{1:x2}{2:x2}{3:x2}' -f $bytes[0..3]) {
        '^efbbbf'   { return 'utf8' }
        '^2b2f76'   { return 'utf7' }
        '^fffe'     { return 'unicode' }
        '^feff'     { return 'bigendianunicode' }
        '^0000feff' { return 'utf32' }
        default     { return 'ascii' }
    }
}

function Get-Md5 {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [Alias("File")]
        [string]$Path
    )

    (Get-FileHash -Path $(Get-FullFilePath $Path) -Algorithm MD5).Hash
}

Set-Alias -Name md5 -Value Get-Sha1

function Get-Path {
    param (
        [switch]$Positions
    )

    if (($env:Path).Length -eq 0) {
        return @()
    }

    $pathList = ($env:Path).Split(';')

    if ($Positions) {
        $p = @()
        for ($i = 0; $i -lt $pathList.Count; $i++) {
           $p += "{0,3} $($pathList[$i])" -f $i
        }

        $pathList = $p
    }

    return $pathList
}

function Get-Sha1 {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [Alias("File")]
        [string]$Path
    )

    (Get-FileHash -Path $(Get-FullFilePath $Path) -Algorithm SHA1).Hash
}

Set-Alias -Name sha1 -Value Get-Sha1

function Get-Sha256 {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [Alias("File")]
        [string]$Path
    )

    (Get-FileHash -Path $(Get-FullFilePath $Path) -Algorithm SHA256).Hash
}

Set-Alias -Name sha256 -Value Get-Sha256

function Invoke-DownloadFile {
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
    $request.set_UserAgent("Mozilla/5.0")
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

Set-Alias -Name Download-File -Value Invoke-DownloadFile

function Invoke-PurgeFiles {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Folder,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Filter,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int]$Age,
        [switch]$Quiet
    )

    $attempts = 0
    $done = $false

    while (($attempts -lt 20) -and (-not $done)) {
        $files = Get-ChildItem -Path $Folder -Filter $Filter -Recurse | `
            Where-Object { [Datetime]::Now -gt $_.LastWriteTime.AddDays($Age) }

        if ($null -eq $files) {
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
            $files = 	Get-ChildItem -Path $Folder -Filter $filter -Recurse `
                | Where-Object { [Datetime]::Now -gt $_.LastWriteTime.AddDays($Age) }

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

Set-Alias -Name Purge-Files -Value Invoke-PurgeFiles

function Invoke-TouchFile {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    if (-not ([System.IO.Path]::IsPathRooted($Path))) {
        $Path = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($pwd, $Path))
    }

    if (Test-Path $Path) {
        $file = Get-Item $Path
        $file.LastWriteTime = Get-Date
    } else {
        "" | Out-File -FilePath $Path -Encoding ASCII
    }
}

Set-Alias -Name touch -Value Invoke-TouchFile

function Invoke-UnzipFile {
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

Set-Alias -Name Unzip-File -Value Invoke-UnzipFile

function Optimize-Path {
    Get-Path | ForEach-Object {
        if (Test-Path $_) {
            $list += "$_;"
        }
    }

    $list = $list.Substring(0,$list.Length -1)

    if (($env:Path).Length -ne ($list.Length)) {
        Set-EnvironmentVariable "Path" $list
    }
}

Set-Alias -Name Clean-Path -Value Optimize-Path

function Remove-Path {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    if (Test-InPath $Path) {
        $pathList = {[System.Collections.ArrayList](Get-Path)}.Invoke()
        $pathList.Remove($Path) | Out-Null
        $pathString = $pathList -join ';'

        Set-EnvironmentVariable "Path" $pathString
    }
}

function Reset-Path {
    param (
        [switch]$Empty
    )

    if ($Empty) {
        Remove-EnvironmentVariable "Path"
    } else {
        $windowsPath = "C:\WINDOWS;C:\WINDOWS\system32;C:\WINDOWS\System32\Wbem"
        $powershellPath = "C:\WINDOWS\System32\WindowsPowerShell\v1.0"

        Set-EnvironmentVariable "Path" "$windowsPath;$powershellPath"
    }
}

function Set-FileShortCut {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$TargetPath,
        [string]$Arguments,
        [string]$IconPath,
        [string]$Description,
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$WorkingDirectory
    )

    if (-not ([System.IO.Path]::HasExtension($Path))) {
        $Path = "$Path.lnk"
    }

    if (-not ([System.IO.Path]::IsPathRooted($Path))) {
        $Path = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($pwd, $Path))
    }

    $shell = New-Object -comObject WScript.Shell

    $shortcut = $shell.CreateShortcut($Path)

    $shortcut.TargetPath = $TargetPath

    if ($Arguments) {
        $shortcut.Arguments = $Arguments
    }

    if ($IconPath) {
        $shortcut.IconLocation = $IconPath
    }

    if ($Description) {
        $shortcut.Description = $Description
    }

    if ($WorkingDirectory) {
        $shortcut.WorkingDirectory = $WorkingDirectory
    }

    $shortcut.Save()
}

Set-Alias -Name New-FileShortCut -Value Set-FileShortCut

function Set-Path {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [ValidateScript({
            if ($_ -lt 0) {
                throw [System.Management.Automation.ValidationMetadataException] "Positions start at 0!"
            }

            if (($_ -gt (Get-Path).Length)) {
                throw [System.Management.Automation.ValidationMetadataException] "'${_}' exceeds the number of paths."
            }

            return $true
        })]
        [int]$Position = 0
    )

    if (($Position -ne (Get-Path).Length) -and (Test-InPathAtPosition -Path $Path -Position $Position)) {
        return
    }

    $pathList = New-Object -TypeName System.Collections.ArrayList

    Get-Path | ForEach-Object {
        $pathList.Add($_) | Out-Null
    }

    if (Test-InPath $Path) {
        $pathList.Remove($Path) | Out-Null
    }

    $pathList.Insert($Position, $Path)
    $pathString = $pathList -join ';'
    # $pathString
    # if ($pathString)
    # $pathString = $pathString.Substring(0, $pathString.Length - 1)
    # $pathString
    Set-EnvironmentVariable "Path" $pathString
}

function Test-InPath {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    return ((-not ($null -eq (Get-Path))) -and ((Get-Path).Contains($Path)))
}

function Test-InPathAtPosition {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            if ($_ -lt 0) {
                throw [System.Management.Automation.ValidationMetadataException] "Positions start at 0!"
            }

            return $true
        })]
        [int]$Position
    )

    return ((-not ($null -eq (Get-Path))) `
        -and (-not ($Position -ge (Get-Path).Length)) `
        -and ((Get-Path)[$Position] -eq $Path))
}
