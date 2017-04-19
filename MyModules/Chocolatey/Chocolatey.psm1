Function Find-UpgradableChocolateyPackages {
    Write-Host "Examining Installed Packages..."
    $packages = choco.exe upgrade all -r -whatif

    foreach ($package in $packages) {
        $Name = $package.Split('|')[0]
        $localVersion = $package.Split('|')[1]
        $remoteVersion = $package.Split('|')[2]

        if ($localVersion -ne $remoteVersion) {
            "{0,-25}Newer version available: $remoteVersion (installed: $localVersion)" -f $Name
        }
    }
}

Function Find-InstalledChocolateyPackages {
    $packages = (Get-ChildItem "$($env:ChocolateyInstall)\lib" | Select-Object basename).basename 
    
    $packages | ForEach-Object { $_.split('|')[0] } | Sort-Object -unique
}


Function Update-AllChocolateyPackages {
    if (Assert-Elevation) {
        Invoke-Expression "choco.exe upgrade all -y"
    }
}

Function Update-ChocolateyPackage {
    Param (
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

Function Install-ChocolateyPackage {
    Param (
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

Function Uninstall-ChocolateyPackage {
    Param (
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

Function Add-ChocolateyToPath {
    $chocolateyPath = "C:\ProgramData\chocolatey\bin"

    $path = "${env:Path};$chocolateyPath"

    $env:Path = $path
    setx.exe /m PATH $path
}

Function Make-ChocolateyPackage {
    Param (
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $NuspecFile = "package.nuspec"
    )

    $nuget = "C:\ProgramData\chocolatey\lib\NuGet.CommandLine\tools\nuget.exe"
    $options = "-Verbosity detailed -NoPackageAnalysis -NonInteractive -NoDefaultExcludes"

    Invoke-Expression "$nuget pack ""$NuspecFile"" $options"
}

###################################################################################################

Export-ModuleMember Find-UpgradableChocolateyPackages
Export-ModuleMember Find-InstalledChocolateyPackages
Export-ModuleMember Update-AllChocolateyPackages
Export-ModuleMember Update-ChocolateyPackage
Export-ModuleMember Install-ChocolateyPackage
Export-ModuleMember Uninstall-ChocolateyPackage

Set-Alias chocoupdate Update-ChocolateyPackage
Export-ModuleMember -Alias chocoupdate

Export-ModuleMember Make-ChocolateyPackage

Set-Alias choco-make-package Make-ChocolateyPackage
Export-ModuleMember -Alias choco-make-package
