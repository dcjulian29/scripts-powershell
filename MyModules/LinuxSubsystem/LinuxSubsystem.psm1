function Disable-WindowsLinuxSubsystem {
    if (-not (Get-WindowsOptionalFeature -online | Where-Object { $_.FeatureName -eq 'Microsoft-Windows-Subsystem-Linux' }).State) {
        Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    }
}

function Enable-WindowsLinuxSubsystem {
    if (-not (Get-WindowsOptionalFeature -online | Where-Object { $_.FeatureName -eq 'Microsoft-Windows-Subsystem-Linux' }).State) {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

        Write-Warning "You must reboot before using the Linux Subsystem..."
    }
}

function Install-KaliLinux {
    if (-not (Test-WindowsLinuxSubsystem)) {
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

    if (Test-Path $env:TEMP\ubuntu.zip) {
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

    Rename-Item (Get-ChildItem -Filter "DistroL*x64.appx" -Path $env:TEMP\Kali).FullName $env:TEMP\Kali\Kali.zip

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

function Install-Ubuntu {
    if (-not (Test-WindowsLinuxSubsystem)) {
        Write-Warning "You must enable the Windows Linux Subsystem..."

        return
    }

    if (Test-Path $env:SYSTEMDRIVE\Ubuntu) {
        Write-Output "Ubuntu Linux is already installed..."

        return
    }

    if (Test-Path $env:TEMP\ubuntu.appx) {
        Remove-Item -Path $env:TEMP\ubuntu.appx -Force | Out-Null
    }

    if (Test-Path $env:TEMP\ubuntu.zip) {
        Remove-Item -Path $env:TEMP\ubuntu.zip -Force | Out-Null
    }

    Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile $env:TEMP\Ubuntu.appx -UseBasicParsing

    Rename-Item $env:TEMP\Ubuntu.appx $env:TEMP\Ubuntu.zip

    New-Item -Type Directory -Path $env:SYSTEMDRIVE\Ubuntu | Out-Null

    Expand-Archive $env:TEMP\Ubuntu.zip $env:SYSTEMDRIVE\Ubuntu

    Set-Content $env:SYSTEMDRIVE\Ubuntu\desktop.ini @"
    [.ShellClassInfo]
    IconResource=$env:SYSTEMDRIVE\Ubuntu\ubuntu1804.exe,0
"@

    attrib +S +H $env:SYSTEMDRIVE\Ubuntu\desktop.ini
    attrib +S $env:SYSTEMDRIVE\Ubuntu

    Remove-Item -Path $env:TEMP\ubuntu.zip -Force | Out-Null

    if (-not (Test-Path $env:SYSTEMDRIVE\Ubuntu\rootfs)) {
        Write-Output "Ubuntu Linux has been installed...  Starting final install."

        Start-Process -FilePath $env:SYSTEMDRIVE\Ubuntu\ubuntu1804.exe `
            -ArgumentList "install --root" -NoNewWindow -Wait

        Start-Process -FilePath $env:SYSTEMDRIVE\Ubuntu\ubuntu1804.exe `
            -ArgumentList "run adduser $($env:USERNAME) --gecos ""First,Last,RoomNumber,WorkPhone,HomePhone"" `
            --disabled-password" -NoNewWindow -Wait

        Start-Process -FilePath $env:SYSTEMDRIVE\Ubuntu\ubuntu1804.exe `
            -ArgumentList "run usermod -aG sudo $($env:USERNAME)" -NoNewWindow -Wait

        Start-Process -FilePath $env:SYSTEMDRIVE\Ubuntu\ubuntu1804.exe `
            -ArgumentList "run echo '$($env:USERNAME) ALL=(ALL) NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo" `
            -NoNewWindow -Wait

        Start-Process -FilePath $env:SYSTEMDRIVE\Ubuntu\ubuntu1804.exe `
            -ArgumentList "config --default-user $($env:USERNAME)" -NoNewWindow -Wait

        Start-Process -FilePath $env:SYSTEMDRIVE\Ubuntu\ubuntu1804.exe `
            -ArgumentList "run curl -sSL http://dl.julianscorner.com/l/init.sh | bash" -NoNewWindow -Wait
    } else {
        Write-Warning "Ubuntu Linux has already been installed..."
    }
}

function Start-KaliLinux {
    Start-Process -FilePath $env:SYSTEMDRIVE\Kali\kali.exe -NoNewWindow -Wait
}

Set-Alias kali Start-KaliLinux

function Start-UbuntuLinux {
    Start-Process -FilePath $env:SYSTEMDRIVE\Ubuntu\ubuntu$Script:UbuntuVersion.exe -NoNewWindow -Wait
}

Set-Alias ubuntu Start-UbuntuLinux

function Test-WindowsLinuxSubsystem {
    return (Get-WindowsOptionalFeature -online | Where-Object { $_.FeatureName -eq 'Microsoft-Windows-Subsystem-Linux' }).State
}

function Uninstall-KaliLinux {
    wslconfig.exe /u Kali

    if (Test-Path $env:SYSTEMDRIVE\Kali) {
        Remove-Item -Path $env:SYSTEMDRIVE\Kali -Recurse -Force | Out-Null
    }
}

function Uninstall-Ubuntu {
    wslconfig.exe /u "Ubuntu-18.04"

    if (Test-Path $env:SYSTEMDRIVE\Ubuntu) {
        Remove-Item -Path $env:SYSTEMDRIVE\Ubuntu -Recurse -Force | Out-Null
    }
}
