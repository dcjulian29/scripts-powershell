function convertSizeString($Size) {
  if ($Size.Contains(' ')) {
    $size = $size.Substring(0, $size.IndexOf(' '))
  }

  $size = $size.ToUpper()
  $size -match '[A-Za-z]+' | Out-Null
  $size = [double]::Parse($size -replace '[^0-9.]')
  switch ($Matches[0]) {
    "KB" { $size = $size * 1KB }
    "MB" { $size = $size * 1MB }
    "GB" { $size = $size * 1GB }
    "TB" { $size = $size * 1TB }
  }

  $size = [long][Math]::Round($size, 0, [MidPointRounding]::AwayFromZero)

  return $size
}

#------------------------------------------------------------------------------

function Find-Docker {
  First-Path `
    ((Get-Command docker -ErrorAction SilentlyContinue).Source) `
    "${env:ALLUSERSPROFILE}\DockerDesktop\version-bin\docker.exe" `
    (Find-ProgramFiles "Docker\Docker\Resources\bin\docker.exe")
}

function Get-DockerDiskUsage {
  $output = Invoke-Docker "system df"

  $list = @()

  if ($output) {
    foreach ($line in $output) {
      if ($line.StartsWith("TYPE")) {
        continue # Exclude Header Row
      }

      $result = $line | Select-String -Pattern '(\S+\s\S+|\S+)' -AllMatches

      $detail = New-Object -TypeName PSObject

      $detail | Add-Member -MemberType NoteProperty -Name Type `
        -Value $result.Matches[0].Value
      $detail | Add-Member -MemberType NoteProperty -Name Total `
        -Value $result.Matches[1].Value
      $detail | Add-Member -MemberType NoteProperty -Name Active `
        -Value $result.Matches[2].Value
      $detail | Add-Member -MemberType NoteProperty -Name Size `
        -Value $(convertSizeString $result.Matches[3].Value)
      $detail | Add-Member -MemberType NoteProperty -Name Reclaimable `
        -Value $(convertSizeString $result.Matches[4].Value)

      $list += $detail
    }
  }

  return $list
}

Set-Alias -Name docker-diskusage -Value Get-DockerDiskUsage

function Get-DockerMountPoint {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [string] $Path,
    [switch] $UnixStyle
  )

  $Path = (Resolve-Path $Path).Path

  if ($UnixStyle) {
    $driveLetter = (Split-Path $Path -Qualifier).Replace(':', '').ToLower()

    return "/mnt/$driveLetter/" + ($Path -replace "${driveLetter}:","").Replace("\", "/").Trim("/")
  } else {
    return $Path.Replace("\", "/").Trim("/")
  }
}

function Get-DockerServerEngine {
  $version = Invoke-Docker "version"

  if (-not $version) {
    return $null
  }

  $server = $false

  foreach ($line in $version) {
    if ($line -like "Server:*") {
      $server = $true
    }

    if ($server) {
      if ($line -like "*OS/Arch:*") {
        return ($line.split(' ', [System.StringSplitOptions]::RemoveEmptyEntries))[1]
      }
    }
  }
}

function Get-FilePathForContainer {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [string] $Path,
    [switch] $MustBeChild
  )

  if (-not (Test-Path -Path $Path -PathType Leaf)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "File does not exists or object is not a file!" `
      -ExceptionType "System.Management.Automation.ItemNotFoundException" `
      -ErrorId "ResourceUnavailable" -ErrorCategory "ResourceUnavailable"))
  }

  Get-PathForContainer -Path $Path -MustBeChild:$MustBeChild.IsPresent
}

function Get-PathForContainer {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [string] $Path,
    [switch] $MustBeChild
  )

  if (-not (Test-Path -Path $Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "Path '$Path' does not exists!" `
      -ExceptionType "System.Management.Automation.ItemNotFoundException" `
      -ErrorId "ResourceUnavailable"  -ErrorCategory "ResourceUnavailable"))
  }

  $Path = (Resolve-Path -Path $Path).Path

  if ($MustBeChild) {
    if (-not (([IO.Path]::GetDirectoryName($Path)).StartsWith([IO.Path]::GetFullPath($pwd)))) {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "Path '$Path' is not a child of the current directory!" `
        -ExceptionType "System.Management.Automation.ItemNotFoundException" `
        -ErrorId "ResourceUnavailable" -ErrorCategory "ResourceUnavailable"))
    }

    return ((Get-DockerMountPoint $Path).Replace("$(Get-DockerMountPoint $pwd.Path)", "."))
  }

  return Get-DockerMountPoint $Path -UnixStyle
}

function Invoke-AlpineContainer {
  if (Test-DockerLinuxEngine) {
    New-DockerContainer -Image "alpine" -Tag "latest" -Interactive -Name "alpine_shell"
  } else {
    Write-Error "Alpine Linux requires the Linux Docker Engine!" -Category ResourceUnavailable
  }
}

Set-Alias -Name alpine -Value Invoke-AlpineContainer

function Invoke-DebianContainer {
  if (Test-DockerLinuxEngine) {
    New-DockerContainer -Image "debian" -Tag "bullseye-slim" -Interactive -Name "debian_shell"
  } else {
    Write-Error "Debian Linux requires the Linux Docker Engine!" -Category ResourceUnavailable
  }
}

Set-Alias -Name debian -Value Invoke-DebianContainer

function Invoke-Dive {
  $params = "$args"

  Invoke-Docker run --rm -it `
    -v "/var/run/docker.sock:/var/run/docker.sock" `
    wagoodman/dive:latest $params
}

Set-Alias -Name dive -Value Invoke-Dive

function Invoke-Docker {
  $docker = Find-Docker

  if ($docker) {
    if (Test-Docker) {
      cmd /c """$docker"" $args"
    } else {
      throw "Docker is not installed on this system."
    }
  }
}

function Optimize-Docker {
  param (
    [switch]$Force
  )

  $params = "--all"

  if ($Force) {
    $params += " --force"
  }

  Invoke-Docker "system prune $params"
}

Set-Alias -Name Prune-Docker -Value Optimize-Docker
Set-Alias -Name docker-prune -Value Optimize-Docker

function Switch-DockerLinuxEngine {
  if (-not (Test-DockerLinuxEngine)) {
    & "C:\Program Files\Docker\Docker\DockerCli.exe" -SwitchLinuxEngine
  }
}

function Switch-DockerWindowsEngine {
  if (-not (Test-DockerWindowsEngine)) {
    & "C:\Program Files\Docker\Docker\DockerCli.exe" -SwitchWindowsEngine
  }
}

function Test-Docker {
  $docker = Find-Docker

  if ($docker) {
    if (Test-Path $docker) {
      return $true
    } else {
      return $false
    }
  }
}

function Test-DockerLinuxEngine {
  if ((Get-DockerServerEngine) -like '*linux*') {
    return $true
  }

  return $false
}

function Test-DockerWindowsEngine {
  if ((Get-DockerServerEngine) -like '*windows*') {
    return $true
  }

  return $false
}
