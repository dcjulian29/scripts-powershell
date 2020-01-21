function Find-FolderSize {
    param (
        [String]$Path = $pwd.Path
    )

    $width = (Get-Host).UI.RawUI.MaxWindowSize.Width - 5
    $files = Get-ChildItem $Path -Recurse

    $total = 0

    for ($i = 1; $i -le $files.Count-1; $i++) {
        $name = $files[$i].FullName
        $name = $name.Substring(0, [System.Math]::Min($width, $name.Length))
        Write-Progress -Activity "Calculating total size..." `
            -Status $name `
            -PercentComplete ($i / $files.Count * 100)
        $total += $files[$i].Length
    }

    "Total size of '$Path': {0:N2} MB" -f ($total / 1MB)

}

Set-Alias -Name Calculate-Folder-Size -Value Find-FolderSize
Set-Alias -Name Calculate-FolderSize -Value Find-FolderSize

function Get-Midnight {
    (Get-Date).Date
}

Set-Alias -Name midnight -Value Get-Midnight

function Get-OSArchitecture {
    (Get-CimInstance Win32_OperatingSystem).OSArchitecture
}

function Get-OSBoot {
    param (
        [switch]$Elaspsed,
        [switch]$Passthru
    )

    $date = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime

    if ($Elaspsed) {
        $t = ((Get-Date) - ($date))
        if ($Passthru) {
            return $t
        } else {
            if ($t.Days -eq 0) {
                return "{0:d2}:{1:d2}:{2:d2}" -f $t.Hours, $t.Minutes, $t.Seconds
            }

            return "{0}.{1:d2}:{2:d2}:{3:d2}" -f $t.Days, $t.Hours, $t.Minutes, $t.Seconds
        }
    } else {
        return $date
    }
}

function Get-OSCaption {
    (Get-CimInstance Win32_OperatingSystem).Caption
}

function Get-OSInstallDate {
    param (
        [switch]$Days
    )

    $installed = (Get-CimInstance Win32_OperatingSystem).InstallDate

    if ($Days) {
        $elaspsed = ((Get-Date) - ($installed))
        return $elaspsed.Days
    } else {
        return $installed
    }
}

function Get-OSVersion {
    (Get-CimInstance Win32_OperatingSystem).Version
}

function Get-OSRegisteredUser {
    (Get-CimInstance Win32_OperatingSystem).RegisteredUser
}

function Get-OSOrganization {
    (Get-CimInstance Win32_OperatingSystem).Organization
}

function Get-OSBuildNumber {
    (Get-CimInstance Win32_OperatingSystem).BuildNumber
}

function New-RemoteDesktopShortcut {
    param (
        [string]$Path = "$ComputerName.rdp",
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $ComputerName,
        [string]$UserName = "${env:USERDOMAIN}\${env:USERNAME}"
    )

    if (Test-Path $Path) {
        $choice = Select-Item -Caption "RDP File Exists" `
            -Message "Do you want to replace the file?" `
            -choiceList "&Yes", "&No" -default 1

        if ($choice -eq 0) {
            Remove-Item $Path -Force -Confirm:$false
        }
    }

    Set-Content -Path $Path -Value @"
full address:s:$ComputerName
redirectprinters:i:0
redirectcomports:i:0
redirectsmartcards:i:0
redirectclipboard:i:1
redirectposdevices:i:0
username:s:$UserName
screen mode id:i:1
use multimon:i:0
desktopwidth:i:1366
desktopheight:i:768
winposstr:s:0,1,0,24,1390,937
session bpp:i:32
compression:i:1
"@
}

function Remove-EnvironmentVariable {
    param (
        [string]$Name,
        [string]$Scope = "Machine"
    )

    if (Test-Path "env:$Name") {
        Remove-Item "env:$Name" -Force
    }

    [Environment]::SetEnvironmentVariable($Name, $null, $Scope)
}

function Set-EnvironmentVariable {
    param (
        [string]$Name,
        [string]$Value,
        [string]$Scope = "Machine"
    )

    Invoke-Expression "`$env:$Name = ""$Value"""
    [Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
}

function Test-DaylightSavingsInEffect {
    return (Get-WmiObject -Class Win32_ComputerSystem).DaylightInEffect
}

function Test-DomainJoined {
    return (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
}

function Test-NormalBoot {
    if ((Get-WmiObject -Class Win32_ComputerSystem).BootupState -eq "Normal boot") {
        return $true
    } else {
        return $false
    }
}

function Test-OS64Bit {
    if (Get-OSArchitecture -eq "64-bit") {
        return $true
    } else {
        return $false
    }
}
function Test-OSClient {
    return ((Get-CimInstance Win32_OperatingSystem).ProductType -eq 1)
}

function Test-OSDomainController {
    return ((Get-CimInstance Win32_OperatingSystem).ProductType -eq 2)
}

function Test-OSServer {
    return ((Get-CimInstance Win32_OperatingSystem).ProductType -eq 3)
}


function Test-PendingReboot {
    $PendingReboot = $false

    Push-Location "HKLM:\Software\Microsoft\Windows\CurrentVersion\"

    if (Get-ChildItem "Component Based Servicing\RebootPending" -EA Ignore) {
        $PendingReboot = $true
    }

    if (Get-Item "WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) {
        $PendingReboot = $true
    }

    Pop-Location

    Push-Location "HKLM:\SYSTEM\CurrentControlSet\Control"

    if (Get-ItemProperty "Session Manager" -Name PendingFileRenameOperations -EA Ignore) {
        $PendingReboot = $true
    }

    Pop-Location

    return $PendingReboot
}
