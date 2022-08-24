function Find-OpenSCP {
  First-Path `
      (Find-ProgramFiles 'OpenSSH\scp.exe') `
      "$env:windir\System32\OpenSSH\scp.exe"
}

function Invoke-OpenSCP {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$LocalPath,
    [Parameter(Mandatory = $true, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]$RemotePath,
    [Parameter(Mandatory = $true, Position = 3)]
    [ValidateNotNullOrEmpty()]
    [Alias("Remote", "RemoteHost")]
    [string]$ComputerName,
    [int32]$Port,
    [string]$User,
    [string]$IdentityFile,
    [ValidateSet("Up","Upload","Down", "Download", IgnoreCase = $true)]
    [String]$Direction,
    [switch]$Recurse,
    [Alias("NoSave", "Transient", "NoHostChecking")]
    [switch]$Temporary
  )

  if ($ComputerName.Contains("@")) {
    if ($User) {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "You cannot specify an explicit user and also one in computer name." `
        -ExceptionType "System.ArgumentException" `
        -ErrorId "ArgumentException" -ErrorCategory "InvalidArgument"))
    } else {
      $User = $ComputerName.Split('@')[0]
    }

    $ComputerName = $ComputerName.Split('@')[1]
  }

  $arguments = "-F `"$(Get-OpenSSHConfigFileName)`""

  if ((($null -eq $IdentityFile) -or "" -eq $IdentityFile)`
      -and (Test-Path "${env:SystemDrive}\etc\ssh\$ComputerName.key")) {
    $IdentityFile = "${env:SystemDrive}\etc\ssh\$ComputerName.key"
  }

  if ($IdentityFile -and (Test-Path $IdentityFile)) {
    $arguments = $arguments + " -i `"$IdentityFile`""
  }

  if ($Recurse) {
    $arguments += " -r"
  }

  if ($Port) {
    $arguments += " -P $Port"
  }

  if ($Temporary) {
    $arguments = $arguments + " -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
  }

  if ($User) {
    $RemoteHost = "$User@$ComputerName"
  } else {
    $RemoteHost = $ComputerName
  }

  if ($Direction[0] -like 'U') {
    $arguments += " $LocalPath $($RemoteHost):$RemotePath"
  } else {
    $arguments += " $($RemoteHost):$RemotePath $LocalPath"
  }

  $oldTitle = $host.UI.RawUI.WindowTitle

  Write-Verbose "[SCP Arguments] $arguments"
  Invoke-Expression "$(Find-OpenSCP) $arguments"

  $host.UI.RawUI.WindowTitle = $oldTitle
}

Set-Alias -Name "secure-copy" -Value Invoke-OpenSCP

function Receive-OpenSCPPath {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$LocalPath,
    [Parameter(Mandatory = $true, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]$RemotePath,
    [Parameter(Mandatory = $true, Position = 3)]
    [ValidateNotNullOrEmpty()]
    [Alias("Remote", "RemoteHost")]
    [string]$ComputerName,
    [int32]$Port,
    [string]$User,
    [string]$IdentityFile,
    [switch]$Recurse,
    [Alias("NoSave", "Transient", "NoHostChecking")]
    [switch]$Temporary
  )

  Invoke-OpenSCP @PSBoundParameters -Direction Down
}

Set-Alias -Name "secure-copy-receive" -Value Receive-OpenSCPPath

function Send-OpenSCPPath {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$LocalPath,
    [Parameter(Mandatory = $true, Position = 1)]
    [ValidateNotNullOrEmpty()]
    [string]$RemotePath,
    [Parameter(Mandatory = $true, Position = 3)]
    [ValidateNotNullOrEmpty()]
    [Alias("Remote", "RemoteHost")]
    [string]$ComputerName,
    [int32]$Port,
    [string]$User,
    [string]$IdentityFile,
    [switch]$Recurse,
    [Alias("NoSave", "Transient", "NoHostChecking")]
    [switch]$Temporary
  )

  Invoke-OpenSCP @PSBoundParameters -Direction Up
}

Set-Alias -Name "secure-copy-send" -Value Send-OpenSCPPath
