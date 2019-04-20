$Script:UbuntuVersion = 1804

function Enable-WindowsLinuxSubsystem {
    if (-not (Get-WindowsOptionalFeature -online | Where-Object { $_.FeatureName -eq 'Microsoft-Windows-Subsystem-Linux' }).State) {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

        Write-Warning "You must reboot before using the Linux Subsystem..."
    }
}

function Disable-WindowsLinuxSubsystem {
    if (-not (Get-WindowsOptionalFeature -online | Where-Object { $_.FeatureName -eq 'Microsoft-Windows-Subsystem-Linux' }).State) {
        Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    }
}

function Install-Ubuntu {
    if (-not (Get-WindowsOptionalFeature -online | Where-Object { $_.FeatureName -eq 'Microsoft-Windows-Subsystem-Linux' }).State) {
        Write-Warning "You must enable the Windows Linux Subsystem..."

        return
    }

    Push-Location -Path $env:TEMP

    Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-$Script:UbuntuVersion -OutFile Ubuntu.appx -UseBasicParsing

    Rename-Item Ubuntu.appx Ubuntu.zip

    if (Test-Path $env:SYSTEMDRIVE\Ubuntu) {
        Remove-Item -Path $env:SYSTEMDRIVE\Ubuntu -Recurse -Force | Out-Null
    }

    New-Item -Type Directory -Path $env:SYSTEMDRIVE\Ubuntu | Out-Null

    Expand-Archive Ubuntu.zip $env:SYSTEMDRIVE\Ubuntu

    Set-Content $env:SYSTEMDRIVE\Ubuntu\desktop.ini @"
    [.ShellClassInfo]
    IconResource=$env:SYSTEMDRIVE\Ubuntu\ubuntu$Script:UbuntuVersion.exe,0
"@

    attrib +S +H $env:SYSTEMDRIVE\Ubuntu\desktop.ini
    attrib +S $env:SYSTEMDRIVE\Ubuntu

    Write-Output "Ubuntu Linux has been installed...  Starting final install."

    Pop-Location

    Remove-Item -Path $env:TEMP\ubuntu.zip -Force | Out-Null

    Start-Process -FilePath $env:SYSTEMDRIVE\Ubuntu\ubuntu$Script:UbuntuVersion.exe -NoNewWindow -Wait
}

function Uninstall-Ubuntu {
    wslconfig.exe /u ubuntu-$Script:UbuntuVersion

    if (Test-Path $env:SYSTEMDRIVE\Ubuntu) {
        Remove-Item -Path $env:SYSTEMDRIVE\Ubuntu -Recurse -Force | Out-Null
    }
}

function Start-Ubuntu {
    Start-Process -FilePath $env:SYSTEMDRIVE\Ubuntu\ubuntu$Script:UbuntuVersion.exe -NoNewWindow -Wait
}

function Install-KaliLinux {
    if (-not (Get-WindowsOptionalFeature -online | Where-Object { $_.FeatureName -eq 'Microsoft-Windows-Subsystem-Linux' }).State) {
        Write-Warning "You must reboot before using the Linux Subsystem..."

        return
    }

    Push-Location -Path $env:TEMP

    Invoke-WebRequest -Uri https://aka.ms/wsl-kali-linux -OutFile Kali.appx -UseBasicParsing

    Rename-Item Kali.appx Kali.zip

    if (Test-Path $env:SYSTEMDRIVE\Kali) {
        Remove-Item -Path $env:SYSTEMDRIVE\Kali -Recurse -Force | Out-Null
    }

    New-Item -Type Directory -Path $env:SYSTEMDRIVE\Kali | Out-Null

    if (Test-Path $env:TEMP\Kali) {
        Remove-Item -Path $env:TEMP\Kali -Recurse -Force | Out-Null
    }

    New-Item -Type Directory -Path $env:TEMP\Kali | Out-Null

    Expand-Archive Kali.zip $env:TEMP\Kali

    Rename-Item (Get-ChildItem -Filter "DistroL*x64.appx" -Path .).FullName Kali.zip

    Expand-Archive Kali.zip $env:SYSTEMDRIVE\Kali

    Set-Content $env:SYSTEMDRIVE\Kali\desktop.ini @"
    [.ShellClassInfo]
    IconResource=$env:SYSTEMDRIVE\Kali\kali.exe,0
"@

    attrib +S +H $env:SYSTEMDRIVE\Kali\desktop.ini
    attrib +S $env:SYSTEMDRIVE\Kali

    Write-Output "Kali Linux has been installed...  Starting final install."

    Pop-Location

    Remove-Item -Path $env:TEMP\Kali -Recurse -Force | Out-Null
    Remove-Item -Path $env:TEMP\kali.zip -Force | Out-Null

    Start-Process -FilePath $env:SYSTEMDRIVE\Kali\Kali.exe -ArgumentList "install --root" `
        -NoNewWindow -Wait
}

function Uninstall-KaliLinux {
    wslconfig.exe /u Kali

    if (Test-Path $env:SYSTEMDRIVE\Kali) {
        Remove-Item -Path $env:SYSTEMDRIVE\Kali -Recurse -Force | Out-Null
    }
}

function Start-KaliLinux {
    Start-Process -FilePath $env:SYSTEMDRIVE\Kali\kali.exe -NoNewWindow -Wait
}

###############################################################################

Export-ModuleMember Enable-WindowsLinuxSubsystem
Export-ModuleMember Disable-WindowsLinuxSubsystem

Export-ModuleMember Install-Ubuntu
Export-ModuleMember Uninstall-Ubuntu
Export-ModuleMember Start-Ubuntu

Export-ModuleMember Install-KaliLinux
Export-ModuleMember Uninstall-KaliLinux
Export-ModuleMember Start-KaliLinux

Set-Alias ubuntu Start-Ubuntu
Export-ModuleMember -Alias Start-Ubuntu

Set-Alias kali Start-KaliLinux
Export-ModuleMember -Alias Start-KaliLinux
