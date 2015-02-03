Function Find-UpgradableChocolateyPackages {
    Write-Host "Examining Installed Packages..."
    $installed = choco.exe list -localonly
    $available = choco.exe list

    foreach ($line in $installed) {
        if ($line -match '\d+\.\d+') {
            $package = $line.split(' ')[0]
            $output = "Checking $package... "
            Write-Host $output -NoNewline

            $localVersion = $line.Split(' ')[1]
            
            $remotePackage = $available -match "^$package\W"

            if ($remotePackage) {
                $remoteVersion = ($remotePackage).Split(' ')[1]
            }

            if ($remoteVersion) {
                if ($localVersion -ne $remoteVersion) {
                    Write-Host "newer version available: $remoteVersion (installed: $localVersion)" -ForegroundColor Yellow
                } else {
                    Write-Host ("`b" * $output.length) -NoNewline
                    Write-Host (" " * $output.length) -NoNewline
                    Write-Host ("`b" * $output.length) -NoNewline
                }
            }
        }
    }
}

Function Find-InstalledChocolateyPackages {
    $packages = (Get-ChildItem "$($env:ChocolateyInstall)\lib" | Select-Object basename).basename 
    
    $packages | ForEach-Object { $_.split('\.')[0] } | Sort-Object -unique
}

Function Find-AvailableChocolateyPackages {
    $installed = choco.exe list -localonly | ForEach-Object { $_.split(' ')[0] }
    $online = choco.exe list | ForEach-Object { $_.split(' ')[0] }
    $combined = $installed + $online | Sort-Object

    $available = $combined | Group-Object | Where-Object { $_.Count -eq 1 } | Select-Object Name

    return $available
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
    if (Test-Elevation) {
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
}

Function Add-ChocolateyToPath {
    $chocolateyPath = "C:\ProgramData\chocolatey\bin"

    $path = "${env:Path};$chocolateyPath"

    $env:Path = $path
    setx.exe /m PATH $path
}

###################################################################################################

Export-ModuleMember Find-UpgradableChocolateyPackages
Export-ModuleMember Find-InstalledChocolateyPackages
Export-ModuleMember Find-AvailableChocolateyPackages
Export-ModuleMember Update-ChocolateyPackage
Export-ModuleMember Install-ChocolateyPackage
Export-ModuleMember Uninstall-ChocolateyPackage
Export-ModuleMember Upgrade-Chocolatey
Export-ModuleMember Add-ChocolateyToPath
