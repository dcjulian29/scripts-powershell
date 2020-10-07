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

function Get-OSActivationStatus {
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$ComputerName = $Env:COMPUTERNAME
    )

    try {
        $wpa = Get-WmiObject SoftwareLicensingProduct -ComputerName $ComputerName `
            -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'" `
            -Property LicenseStatus -ErrorAction Stop
    } catch {
        $status = New-Object ComponentModel.Win32Exception ($_.Exception.ErrorCode)
        $wpa = $null
    }

    $output = New-Object psobject -Property @{
        ComputerName = $ComputerName;
        Status = [string]::Empty;
    }

    if ($wpa) {
        :outer foreach($item in $wpa) {
            switch ($item.LicenseStatus) {
                0 {$output.Status = "Unlicensed"}
                1 {$output.Status = "Licensed"; break outer}
                2 {$output.Status = "Out-Of-Box Grace Period"; break outer}
                3 {$output.Status = "Out-Of-Tolerance Grace Period"; break outer}
                4 {$output.Status = "Non-Genuine Grace Period"; break outer}
                5 {$output.Status = "Notification"; break outer}
                6 {$output.Status = "Extended Grace"; break outer}
                default {$output.Status = "Unknown value"}
            }
        }
    } else {
        $output.Status = $status.Message
    }

    return $output
}

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

function Get-OSBuildNumber {
    (Get-CimInstance Win32_OperatingSystem).BuildNumber
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

function Get-OSRegisteredOrganization {
    (Get-CimInstance Win32_OperatingSystem).Organization
}

function Get-OSRegisteredUser {
    (Get-CimInstance Win32_OperatingSystem).RegisteredUser
}

function Get-OSVersion {
    (Get-CimInstance Win32_OperatingSystem).Version
}

function Install-WindowsUpdates {
    $session = New-Object -ComObject 'Microsoft.Update.Session'
    $searcher = $session.CreateUpdateSearcher()
    $search = 'IsInstalled = 0'

    Write-Output "Looking for Windows Updates..."

    $results = $searcher.Search($search)
    $updates = $results.Updates
    $numberUpdates = 1
    $updateCount = $updates.Count

    if ($updateCount -gt 0) {
        Write-Output "The following updates will be attempted:"

        ($updates | Select-Object Title).Title | ForEach-Object { Write-Output "  --> $_" }

        Write-Output " "

        $collectionDownload = New-Object -ComObject 'Microsoft.Update.UpdateColl';

        Write-Output "Downloading:"
        foreach ($update in $updates) {
            Write-Output "  --> [$numberUpdates/$updateCount]: $($update.Title)"

            $update.AcceptEula();
            $tempCollection = New-Object -ComObject 'Microsoft.Update.UpdateColl'
            $tempCollection.Add($Update) | Out-Null

            $Downloader = $session.CreateUpdateDownloader()
            $Downloader.Updates = $tempCollection

            try {
                $downloadResult = $downloader.Download()
            } catch {
                if ($_ -match 'HRESULT: 0x80240044') {
                    Write-Warning 'Your security policy do not allow a non-administator identity to perform this task';
                }

                return
            }

            if ($downloadResult.ResultCode -eq 2) {
                $collectionDownload.Add($Update) | Out-Null;
            } else {
                Write-Warning "Error downloading update: $($downloadResult.ResultCode)"
            }

            $numberUpdates++;
        }

        $readyToInstall = $collectionDownload.count;
        $needReboot = $false;

        if ($readyToInstall -gt 0) {
            Write-Output "`nDownloaded $readyToInstall updates."

            $numberUpdates = 1;

            Write-Output "`nInstalling:"
            foreach ($update in $collectionDownload) {
                Write-Output "  --> [$numberUpdates/$readyToInstall] $($update.Title)"

                $tempCollection = New-Object -ComObject 'Microsoft.Update.UpdateColl'
                $tempCollection.Add($Update) | Out-Null

                $installer = $session.CreateUpdateInstaller()
                $installer.Updates = $tempCollection

                try {
                    $installResult = $installer.Install()
                } catch {
                    if ($_ -match 'HRESULT: 0x80240044') {
                        Write-Warning `
                            'Your security policy do not allow a non-administator identity to perform this task'
                    }

                    return;
                }

                if (!$needReboot) {
                    $needReboot = $installResult.RebootRequired;
                }

                $numberUpdates++;
            }

            if ($needReboot) {
                Write-Output "`n`nA reboot is required to finish the update process.`n"
            }
        }
    }
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

function Test-EnvironmentVariable {
    param (
        [string]$Name
    )

    return Test-Path env:$Name
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
