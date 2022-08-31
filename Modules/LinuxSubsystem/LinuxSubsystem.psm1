function Disable-LinuxSubsystem {
  if (-not (Get-WindowsOptionalFeature -online | Where-Object { $_.FeatureName -eq 'Microsoft-Windows-Subsystem-Linux' }).State) {
    Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
  }
}

function Enable-LinuxSubsystem {
  if (-not (Get-WindowsOptionalFeature -online | Where-Object { $_.FeatureName -eq 'Microsoft-Windows-Subsystem-Linux' }).State) {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

    Write-Warning "You must reboot before using the Linux Subsystem..."
  }
}

function Restart-LinuxSubsystem {
  if (Test-LinuxSubsystem) {
    Get-Service LxssManager | Restart-Service
  }
}

function Start-UbuntuLinux {
  $ubuntu = (Get-ChildItem -Path "${env:SYSTEMDRIVE}\Ubuntu" `
    | Where-Object { $_.Name -match "^Ubuntu\d{4}.exe" } `
    | Sort-Object Name -Descending `
    | Select-Object -First 1).FullName

  if ($ubuntu) {
    Start-Process -FilePath $ubuntu -NoNewWindow -Wait
  }
}

Set-Alias ubuntu Start-UbuntuLinux

function Test-LinuxSubsystem {
  return (Get-WindowsOptionalFeature -online | Where-Object { $_.FeatureName -eq 'Microsoft-Windows-Subsystem-Linux' }).State
}

