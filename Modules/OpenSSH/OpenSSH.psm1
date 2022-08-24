function Find-OpenSSH {
  First-Path `
      (Find-ProgramFiles 'OpenSSH\ssh.exe') `
      "$env:windir\System32\OpenSSH\ssh.exe"
}

function Invoke-OpenSSH {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias("Remote", "RemoteHost")]
    [string]$ComputerName,
    [string]$Command,
    [string]$IdentityFile,
    [string]$User,
    [int32]$Port,
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

  if (($null -eq $IdentityFile) -and (Test-Path "${env:SystemDrive}\etc\ssh\$ComputerName.key")) {
    $IdentityFile = "${env:SystemDrive}\etc\ssh\$ComputerName.key"
  }

  if ($IdentityFile -and (Test-Path $IdentityFile)) {
    $arguments = $arguments + " -i `"$IdentityFile`""
  }

  if ($Port) {
    $arguments += " -P $Port"
  }

  if ($Temporary) {
    $arguments = $arguments + " -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
  }

  if ($User) {
    $arguments = $arguments + " $User@$ComputerName"
  } else {
    $arguments = $arguments + " $ComputerName"
  }

  if ($Command) {
    $arguments = $arguments + " -t `"$Command`""
  }

  $oldTitle = $host.UI.RawUI.WindowTitle

  Write-Verbose "[SSH Arguments] $arguments"
  Invoke-Expression "$(Find-OpenSSH) $arguments"

  $host.UI.RawUI.WindowTitle = $oldTitle
}

Set-Alias -Name "sshell" -Value Invoke-OpenSSH
Set-Alias -Name "sshellc" -Value Invoke-OpenSSH
Set-Alias -Name "Execute-OpenSSHCommand" -Value Invoke-OpenSSH
Set-Alias -Name "Invoke-OpenSSHCommand" -Value Invoke-OpenSSH
