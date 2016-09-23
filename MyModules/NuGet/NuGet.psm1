$script:NuGetUrl = ''
$script:NuGetApi = ''

Function Get-DevPath {
    $a = $($env:Path).IndexOf('development;')
    $b = $($env:Path).LastIndexOf(';', $a)

    if ($b -eq -1) { $b = 0 }

    $devt = $($env:Path).Substring($b, $a + 11)
    
    Write-Verbose "Development Script Directory is $devt"

    if ($devt.Length -eq 0) {
        Write-Error "Could not determine development tools directory."
    }
    
    return $devt
}

Function Initialize-NuGetProfileSettings {
    param (
        $ProfileName= $(Write-Error “An NuGet profile name is required.”)
    )
    
    $OriginalProfile = ${env:'NUGET-PROFILE'}
  
    Get-NuGetProfile $ProfileName

    $devt = Get-DevPath

    $cmd = "call `"$devt\_nuget_LoadSettings.cmd`" NO $ProfileName & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        if ($p -eq 'NUGET-URL') {
            $script:NuGetUrl = $v
        }
        if ($p -eq 'NUGET-API') {
            $script:NuGetApi = $v
        }
    }

    Clear-NuGetProfile
    if ($OriginalProfile.Length -gt 0) {
        ${env:'NUGET-PROFILE'} = $OriginalProfile
    }
}

Function Clear-NuGetProfile {
  Remove-Item -path env:NUGET-PROFILE
}

Function Load-NuGetProfile {
    param (
        $ProfileName= $(Write-Error “An NuGet profile name is required.”)
    )

    if ($ProfileName.Length -gt 0) {
        $devt = Get-DevPath

        $cmd = "`"$devt\nuget-profile-load.bat`" $ProfileName & set"

        $profileFound = $false

        cmd /c $cmd | Foreach-Object {
            $p, $v = $_.split('=')
            if ($p -eq 'NUGET-PROFILE') {
                Set-Item -path env:$p -value $v
                $profileFound = $true
            }
        }
      
        if (-not $profileFound) {
            Write-Error "The NuGet profile does not exist."
        }
    }
}

Function Restore-NugetPackages {
    Invoke-Nuget restore $args
}

Function Invoke-Nuget {
    & "C:\tools\apps\nuget\nuget.exe" $args
}

###################################################################################################

Export-ModuleMember Clear-NuGetProfile
Export-ModuleMember Load-NuGetProfile
Export-ModuleMember Restore-NugetPackages
Export-ModuleMember Invoke-Nuget

Set-Alias nuget-profile-clear Clear-NuGetProfile
Export-ModuleMember -Alias nuget-profile-clear

Set-Alias nuget-profile-load Load-NuGetProfile
Export-ModuleMember -Alias nuget-profile-load

Set-Alias nuget Invoke-Nuget
Export-ModuleMember -Alias nuget
