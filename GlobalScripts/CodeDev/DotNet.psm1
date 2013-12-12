Function Test-NetFramework1To4
{
    param ([string]$version)
    BEGIN { }
    PROCESS {
        $path = 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\'
        switch ($version) {
            "2.0" { $path = "$path\v2.0.50727" }
            "3.0" { $path = "$path\v3.0" }
            "3.5" { $path = "$path\v3.5" }
            "4.0" { $path = "$path\v4\Full" }
            default { return $False }
        }

        Write-Verbose "Checking Registry at $path"

        if (Test-PathReg -Path $path -Property Install) {
            if (Test-Path $path) {
                if (Get-ItemProperty $path -Name Install -ErrorAction SilentlyContinue) {
                    return $True
                }
            }
        }
      
        return $False
    }
    END { }
}

Function Test-NetFramework45AndUp
{
    param ([string]$version)
    BEGIN { }
    PROCESS {
        $path = 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
        switch ($version) {
            "4.5"   { $release = "378389 378675 378758" }
            "4.5.1" { $release = "378675 378758" }
            default { return $False }
        }

        Write-Verbose "Checking Registry at $path for $release"

        if (Test-PathReg -Path $path -Property Release) {
            $installed = (Get-ItemProperty $path -Name Release -ErrorAction SilentlyContinue).Release

            if ($release.Contains($installed)) {
                return $True
            }
        }
      
        return $False
    }
    END { }
}

Function Test-NetFramework2
{
    Test-NetFramework1To4 -Version "2.0"
}

Function Test-NetFramework3
{
    Test-NetFramework1To4 -Version "3.0"
}

Function Test-NetFramework35
{
    Test-NetFramework1To4 -Version "3.5"
}

Function Test-NetFramework40
{
    Test-NetFramework1To4 -Version "4.0"
}

Function Test-NetFramework45
{
    Test-NetFramework45AndUp -Version "4.5"
}

Function Test-NetFramework451
{
    Test-NetFramework45AndUp -Version "4.5.1"
}

Export-ModuleMember Test-NetFramework2
Export-ModuleMember Test-NetFramework3
Export-ModuleMember Test-NetFramework35
Export-ModuleMember Test-NetFramework40
Export-ModuleMember Test-NetFramework45
Export-ModuleMember Test-NetFramework451
