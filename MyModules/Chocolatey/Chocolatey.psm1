function Find-InstalledChocolateyPackages {
    param (
        [switch] $NameOnly,
        [switch] $PassThru
    )

    $output = @()

    if ($NameOnly) {
        $packages = choco.exe list -r --local --id-only
        $line = @{Expression={$_.Name};Label="Name";width=40}
    } else {
        $packages = choco.exe list -r --local
        $line = @{Expression={$_.Name};Label="Name";width=40}, `
                @{Expression={$_.Version};Label="Installed Version";width=20}
    }

    foreach ($package in $packages) {
        $name = $package.Split('|')[0]
        $version = $package.Split('|')[1]

        if ($NameOnly) {
            $item = New-Object PSObject -Property @{
                'Name' = $name
            }
        } else {
            $item = New-Object PSObject -Property @{
                'Name' = $name
                'Version' = $version
            }
        }

        $output += $item
    }

    if ($PassThru) {
        return $output
    } else {
        $output | Format-Table $line
    }
}

function Find-UpgradableChocolateyPackages {
    param (
        [switch] $PassThru
    )

    Write-Host "Examining Installed Packages..."
    $packages = choco.exe upgrade all -r -whatif -y

    $output = @()

    foreach ($package in $packages) {
        if ($package -notlike "*|*") {
            continue
        }

        $Name = $package.Split('|')[0]
        $localVersion = $package.Split('|')[1]
        $remoteVersion = $package.Split('|')[2]

        if ($localVersion -ne $remoteVersion) {
            $item = New-Object PSObject -Property @{
                'Name' = $Name
                'RemoteVersion' = $remoteVersion
                'LocalVersion' = $localVersion
            }

            $output += $item
        }
    }

    if ($PassThru) {
        return $output
    } else {
        $line = @{Expression={$_.Name};Label="Name";width=40}, `
                @{Expression={$_.LocalVersion};Label="Installed Version";width=20}, `
                @{Expression={$_.RemoteVersion};Label="New Version";width=20}

        $output | Format-Table $line
    }
}

function Install-ChocolateyPackage {
    param (
        [string]$version,
        [alias("ia","installArgs")][string] $installArguments,
        [parameter(Mandatory=$true, Position=1)]
        [string] $package
    )

    if (Assert-Elevation) {
        if ($version.Length) {
            $args = $args + " -version $version"
        }

        if ($installArguments) {
            $args = $args + " -installArguments $installArguments"
        }

        Invoke-Expression "choco.exe install $package$args -y"
    }
}

function New-ChocolateyPackage {
    param (
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $NuspecFile = "package.nuspec"
    )

    $options = "-Verbosity detailed -NoPackageAnalysis -NonInteractive -NoDefaultExcludes"

    Invoke-Expression "nuget.exe pack ""$NuspecFile"" $options"
}

Set-Alias choco-make-package Make-ChocolateyPackage
Set-Alias Make-ChocolateyPackage New-ChocolateyPackage

function Restore-ChocolateyCache {
    param (
        [string]$PackageList = "$env:SystemDrive\etc\choco-package-cache\packages.json",
        [string]$Destination = "$env:SystemDrive\etc\choco-package-cache",
        [string]$Config = "$env:SystemDrive\etc\choco-package-cache\nuget.config",
        [switch]$Reset
    )

    Start-Transcript -Path $(Get-LogFileName "Cache-ChocolateyPackages")

    $chocoCache = "$env:TEMP\choco-cache"

    if (Test-Path $chocoCache) {
        Remove-Item $chocoCache -Recurse -Force
    }

    New-Item $chocoCache -ItemType Directory | Out-Null

    if ($Reset) {
        if (Test-Path $Destination) {
            Get-Childitem -Filter "*.nupkg" -Path $Destination -Recurse | Remove-Item -Force
        }
    }

    (Get-Content -Raw -Path $PackageList | ConvertFrom-Json).Packages | ForEach-Object {
        Write-Output " "
        Write-Output "===================================================> $_"
        Write-Output " "

        $nuget = "install $_ -NonInteractive -OutputDirectory $chocoCache " + `
            "-ConfigFile ""$Config"" -Verbosity Detailed -DependencyVersion Highest"

        Invoke-Nuget $nuget

        Get-Childitem -Filter "*.nupkg" -Path $chocoCache -Recurse | ForEach-Object {
            if (-not (Test-Path "$Destination\$($_.Name)")) {
                Copy-Item -Path $_.FullName -Destination $Destination
            } else {
                $sourceHash = Get-Sha256 -File "$($_.FullName)"
                $destinationHash = Get-Sha256 -File "$Destination\$($_.Name)"
                if ($sourceHash -ne $destinationHash) {
                    Copy-Item -Path $_.FullName -Destination $Destination -Force
                }
            }
        }
    }

    Remove-Item $chocoCache -Recurse -Force

    Stop-Transcript
}

function Uninstall-ChocolateyPackage {
    param (
        [string]$version,
        [alias("ia","installArgs")][string] $installArguments,
        [parameter(Mandatory=$true, Position=1)]
        [string] $package
    )

    if (Assert-Elevation) {
        if ($version) {
            $args = $args + " -version $version"
        }

        if ($installArguments) {
            $args = $args + " -installArguments $installArguments"
        }

        Invoke-Expression "choco.exe uninstall $package$args -y"
    }
}

function Update-AllChocolateyPackages {
    Start-Transcript -Path $(Get-LogFileName "Update-AllChocolateyPackages")

    $packages = Find-UpgradableChocolateyPackages -PassThru

    foreach ($package in $packages) {
        if ($package.LocalVersion -ne $package.RemoteVersion) {
            Write-Output "  - Adding $($package.Name) to upgrade queue."
            $updatePackages += "$($package.Name) "
        }
    }

    if ($updatePackages.Length -gt 0) {
        if (Assert-Elevation) {
            Invoke-Expression "choco.exe upgrade $updatePackages -y"
        }
    } else {
        Write-Output "  - All Chocolatey packages are up-to-date."
    }

    Stop-Transcript
}

Set-Alias Upgrade-AllChocolateyPackage Update-AllChocolateyPackages

function Update-ChocolateyPackage {
    param (
        [alias("ia","installArgs")][string] $installArguments,
        [parameter(Mandatory=$true, Position=1)]
        [string] $package
    )

    if (Assert-Elevation) {
        if ($installArguments) {
            $args = " -installArguments $installArguments"
        }

        Invoke-Expression "choco.exe upgrade $package$args -y"
    }
}

Set-Alias chocoupdate Update-ChocolateyPackage
Set-Alias Upgrade-ChocolateyPackage Update-ChocolateyPackage
