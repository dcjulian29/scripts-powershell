Function Find-ChocolateyUpgradablePackages {
    Write-Host "Examining Installed Packages..."
    $installed = clist -localonly

    foreach ($line in $installed) {
        if ($line -match '\d+\.\d+') {
            $package = $line.split(' ')[0]
            $output = "Checking $package... "
            Write-Host $output -NoNewline

            $cver = cver $package
            foreach ($ver in $cver) {
                if ($ver -match 'found.*:') {
                    if (-not ($ver -like "foundCompare*")) {
                        $found = $ver.split(':')[1]
                    }
                }

                if ($ver -match 'latest\s+:') {
                    if (-not ($ver -like "latestCompare*")) {
                        $latest = $ver.split(':')[1]
                    }
                }
            }
        
            if ($found -ne $latest) {
                Write-Host "newer version available: $latest" -ForegroundColor Yellow
            } else {
                Write-Host ("`b" * $output.length) -NoNewline
                Write-Host (" " * $output.length) -NoNewline
                Write-Host ("`b" * $output.length) -NoNewline
            }
        }
    }
}

Function Find-ChocolateyInstalledPackages {
    $packages = (Get-ChildItem "$($env:ChocolateyInstall)\lib" | Select-Object basename).basename 
    
    $packages | ForEach-Object {'cinst ' + $_.split('\.')[0]} | Sort-Object -unique
}
###################################################################################################

Export-ModuleMember Find-ChocolateyUpgradablePackages
Export-ModuleMember Find-ChocolateyInstalledPackages
