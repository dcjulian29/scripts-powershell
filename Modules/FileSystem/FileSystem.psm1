function Assert-FolderExists {
  process {
    if (-not (Test-Path -Path $_ -PathType Container)) {
      Write-Warning "$_ did not exist. Folder created."
      New-Folder -Path $_
    }
  }
}

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

function Find-FolderSize {
  param (
      [String]$Path = $pwd.Path
  )

  $width = (Get-Host).UI.RawUI.MaxWindowSize.Width - 5
  $files = Get-ChildItem $Path -Recurse

  $total = 0

  for ($i = 1; $i -le $files.Count-1; $i++) {
      $name = $files[$i].FullName
      $name = $name.Substring(0, [System.Math]::Min($width, $name.Length))
      Write-Progress -Activity "Calculating total size..." `
          -Status $name `
          -PercentComplete ($i / $files.Count * 100)
      $total += $files[$i].Length
  }

  "Total size of '$Path': {0:N2} MB" -f ($total / 1MB)

}

Set-Alias -Name Calculate-Folder-Size -Value Find-FolderSize
Set-Alias -Name Calculate-FolderSize -Value Find-FolderSize

function Format-FileWithSpaceIndent {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ Test-Path $(Resolve-Path $_) })]
      [string] $Path,
      [int]$spaces = 4
  )

  $tab = "`t"
  $space = " " * $spaces
  $text = Get-Content -Path $Path

  $newText = ""

  foreach ($line in $text -split [Environment]::NewLine) {
      if ($line -match "\S") {
          $pos = $line.IndexOf($Matches[0])
          $indentation = $line.SubString(0, $pos)
          $remainder = $line.SubString($pos)

          $replaced = $indentation -replace $tab, $space

          $newText += $replaced + $remainder + [Environment]::NewLine
      } else {
          $newText += $line + [Environment]::NewLine
      }

      Set-Content -Path $Path -Value $text
  }
}

function Format-FileWithTabIndent {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ Test-Path $(Resolve-Path $_) })]
      [string] $Path,
      [int]$Spaces = 4
  )

  $tab = "`t"
  $space = " " * $spaces
  $text = Get-Content -Path $Path

  $newText = ""

  foreach ($line in $text -split [Environment]::NewLine) {
      if ($line -match "\S") {
          $pos = $line.IndexOf($Matches[0])
          $indentation = $line.SubString(0, $pos)
          $remainder = $line.SubString($pos)

          $replaced = $indentation -replace $space, $tab

          $newText += $replaced + $remainder + [Environment]::NewLine
      } else {
          $newText += $line + [Environment]::NewLine
      }

      Set-Content -Path $Path -Value $text
  }
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

function Get-Share {
  Get-WMIObject Win32_share
}

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

function New-FileLink {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory = $true)]
      [string] $LinkPath,
      [Parameter(Mandatory = $true)]
      [string] $TargetPath,
      [Alias("Recreate")]
      [switch] $Force,
      [Alias("Quiet")]
      [switch] $Silent,
      [switch] $TargetNotFoundOk,
      [switch] $LinkExistOk
  )

  if (-not (Test-Path $TargetPath)) {
    if ($TargetNotFoundOk) { return }

    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "'$TargetPath' does not exists!" `
      -ExceptionType "System.Management.Automation.ItemNotFoundException" `
      -ErrorId "ResourceUnavailable" -ErrorCategory "ResourceUnavailable"))
  }

  if (-not (Test-Path (Split-Path -Parent $LinkPath))) {
    New-Folder (Split-Path -Parent $LinkPath)
  }

  if (Test-Path $LinkPath) {
    if ($Force) {
      Remove-Item -Path $LinkPath -Recurse -Force
    } else {
      if ($Silent) {
        return
      }

      if ($LinkExistOk) {
        Write-Output "Already exist '$LinkPath' ---> '$TargetPath'"
        return
      }

      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "An item with the specified name '$LinkPath' already exists." `
        -ExceptionType "Microsoft.PowerShell.Commands.NewItemCommand" `
        -ErrorId "DirectoryExist" -ErrorCategory "ResourceExist"))
    }
  }

  if (-not ($Silent)) {
    Write-Output "Creating '$LinkPath' ---> '$TargetPath'"
  }

  New-Item -ItemType SymbolicLink -Path $LinkPath -Value $TargetPath | Out-Null
}

function New-Folder {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string] $Path
  )

  if (-not (Test-Path $Path)) {
    do {
      $parent = Split-Path -Parent $Path
      while ("" -ne $parent) {
        if (Test-Path $parent) {
          if (($Path.LastIndexOf("\") -eq $parent.Length) -or ($last -eq $parent)) {
            break
          } else {
            if ($null -eq $last) {
              $parent = Split-Path -Parent $Path
              break
            }

            New-Item -ItemType Directory -Path $last  | Write-Verbose
            $parent = ""
          }
        }

        if ("" -ne $parent) {
          $last = $parent
          $parent = Split-Path -Parent $parent
        }
      }
    } until ($parent -eq (Split-Path -Parent $Path))

    New-Item -ItemType Directory -Path $Path  | Write-Verbose
  }
}

function New-FolderLink {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory = $true)]
      [string] $LinkPath,
      [Parameter(Mandatory = $true)]
      [string] $TargetPath,
      [Alias("Recreate")]
      [switch] $Force,
      [Alias("Quiet")]
      [switch] $Silent,
      [switch] $TargetNotFoundOk,
      [switch] $LinkExistOk
  )

  if (-not (Test-Path $TargetPath)) {
    if ($TargetNotFoundOk) { return }

    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "'$TargetPath' does not exists!" `
      -ExceptionType "System.Management.Automation.ItemNotFoundException" `
      -ErrorId "ResourceUnavailable" -ErrorCategory "ResourceUnavailable"))
  }

  if (-not (Test-Path (Split-Path -Parent $LinkPath))) {
    New-Folder (Split-Path -Parent $LinkPath)
  }

  if (Test-Path $LinkPath) {
    if ($Force) {
      Remove-Item -Path $LinkPath -Recurse -Force
    } else {
      if ($Silent) {
        return
      }

      if ($LinkExistOk) {
        Write-Output "Already exist '$LinkPath' ---> '$TargetPath'"
        return
      }

      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "An item with the specified name '$LinkPath' already exists." `
        -ExceptionType "Microsoft.PowerShell.Commands.NewItemCommand" `
        -ErrorId "DirectoryExist" -ErrorCategory "ResourceExist"))
    }
  }

  if (-not ($Silent)) {
    Write-Output "Creating '$LinkPath' ---> '$TargetPath'"
  }

  New-Item -ItemType Junction -Path (Split-Path -Parent $LinkPath) `
    -Value $TargetPath | Out-Null
}

function New-Share {
  param (
    [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true)]
    [string]$FolderName,
    [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true)]
    [string]$ShareName,
    [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$false)]
    [string]$Description
  )

  if (-not (Test-Path $FolderName)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "$($FolderName) does not exists!" `
      -ExceptionType "System.Management.Automation.ItemNotFoundException" `
      -ErrorId "ResourceUnavailable" -ErrorCategory "ResourceUnavailable"))
  }

  if (-not (Get-WMIObject Win32_share -filter "name='$ShareName'")) {
    $trustee = ([WMIClass] "Win32_Trustee").CreateInstance()
    $trustee.Name = "EVERYONE"
    $trustee.Domain = $Null
    $trustee.SID = @(1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)

    $ace = ([WMIClass] "Win32_ACE").CreateInstance()
    $ace.AccessMask = 2032127
    $ace.AceFlags = 3
    $ace.AceType = 0
    $ace.Trustee = $trustee

    $sd = ([WMIClass] "Win32_SecurityDescriptor").CreateInstance()
    $sd.DACL += $ace.psObject.baseobject

    $shares = [WMICLASS]"WIN32_Share"
    $params =  $shares.psbase.GetMethodParameters("Create")

    $params.Access = $sd
    $params.Description = $Description
    $params.MaximumAllowed = $Null
    $params.Name = $ShareName
    $params.Password = $Null
    $params.Path = $FolderName
    $params.Type = [uint32]0

    $r = $shares.PSBase.InvokeMethod("Create", $params, $Null)

    if ($r.ReturnValue -eq 0) {
      Write-Output "Share $($ShareName) created at $($FolderName)..."
    } else {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "Error creating share '$ShareName'!" `
        -ExceptionType "System.Runtime.InteropServices.ExternalException" `
        -ErrorId "InvalidOperation" -ErrorCategory "InvalidOperation"))
    }
  } else {
    Write-Warning "Share $($ShareName) already exists..."
  }
}

function Remove-FilePermission {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path,
    [string] $UserOrGroup = "",
    [switch] $All
  )

  $acl = Get-Acl -Path $Path

  if ($UserOrGroup -ne "") {
    foreach ($access in $acl.Access) {
      if ($access.IdentityReference.Value -eq $UserOrGroup) {
        $acl.RemoveAccessRule($access) | Out-Null
      }
    }
  }

  if ($All) {
    foreach ($access in $acl.Access) {
      $acl.RemoveAccessRule($access) | Out-Null
    }
  }

  Set-Acl -Path $folder.FullName -AclObject $acl
}

function Set-FileInheritance {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path,
    [switch] $DisableInheritance,
    [switch] $KeepInheritedAcl
  )

  $acl = Get-Acl -Path $Path

  $acl.SetAccessRuleProtection($DisableInheritance.IsPresent, $KeepInheritedAcl.IsPresent)

  $acl | Set-Acl -Path $Path
}

function Set-FilePermission {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path,
    [string] $UserOrGroup = "",
    [ValidateSet('ContainerInherit', 'ObjectInherit', 'InheritOnly')]
    [string[]] $InheritedFolderPermissions = @("ContainerInherit", "ObjectInherit"),
    [string] $AccessControlType = "Allow",
    [string] $PropagationFlags = "None",
    [ValidateSet('ListDirectory', 'ReadData', 'WriteData', 'CreateFiles',
                 'CreateDirectories', 'AppendData', 'Synchronize',
                 'FullControl', 'ReadExtendedAttributes', 'WriteExtendedAttributes',
                 'Traverse', 'ExecuteFile', 'DeleteSubdirectoriesAndFiles',
                 'ReadAttributes', 'WriteAttributes', 'Write', 'Delete',
                 'ReadPermissions', 'Read', 'ReadAndExecute', 'Modify',
                 'ChangePermissions', 'TakeOwnership')]
    [string[]] $AclRightsToAssign
  )

  $acl = Get-Acl -Path $Path
  $perm = $UserOrGroup, $AclRightsToAssign, $InheritedFolderPermissions, `
    $PropagationFlags, $AccessControlType
  $rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule `
    -ArgumentList $perm

  $acl.SetAccessRule($rule)

  Set-Acl -Path $Path $acl
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
