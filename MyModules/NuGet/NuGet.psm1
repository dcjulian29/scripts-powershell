$script:NuGetUrl = ''
$script:NuGetApi = ''

function Clear-NuGetProfile {
    $script:NuGetUrl = ''
    $script:NuGetApi = ''
}

Set-Alias nuget-profile-clear Clear-NuGetProfile

function Get-NuGetMetadata {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ })]
        [String]$NuGetPackage
    )

    [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null

    try {
        $zipFile = [System.IO.Compression.ZipFile]::OpenRead($NuGetPackage)
        $entry = ($zipFile.Entries | Where-Object { $_.FullName.EndsWith(".nuspec") }).Open()
        $reader = New-Object System.IO.StreamReader($entry)
        $nuspec = [xml] ($reader.ReadToEnd())
    }
    catch [System.IO.InvalidDataException] {
        Write-Error "'$NuGetPackage' is not a vaild NuGet file!"
    }
    catch {
        Write-Error $_
    }
    finally {
        if ($zipFile) { $zipFile.Dispose() }
    }

    return $nuspec.package.metadata
}

Set-Alias -Name nuget-metadata -Value Get-NuGetMetadata

function New-NuGetPackage {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ })]
        [String]$NuGetPackage
    )

    Invoke-NuGet pack $NuGetPackage -Verbosity detailed
}

Set-Alias Create-NuGetPackage New-NuGetPackage
Set-Alias nuget-make-package New-NuGetPackage

function Find-NuGet {
    First-Path `
        "$env:ALLUSERSPROFILE\chocolatey\lib\NuGet.CommandLine\tools\nuget.exe" `
        "$env:ALLUSERSPROFILE\chocolatey\bin\NuGet.exe"
}

function Import-NuGetProfile {
    param (
        [string]$ProfileName = $(Read-Host "Enter the NuGet Profile")
    )

    $profileFile = Join-Path -Path "$($env:SystemDrive)/etc/nuget" -ChildPath "$ProfileName.json"

    if (-not (Test-Path $profileFile)) {
        Write-Error "NuGet Profile does not exist!"
    } else {
        $json = Get-Content -Raw -Path $profileFile | ConvertFrom-Json

        $script:NuGetUrl = $json.Url
        $script:NuGetApi = $json.Api
    }
}

Set-Alias Load-NuGetProfile Import-NuGetProfile
Set-Alias nuget-profile-load Import-NuGetProfile

function Invoke-NuGet {
    cmd /c "$(Find-NuGet) $args"
}

function Push-NuGetPackage {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ })]
        [String]$NuGetSpec
    )

    if ($script:NuGetUrl -eq '') {
        Write-Error "A NuGet profile is not loaded."
        return
    }

    Invoke-NuGet push $NuGetSpec $script:NuGetApi -Source $script:NuGetUrl
}

Set-Alias nuget-publish Push-NuGetPackage

function Remove-AllNuGetPackages {
    Get-ChildItem *.nupkg -recurse | Remove-Item -Verbose
}

Set-Alias Purge-AllNuGetPackage Remove-AllNuGetPackages
Set-Alias nuget-package-clean Remove-AllNuGetPackages

function Remove-AllNuGetPackagesFromCache {
    Remove-NuGetPackagesFromCache -Age 0
}

Set-Alias Purge-AllNugetPackagesFromCache Remove-AllNuGetPackagesFromCache

function Remove-NuGetPackagesFromCache {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int]$Age
    )

    $cache = "${env:LOCALAPPDATA}\NuGet\Cache"
    $filter = "*.nupkg"

    Purge-Files -Folder $cache -Filter $filter -Age $Age
}

Set-Alias Purge-NuGetPackagesFromCache Remove-NuGetPackagesFromCache

function Restore-NuGetPackages {
    Invoke-NuGet restore $args
}
