Function Find-ChocolateyUpgradablePackages {
    Write-Host "Examining Installed Packages..."
    $installed = choco.exe list -localonly

    foreach ($line in $installed) {
        if ($line -match '\d+\.\d+') {
            $package = $line.split(' ')[0]
            $output = "Checking $package... "
            Write-Host $output -NoNewline

            $cver = choco.exe version $package
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
    
    $packages | ForEach-Object { $_.split('\.')[0] } | Sort-Object -unique
}

Function Update-ChocolateyPackage {
    Param (
        [string]$source='',
        [alias("ia","installArgs")][string] $installArguments = '',
        [parameter(Mandatory=$true, Position=1, ValueFromRemainingArguments=$true)]
        [string[]] $packageNames=@('')
    )

    if (Test-Elevation) {
        $choco = "${env:ChocolateyInstall}\chocolateyInstall\chocolatey.ps1"
        $args = "$packageNames"

        if ($source.Length -gt 0) {
            $args = $args + " -source $source"
        }

        if ($installArguments.Length -gt 0) {
            $args = $args + " -installArguments $installArguments"
        }

        & $choco update $args
    }
}

Function Install-ChocolateyPackage {
    Param (
        [string]$source='',
        [string]$version='',
        [alias("ia","installArgs")][string] $installArguments = '',
        [parameter(Mandatory=$true, Position=1, ValueFromRemainingArguments=$true)]
        [string[]] $packageNames=@('')
    )

    if (Test-Elevation) {
        $choco = "${env:ChocolateyInstall}\chocolateyInstall\chocolatey.ps1"
        $args = "$packageNames"

        if ($version.Length -gt 0) {
            $args = $args + " -version $version"
        }

        if ($source.Length -gt 0) {
            $args = $args + " -source $source"
        }

        if ($installArguments.Length -gt 0) {
            $args = $args + " -installArguments $installArguments"
        }

        & $choco install $args
    }
}

Function Uninstall-ChocolateyPackage {
    Param (
        [string]$version='',
        [alias("ia","installArgs")][string] $installArguments = '',
        [parameter(Mandatory=$true, Position=1, ValueFromRemainingArguments=$true)]
        [string[]] $packageNames=@('')
    )

    if (Test-Elevation) {
        $choco = "${env:ChocolateyInstall}\chocolateyInstall\chocolatey.ps1"
        $args = "$packageNames"

        if ($version.Length -gt 0) {
            $args = $args + " -version $version"
        }

        if ($installArguments.Length -gt 0) {
            $args = $args + " -installArguments $installArguments"
        }

        & $choco uninstall $args
    }
}

Function Upgrade-Chocolatey {
    $url = 'https://chocolatey.org/install.ps1'
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url))

    $config = Get-Content "C:\ProgramData\chocolatey\chocolateyinstall\chocolatey.config"
    $config = $config -replace '<ksMessage>true</ksMessage>', '<ksMessage>false</ksMessage>' 
    $config | Out-File "C:\ProgramData\chocolatey\chocolateyinstall\chocolatey.config"

    cmd /c "icacls.exe ${env:ALLUSERSPROFILE}\chocolatey /grant Everyone:(OI)(CI)F /T"

    if (-not ($env:Path -contains "chocolatey")) {
        $env:Path = $env:path + ";${env:ALLUSERSPROFILE}\chocolatey\bin"
        setx /m PATH $env:PATH
    }

    choco.exe sources add -name dcjulian29 -source 'https://www.myget.org/F/dcjulian29-chocolatey'
    choco.exe sources disable -name chocolatey
}

Function Add-ChocolateyToPath {
    $chocolateyPath = "C:\ProgramData\chocolatey\bin"

    $path = "${env:Path};$chocolateyPath"

    $env:Path = $path
    setx.exe /m PATH $path
}

###################################################################################################

Export-ModuleMember Find-ChocolateyUpgradablePackages
Export-ModuleMember Find-ChocolateyInstalledPackages
Export-ModuleMember Update-ChocolateyPackage
Export-ModuleMember Install-ChocolateyPackage
Export-ModuleMember Uninstall-ChocolateyPackage
Export-ModuleMember Upgrade-Chocolatey
Export-ModuleMember Add-ChocolateyToPath
