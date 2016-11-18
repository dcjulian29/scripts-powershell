$script:NuGetUrl = ''
$script:NuGetApi = ''

Function Clear-NuGetProfile {
    $script:NuGetUrl = ''
    $script:NuGetApi = ''
}

Function Load-NuGetProfile {
    param (
        [string]$ProfileName = $(Read-Host "Enter the Nuget Profile")
    )
    
    $profileFile = Join-Path -Path "$($env:SystemDrive)/etc/nuget" -ChildPath "$ProfileName.json"

    if (-not (Test-Path $profileFile)) {
        Write-Error "Nuget Profile does not exist!"
    } else {
        $json = Get-Content -Raw -Path $profileFile | ConvertFrom-Json

        $script:NuGetUrl = $json.Url
        $script:NuGetApi = $json.Api
    }
}

Function Restore-NugetPackages {
    Invoke-Nuget restore $args
}

Function Invoke-Nuget {
    & "C:\tools\apps\nuget\nuget.exe" $args
}

Function Purge-NugetPackagesFromCache {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]        
        [int]$Age
    )

    $cache = "${env:LOCALAPPDATA}\NuGet\Cache"
    $filter = "*.nupkg"

    Purge-Files -Folder $cache -Filter $filter -Age $Age
}

Function Purge-AllNugetPackagesFromCache {
    Purge-NugetPackages -Age 0
}

Function Purge-AllNugetPackages {
    Get-ChildItem *.nupkg -recurse | Remove-Item -Verbose
}

Function Create-NugetPackage {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ })]
        [String]$NugetPackage
    )

    Invoke-Nuget pack $NugetPackage -Verbosity detailed
}

Function Push-NugetPackage {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ })]
        [String]$NugetSpec
    )

    if ($script:NuGetUrl -eq '') {
        Write-Error "A Nuget profile is not loaded."
        return
    }

    Invoke-Nuget push $NugetSpec $script:NuGetApi -Source $script:NuGetUrl
}

###################################################################################################

Export-ModuleMember Clear-NuGetProfile
Export-ModuleMember Load-NuGetProfile
Export-ModuleMember Restore-NugetPackages
Export-ModuleMember Invoke-Nuget
Export-ModuleMember Purge-NugetPackagesFromCache
Export-ModuleMember Purge-AllNugetPackagesFromCache
Export-ModuleMember Purge-AllNugetPackages
Export-ModuleMember Create-NugetPackage
Export-ModuleMember Push-NugetPackage

Set-Alias nuget-profile-clear Clear-NuGetProfile
Export-ModuleMember -Alias nuget-profile-clear

Set-Alias nuget-profile-load Load-NuGetProfile
Export-ModuleMember -Alias nuget-profile-load

Set-Alias nuget Invoke-Nuget
Export-ModuleMember -Alias nuget

Set-Alias nuget-package-clean Purge-AllNugetPackages
Export-ModuleMember -Alias nuget-package-clean

Set-Alias nuget-make-package Create-NugetPackage
Export-ModuleMember -Alias nuget-make-package

Set-Alias nuget-publish Push-NugetPackage
Export-ModuleMember -Alias nuget-publish
