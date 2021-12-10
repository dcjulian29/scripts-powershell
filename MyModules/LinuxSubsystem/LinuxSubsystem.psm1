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

function Install-KaliLinux {
  if (-not (Test-LinuxSubsystem)) {
    Write-Warning "You must reboot before using the Linux Subsystem..."

    return
  }

  if (Test-Path $env:SYSTEMDRIVE\Kali) {
    Write-Warning "Kali Linux is already installed..."

    return
  }

  if (Test-Path $env:TEMP\kali.appx) {
      Remove-Item -Path $env:TEMP\kali.appx -Force | Out-Null
  }

  if (Test-Path $env:TEMP\kali.zip) {
      Remove-Item -Path $env:TEMP\kali.zip -Force | Out-Null
  }

  Invoke-WebRequest -Uri https://aka.ms/wsl-kali-linux -OutFile $env:TEMP\Kali.appx -UseBasicParsing

  Rename-Item $env:TEMP\Kali.appx $env:TEMP\Kali.zip

  New-Item -Type Directory -Path $env:SYSTEMDRIVE\Kali | Out-Null

  if (Test-Path $env:TEMP\Kali) {
      Remove-Item -Path $env:TEMP\Kali -Recurse -Force | Out-Null
  }

  New-Item -Type Directory -Path $env:TEMP\Kali | Out-Null

  Expand-Archive $env:TEMP\Kali.zip $env:TEMP\Kali

  Rename-Item -Path (Get-ChildItem -Filter "DistroL*x64.appx" -Path $env:TEMP\Kali).FullName `
    -NewName $env:TEMP\Kali\Kali.zip

  Expand-Archive $env:TEMP\Kali\Kali.zip $env:SYSTEMDRIVE\Kali

  Set-Content $env:SYSTEMDRIVE\Kali\desktop.ini @"
  [.ShellClassInfo]
  IconResource=$env:SYSTEMDRIVE\Kali\kali.exe,0
"@

  attrib +S +H $env:SYSTEMDRIVE\Kali\desktop.ini
  attrib +S $env:SYSTEMDRIVE\Kali

  Remove-Item -Path $env:TEMP\Kali -Recurse -Force | Out-Null
  Remove-Item -Path $env:TEMP\kali.zip -Force | Out-Null

  Write-Output "Kali Linux has been installed...  Starting final install."

  Start-Process -FilePath $env:SYSTEMDRIVE\Kali\Kali.exe -ArgumentList "install --root" `
      -NoNewWindow -Wait
}

function Restart-LinuxSubsystem {
  if (Test-LinuxSubsystem) {
    Get-Service LxssManager | Restart-Service
  }
}

function Start-KaliLinux {
  if (Test-Path $env:SYSTEMDRIVE\Kali\kali.exe) {
    Start-Process -FilePath $env:SYSTEMDRIVE\Kali\kali.exe -NoNewWindow -Wait
  }
}

Set-Alias kali Start-KaliLinux

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

function Uninstall-KaliLinux {
  wslconfig.exe /u MyDistribution  #Kali

  if (Test-Path $env:SYSTEMDRIVE\Kali) {
    Remove-Item -Path $env:SYSTEMDRIVE\Kali -Recurse -Force | Out-Null
  }
}
