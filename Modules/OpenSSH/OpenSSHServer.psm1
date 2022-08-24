function Disable-OpenSSHServer {
  [CmdletBinding()]
  param ()

  if (Test-Elevation) {
    if (Test-OpenSSHServer) {
      if (Get-Service -Name 'sshd') {
        Set-Service -Name 'sshd' -StartupType 'Disabled'
        if (Test-OpenSSHService) {
          Stop-Service -Name 'sshd'
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

function Enable-OpenSSHServer {
  [CmdletBinding()]
  param ()

  if (Test-Elevation) {
    if (Test-OpenSSHServer) {
      if (Get-Service -Name 'sshd') {
        Set-Service -Name 'sshd' -StartupType 'Automatic'
        if (-not (Test-OpenSSHService)) {
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

function Get-OpenSSHDefaultShell {
  if (Test-Path "HKLM:\SOFTWARE\OpenSSH") {
    $present = Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
      | Select-Object -ExpandProperty 'DefaultShell' `
        -ErrorAction SilentlyContinue | Out-Null

    if ($present) {
      return (Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
        -Name DefaultShell).DefaultShell
    }
  }
}

function Get-OpenSSHDefaultShellOptions {
  if (Test-Path "HKLM:\SOFTWARE\OpenSSH") {
    $present = Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
      | Select-Object -ExpandProperty 'DefaultShellCommandOption' `
        -ErrorAction SilentlyContinue | Out-Null

    if ($present) {
      return (Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
         -Name DefaultShellCommandOption).DefaultShellCommandOption
    }
  }
}

function Set-OpenSSHDefaultShell {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string]$Path,
    [string]$Options = $null
  )

  if (-not (Test-Elevation)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "The requested operation requires elevation." `
      -ExceptionType "System.UnauthorizedAccessException" `
      -ErrorId "PrivilegeNotHeldException" -ErrorCategory "SecurityError"))
  }

  if (-not (Test-OpenSSHServer)) {
    return
  }

  if (-not (Test-Path "HKLM:\SOFTWARE\OpenSSH")) {
    New-Item -Path "HKLM:\SOFTWARE" -Name "OpenSSH" -Force | Out-Null
  }

  New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
    -Name 'DefaultShell' -Value "$Path" `
    -PropertyType 'String' -Force | Out-Null

  if ($Options) {
    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
      -Name 'DefaultShellCommandOption' `
      -Value "$Options" -PropertyType 'String' -Force  | Out-Null
  } else {
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" `
      -Name 'DefaultShellCommandOption' -ErrorAction 'SilentlyContinue'
  }
}

function Test-OpenSSHService {
  if (Get-Service -Name 'sshd' -ErrorAction SilentlyContinue) {
    return ((Get-Service -Name 'sshd').Status -eq "Running")
  } else {
    return $false
  }
}
