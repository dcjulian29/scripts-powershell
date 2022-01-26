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
    [string] $Path
  )

  $options = @(
    "type=nfs"
    "o=addr=$Server,rw"
    "device=:$Path"
  )

  New-DockerVolume -Name $Name -Driver "local" -DriverOptions $options
}

function New-DockerVolume {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string] $Name,
    [string] $Driver,
    [string[]] $DriverOptions
  )

  $options = ""

  if ($Driver) {
    $options = " --driver $Driver"
  }

  if ($DriverOptions) {
    foreach ($option in $DriverOptions) {
      $options += " --opt $option"
    }
  }

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
