function Disable-LinuxSubsystem {
  [CmdletBinding()]
  param ( )

  if (-not (Test-LinuxSubsystem)) {
    Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
  }
}

function Enable-LinuxSubsystem {
  [CmdletBinding()]
  param ( )

  if (-not (Test-LinuxSubsystem)) {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

    Write-Warning "You must reboot before using the Linux Subsystem..."
  }
}

function Export-LinuxSubsystemDistribution {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [Alias("DistributionName", "DistroName")]
    [string] $Name,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Path
  )

  if (Test-Path -Path $Path -PathType Container) {
    $Path = Join-Path -Path $Path -ChildPath "$Name.tar"
  }

  wsl.exe --export $Name $Path
}

function Get-LinuxSubsystemDistribution {
  [CmdletBinding()]
  param (
    [string] $Name,
    [switch] $Running
   )

  $results = @()
  $m = (wsl.exe --list --verbose) -replace "`0" -split "`n" `
    | Select-String -Pattern '(\*|\s)\s([\S]+)\s+([\S]+)\s+([\S]+)' -AllMatches

  $m | ForEach-Object {
    if ($_.Matches.Groups[2].Value -ne 'NAME') {
      if ($_.Matches.Groups[1].Value -eq '*') {
        $default = $true
      } else {
        $default = $false
      }

      $results += [PSCustomObject]@{
        Name = $_.Matches.Groups[2].Value
        State = $_.Matches.Groups[3].Value
        Version = $_.Matches.Groups[4].Value
        Default = $default
      }
    }
  }

  if ($Name.Length -gt 0) {
    $results = $results | Where-Object { $_.Name -like "*$Name*" }
  }

  if ($Running) {
    $results = $results | Where-Object { $_.State -eq "Running" }
  }

  return $results
}

function Get-LinuxSubsystemParentProcess {
  [CmdletBinding()]
  param ( )

  $id = tasklist /svc /fi "imagename eq svchost.exe" `
    | Select-String ".*\s(\d+)\sLxssManager" `
    | ForEach-Object { "$($_.Matches.Groups[1])" }

  if ($id.Length -lt 2) { $id = $null }

  return $id
}

function Import-LinuxSubsystemDistribution {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [Alias("DistributionName", "DistroName")]
    [string] $Name,
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path -Path $(Resolve-Path $_) -PathType Leaf })]
    [string] $Path
  )

  wsl.exe --import $Name $(Resolve-Path $Path)
}

function Restart-LinuxSubsystem {
  [CmdletBinding()]
  param ( )

  if (Test-LinuxSubsystem) {
    Get-Service LxssManager | Stop-Service

    $id = Get-LinuxSubsystemParentProcess

    if ($id) {
      Get-Process -Id $id | Stop-Process -Force
    }

    Get-Service LxssManager | Start-Service
  }
}

function Set-LinuxSubsystemDistribution {
  [CmdletBinding(DefaultParameterSetName = "default")]
  param (
    [parameter(ParameterSetName = "default", Mandatory = $true)]
    [parameter(ParameterSetName = "user", Mandatory = $true)]
    [parameter(ParameterSetName = "version", Mandatory = $true)]
    [Alias("DistributionName", "DistroName")]
    [string] $Name,

    [parameter(ParameterSetName = "user", Mandatory = $true)]
    [string] $User,

    [parameter(ParameterSetName = "version", Mandatory = $true)]
    [string] $Version,

    [parameter(ParameterSetName = "default", Mandatory = $true)]
    [switch] $Default
  )

  switch ($PSCmdlet.ParameterSetName) {
    "user" {
      Get-ItemProperty Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lxss\*\ DistributionName `
        | Where-Object -Property DistributionName -eq $Name `
        | Set-ItemProperty -Name DefaultUid `
          -Value ((wsl.exe -d $Name -u $User -e id -u) | Out-String)
    }

    "version" {
      wsl.exe --set-version $Version $Name
    }

    "default" {
      wsl.exe -d $Name --set-default
    }
  }
}

function Stop-LinuxSubsystemDistribution {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [Alias("DistributionName", "DistroName")]
    [string] $Name
  )

  wsl.exe -d $Name --terminate
}

function Test-LinuxSubsystem {
  return (Get-WindowsOptionalFeature -online `
    | Where-Object { $_.FeatureName -eq 'Microsoft-Windows-Subsystem-Linux' }).State
}
