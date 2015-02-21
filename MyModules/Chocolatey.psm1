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
            
            $remotePackage = $available -match "^$package\s"

            if ($remotePackage.Length -gt 0) {
                $remoteVersion = ($remotePackage).Split(' ')[1]

                if ($remoteVersion) {
                    if ($localVersion -ne $remoteVersion) {
                        Write-Host "newer version available: $remoteVersion (installed: $localVersion)" -ForegroundColor Yellow
                    } else {
                        Write-Host ("`b" * $output.length) -NoNewline
                        Write-Host (" " * $output.length) -NoNewline
                        Write-Host ("`b" * $output.length) -NoNewline
                    }
                }
            } else {
                Write-Host "remote package removed." -ForegroundColor Red
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

Function Add-ChocolateyToPath {
    $chocolateyPath = "C:\ProgramData\chocolatey\bin"

    $path = "${env:Path};$chocolateyPath"

    $env:Path = $path
    setx.exe /m PATH $path
}

Function Purge-ObsoleteChocolateyPackages {
    $expression = "(?<name>[^\.]+)\.(?<major>\d+)\.(?<minor>\d+)\.?(?<revision>\d+)?\.?(?<patch>\d+)?"
    $packageDir = "${env:ChocolateyInstall}\lib"
    $packages = Get-ChildItem -Path $packageDir -Directory `
        | Sort-Object -Property `
            @{Expression={[RegEx]::Match($_.Name, $expression).Groups["name"].Value}}, `
            @{Expression={[int][RegEx]::Match($_.Name, $expression).Groups["major"].Value}}, `
            @{Expression={[int][RegEx]::Match($_.Name, $expression).Groups["minor"].Value}}, `
            @{Expression={[int][RegEx]::Match($_.Name, $expression).Groups["revision"].Value}}, `
            @{Expression={[int][RegEx]::Match($_.Name, $expression).Groups["patch"].Value}} `

    for ($i = 0; $i -lt $packages.Count - 1; $i++) {
        $this = $packages[$i].Name
        $next = $packages[$i + 1].Name

        $a = $this.IndexOf('.')
        $b = $next.IndexOf('.')

        $thisName = $this.Substring(0,$a)
        $nextName = $next.Substring(0,$b)

        $thisVersion = $this.Substring($a + 1)
        $nextVersion = $next.Substring($b + 1)

        if ($thisName -eq $nextName) {
            Write-Output "Purging $thisName : $thisVersion (< $nextVersion)"
            Remove-Item $packages[$i].FullName -Recurse -Force
        }
    }
}

###################################################################################################

Export-ModuleMember Find-UpgradableChocolateyPackages
Export-ModuleMember Find-InstalledChocolateyPackages
Export-ModuleMember Find-AvailableChocolateyPackages
Export-ModuleMember Update-ChocolateyPackage
Export-ModuleMember Install-ChocolateyPackage
Export-ModuleMember Uninstall-ChocolateyPackage
Export-ModuleMember Add-ChocolateyToPath
Export-ModuleMember Purge-ObsoleteChocolateyPackages
