function Get-DockerVolume {
  [CmdletBinding()]
  param (
    [string] $Name
  )

  if ($Name.Length -eq 0) {
    $net = Invoke-Docker volume ls
    $list = @()

    foreach ($line in $net) {
      if ($line.StartsWith("DRIVER")) {
        continue
      }

      $result = $line | Select-String -Pattern '(\S+)\s+(\S+)'

      $volume = New-Object -TypeName PSObject

      $volume | Add-Member -MemberType NoteProperty -Name Name `
        -Value $result.Matches.Groups[2].Value
      $volume | Add-Member -MemberType NoteProperty -Name Driver `
        -Value $result.Matches.Groups[1].Value

      $list += $volume
    }

    return $list
  } else {
    $json = Invoke-Docker volume inspect $Name

    return $json | ConvertFrom-Json
  }
}

function New-DockerNfsVolume {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string] $Name,
    [Parameter(Mandatory = $true)]
    [string] $Server,
    [Parameter(Mandatory = $true)]
    [string] $Path,
    [switch] $ReadOnly
  )

  if ($ReadOnly) {
    $access = "ro"
  } else {
    $access = "rw"
  }

  $options = @(
    "type=nfs"
    "o=addr=$Server,$access"
    "device=:$Path"
  )

  New-DockerVolume -Name $Name -Driver "local" -DriverOptions $options
}

function New-DockerVolume {
  [CmdletBinding(DefaultParameterSetName = 'Name')]
  param (
    [Parameter(ParameterSetName = "Name", Position = 0, Mandatory = $true)]
    [Parameter(ParameterSetName = "Path", Position = 0, Mandatory = $true)]
    [Parameter(ParameterSetName = "Driver", Position = 0, Mandatory = $true)]
    [Parameter(ParameterSetName = "TempFS", Position = 0, Mandatory = $true)]
    [string] $Name,
    [Parameter(ParameterSetName = "Path", Position = 1, Mandatory = $true)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path,
    [Parameter(ParameterSetName = "Driver", Position = 1, Mandatory = $true)]
    [string] $Driver,
    [Parameter(ParameterSetName = "Driver", Position = 2)]
    [string[]] $DriverOptions,
    [Parameter(ParameterSetName = "TempFS")]
    [string] $Size = "512m",
    [Parameter(ParameterSetName = "TempFS")]
    [int] $UserID = 0,
    [Parameter(ParameterSetName = "TempFS")]
    [Alias("TempFS")]
    [switch] $TemporaryFS
  )

  switch ($PSCmdlet.ParameterSetName) {
    "Driver" {
      $options = " --driver $Driver"

      if ($DriverOptions) {
        foreach ($option in $DriverOptions) {
          $options += " --opt $option"
        }
      }
    }

    "TempFS" {
      $options  = " --driver local --opt type=tmpfs --opt device=tmpfs"
      $options += " --opt o=size=$Size,uid=$UserID"
    }

    "Path" {
      $Path = $(Resolve-Path $Path)
      $options  = " --driver local --opt o=bind --opt type=mount"
      $options += " --opt device=$(ConvertTo-UnixPath $Path)"
    }

    Default {
      $options = ""
    }
  }

  Write-Verbose "Arguments: 'volume create$options $Name'"
  Invoke-Docker volume create$options $Name
}

function Optimize-DockerVolume {
  param (
    [switch] $Force
  )

  $params = "volume prune"

  if ($Force) {
    $params += " --force"
  }

  Invoke-Docker $params
}

Set-Alias -Name Prune-DockerVolume -Value Optimize-DockerVolume

function Remove-DockerVolume {
 [CmdletBinding()]
 param (
  [Parameter(Mandatory = $true)]
  [string] $Name
 )

 Invoke-Docker volume rm $Name
}
