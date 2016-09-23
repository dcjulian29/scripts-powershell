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
            "4.5.2" { $release = "379893" }
            "4.6"   { $release = "393295 393297" }
            "4.6.1" { $release = "393295 394271" }
            "4.6.2" { $release = "394802 394806" }

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

Function Test-NetFramework452
{
    Test-NetFramework45AndUp -Version "4.5.2"
}

Function Test-NetFramework46
{
    Test-NetFramework45AndUp -Version "4.6"
}

Function Test-NetFramework461
{
    Test-NetFramework45AndUp -Version "4.6.1"
}

Function Test-NetFramework462
{
    Test-NetFramework45AndUp -Version "4.6.2"
}

Function Test-NetFrameworks
{
    $versions = ""

    if (Test-NetFramework2) { $versions = $versions + "2.0," }
    if (Test-NetFramework3) { $versions = $versions + "3.0," }
    if (Test-NetFramework35) { $versions = $versions + "3.5," }
    if (Test-NetFramework40) { $versions = $versions + "4.0," }
    if (Test-NetFramework45) { $versions = $versions + "4.5," }
    if (Test-NetFramework451) { $versions = $versions + "4.5.1," }
    if (Test-NetFramework452) { $versions = $versions + "4.5.2," }
    if (Test-NetFramework46) { $versions = $versions + "4.6," }
    if (Test-NetFramework461) { $versions = $versions + "4.6.1," }
    if (Test-NetFramework462) { $versions = $versions + "4.6.2," }

    return $versions.Split(',', [StringSplitOptions]::RemoveEmptyEntries)
}

Function Get-AssemblyInfo {
    param (
        $assembly = $(throw “An assembly name is required.”)
    )
    
    if (test-path $assembly) {
        $assemblyPath = Get-Item $assembly
        $loadedAssembly = [System.Reflection.Assembly]::LoadFrom($assemblyPath)
    } else {
        # Load from GAC
        $loadedAssembly = [System.Reflection.Assembly]::LoadWithPartialName("$assembly")
    }

    $name = $loadedAssembly.GetName().name
    $version =  $loadedAssembly.GetName().version

    "{0} [{1}]" -f $name, $version
}

Function Get-AllAssemblyInfo {
    Get-ChildItem | Where-Object { $_.Extension -eq ".dll" } | foreach { Get-AssemblyInfo $_ }
}

###################################################################################################

Export-ModuleMember Test-NetFramework2
Export-ModuleMember Test-NetFramework3
Export-ModuleMember Test-NetFramework35
Export-ModuleMember Test-NetFramework40
Export-ModuleMember Test-NetFramework45
Export-ModuleMember Test-NetFramework451
Export-ModuleMember Test-NetFramework452
Export-ModuleMember Test-NetFramework46
Export-ModuleMember Test-NetFramework461
Export-ModuleMember Test-NetFramework462
Export-ModuleMember Test-NetFrameworks
Export-ModuleMember Get-AssemblyInfo
Export-ModuleMember Get-AllAssemblyInfo

Set-Alias aia Get-AllAssemblyInfo
Export-ModuleMember -Alias aia
