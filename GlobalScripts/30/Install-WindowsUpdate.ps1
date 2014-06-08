Function Install-WindowsUpdate
{
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($CurrentUser)
    if (-not ($principal.IsInRole("Administrators"))) {
        throw "You must be an administrator running an elevated shell."
    }

    $session = New-Object -comobject "Microsoft.Update.Session"
    $searcher = $session.CreateUpdateSearcher()
    $result = $searcher.Search("IsInstalled=0 and Type='Software'")

    if ($result.updates.count -ne 0) {
        Write-Output "Found $($result.updates.count) update(s)..."

        $downloader = $session.CreateUpdateDownloader()
        $updatesToDownload = New-Object -com "Microsoft.Update.UpdateColl"

        foreach ($update in $result.updates) {
            if (-not ($update.title -match "Bing")) {
                Write-Output " * $($update.title)"
                if (-not $update.isDownloaded) {
                    $updatesToDownload.add($update) | Out-Null
                }
            } else {
	    	Write-Output " # $($update.title)"
	    }
        }

        if ($updatesToDownload.Count -gt 0) {
            $downloader.Updates = $updatesToDownload
            $downloader.Download() | Out-Null
        }

        $installer = $session.CreateUpdateInstaller()
        $updatesToInstall = New-object -com "Microsoft.Update.UpdateColl"

        foreach ($update in $result.updates) {
            if (-not ($update.title -match "Bing")) {
                $updatesToinstall.add($update) | Out-Null
            }
        }

        if ($updatesToInstall.Count -gt 0) {
            $installer.updates = $UpdatesToInstall
            $result = $Installer.Install()

            if($result.rebootRequired) {
                Write-Warning "Restart required to finish installing updates."
            }
        } else {
            Write-Output "There are no installable updates for this computer."
	}
    } else {
        Write-Output "There are no applicable updates for this computer."
    }
}
