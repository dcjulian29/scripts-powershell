function Get-AllAssemblyInfo {
    Get-ChildItem `
        | Where-Object { $_.Extension -eq ".dll" } `
        | ForEach-Object { Get-AssemblyInfo $_ }
}

Set-Alias aia Get-AllAssemblyInfo

function Get-AssemblyInfo {
    param (
        $Assembly = $(throw "An assembly name is required.")
    )


    if (Test-Path $Assembly) {
        $loaded = [System.Reflection.Assembly]::LoadFrom($(Get-Item $Assembly))
    } else {
        # Load from GAC
        $loaded = [System.Reflection.Assembly]::LoadWithPartialName("$Assembly")
    }

    "{0} [{1}]" -f $loaded.GetName().name, $loaded.GetName().version
}

function Get-NetFramework
{
    $versions = @(
        "2.0"
        "3.0"
        "3.5"
        "4.0"
        "4.5"
        "4.5.1"
        "4.5.2"
        "4.6"
        "4.6.1"
        "4.6.2"
        "4.7"
        "4.7.1"
        "4.7.2"
        "4.8"
    )

    $installed = @()

    foreach ($version in $versions) {
        if (Test-NetFramework -Version $version) {
            $installed += $version
        }
    }

    return $installed.Join(',')
}

function Test-NetFramework
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Version
    )
    $major = [int]$version.Split('.')[0]
    $path = 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\'

    switch ($major) {
        @(2, 3) {
            switch ($version) {
                "2.0" { $path = "$path\v2.0.50727" }
                "3.0" { $path = "$path\v3.0" }
                "3.5" { $path = "$path\v3.5" }
                default { return $False }
            }

            if (Test-Path $path) {
                if (Get-ItemProperty $path -Name Install -ErrorAction SilentlyContinue) {
                    return $True
                }
            }

            return $False
        }

        4 {
            $path = "$path\v4\Full"
            switch ($version) {
                "4.5"   { $release = "378389 378675 378758" }
                "4.5.1" { $release = "378675 378758" }
                "4.5.2" { $release = "379893" }
                "4.6"   { $release = "393295 393297" }
                "4.6.1" { $release = "394254 394271" }
                "4.6.2" { $release = "394802 394806" }
                "4.7"   { $release = "460798 460805" }
                "4.7.1" { $release = "461308 461310" }
                "4.7.2" { $release = "461808 461814" }
                "4.8"   { $release = "528040 528209 528049" }
                default { return $False }
            }

            $installed = (Get-ItemProperty $path -Name Release -ErrorAction SilentlyContinue).Release

            if ($release.Contains($installed)) {
                return $True
            }

            return $False

        }

        default {
            return $False
        }
    }
}

function Test-NetFramework2 { Test-NetFramework -Version "2.0" }

function Test-NetFramework3 { Test-NetFramework -Version "3.0" }

function Test-NetFramework35 { Test-NetFramework -Version "3.5" }

function Test-NetFramework40 { Test-NetFramework -Version "4.0" }

function Test-NetFramework45 { Test-NetFramework -Version "4.5" }

function Test-NetFramework451 { Test-NetFramework -Version "4.5.1" }

function Test-NetFramework452 { Test-NetFramework -Version "4.5.2" }

function Test-NetFramework46 { Test-NetFramework -Version "4.6" }

function Test-NetFramework461 { Test-NetFramework -Version "4.6.1" }

function Test-NetFramework462 { Test-NetFramework -Version "4.6.2" }

function Test-NetFramework47 { Test-NetFramework -Version "4.7" }

function Test-NetFramework471 { Test-NetFramework -Version "4.7.1" }

function Test-NetFramework472 { Test-NetFramework -Version "4.7.2" }

function Test-NetFramework48 { Test-NetFramework -Version "4.8" }
