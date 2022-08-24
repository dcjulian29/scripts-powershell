function getServerPackageName {
    return (Get-WindowsCapability -online `
        | Where-Object { $_.Name -like "*OpenSSH.Server*" }).Name
}

function getClientPackageName {
    return (Get-WindowsCapability -online `
        | Where-Object { $_.Name -like "*OpenSSH.Client*" }).Name
}

###############################################################################

function Add-OpenSSHClient {
  [CmdletBinding()]
  param ()

  if (Test-Elevation) {
    if (-not (Test-OpenSSHClient)) {
      Add-WindowsCapability -Online -Name $(getClientPackageName)
    }
  } else {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "The requested operation requires elevation." `
      -ExceptionType "System.UnauthorizedAccessException" `
      -ErrorId "PrivilegeNotHeldException" -ErrorCategory "SecurityError"))
  }
}

function Add-OpenSSHServer {
  [CmdletBinding()]
  param ()

  if (Test-Elevation) {
    if (-not (Test-OpenSSHServer)) {
      Add-WindowsCapability -Online -Name $(getServerPackageName)

      if (Test-OpenSSHServer) {
        Set-OpenSSHDefaultShell "$env:windir\System32\WindowsPowerShell\v1.0\powershell.exe"

        if (Get-Service -Name 'sshd') {
          Set-Service -Name 'sshd' -StartupType 'Automatic'
          Start-Service -Name 'sshd'
        }
      }
    }
  } else {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "The requested operation requires elevation." `
      -ExceptionType "System.UnauthorizedAccessException" `
      -ErrorId "PrivilegeNotHeldException" -ErrorCategory "SecurityError"))
  }
}

function Remove-OpenSSHClient {
  [CmdletBinding()]
  param ()

  if (Test-Elevation) {
    if (Test-OpenSSHClient) {
      Remove-WindowsCapability -Online -Name $(getClientPackageName)
    }
  } else {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "The requested operation requires elevation." `
      -ExceptionType "System.UnauthorizedAccessException" `
      -ErrorId "PrivilegeNotHeldException" -ErrorCategory "SecurityError"))
  }
}

function Remove-OpenSSHServer {
  [CmdletBinding()]
  param ()

  if (Test-Elevation) {
    if (Test-OpenSSHServer) {
      if (Get-Service -Name 'sshd') {
        Stop-Service -Name 'sshd' -Force
      }

      Remove-WindowsCapability -Online -Name $(getServerPackageName) | Out-Null
    }
  } else {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "The requested operation requires elevation." `
      -ExceptionType "System.UnauthorizedAccessException" `
      -ErrorId "PrivilegeNotHeldException" -ErrorCategory "SecurityError"))
  }
}

function Test-OpenSSHClient {
  [CmdletBinding()]
  param ()

  if (Test-Elevation) {
    return ((Get-WindowsCapability -Online -Name $(getClientPackageName)).State -eq "Installed")
  } else {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "The requested operation requires elevation." `
      -ExceptionType "System.UnauthorizedAccessException" `
      -ErrorId "PrivilegeNotHeldException" -ErrorCategory "SecurityError"))
  }
}

function Test-OpenSSHServer {
  [CmdletBinding()]
  param ()

  if (Test-Elevation) {
    return ((Get-WindowsCapability -Online -Name $(getServerPackageName)).State -eq "Installed")
  } else {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "The requested operation requires elevation." `
      -ExceptionType "System.UnauthorizedAccessException" `
      -ErrorId "PrivilegeNotHeldException" -ErrorCategory "SecurityError"))
  }
}
