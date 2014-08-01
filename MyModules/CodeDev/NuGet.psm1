$script:NuGetUrl = ''
$script:NuGetApi = ''

Function Get-DevPath {
    $cmd = "path-dev.bat & set PATH"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        if ($p.ToLower() -eq 'path') {
        $a = $v.IndexOf('development;')
        $b = $v.LastIndexOf(';', $a)
        if ($b -eq -1) { $b = 0 }
        $devt = $v.Substring($b, $a + 11)
        }
    }
    
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

Function Get-NuGetProfile {
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

Export-ModuleMember Clear-NuGetProfile
Export-ModuleMember Get-NuGetProfile

Set-Alias nuget-profile-clear Clear-NuGetProfile
Set-Alias nuget-profile-load Get-NuGetProfile
Set-Alias Load-NuGetProfile Get-NuGetProfile

Export-ModuleMember -Alias nuget-profile-clear
Export-ModuleMember -Alias nuget-profile-load
Export-ModuleMember -Alias Load-NuGetProfile
