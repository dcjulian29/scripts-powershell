$script:regexmatch = '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'

function Get-SemanticVersion {
    param (
        [string]$Version
    )

    if (-not (Test-SemanticVersion $Version)) {
        throw "'$Version' is not a semantic version."
    }

    $Version -match $script:regexmatch | Out-Null

    $detail = New-Object PSObject

    $detail | Add-Member -Type NoteProperty -Name 'Major' -Value $Matches[1]
    $detail | Add-Member -Type NoteProperty -Name 'Minor' -Value $Matches[2]
    $detail | Add-Member -Type NoteProperty -Name 'Patch' -Value $Matches[3]

    if ($Matches.Count -gt 3){
        $detail | Add-Member -Type NoteProperty -Name 'PreRelease' -Value $Matches[4]
    } else {
        $detail | Add-Member -Type NoteProperty -Name 'PreRelease' -Value $null
    }

    if ($Matches.Count -gt 4){
        $detail | Add-Member -Type NoteProperty -Name 'BuildMetaData' -Value $Matches[5]
    } else {
        $detail | Add-Member -Type NoteProperty -Name 'BuildMetaData' -Value $null
    }

    return $detail
}

Set-Alias -Name "Get-SemVer" -Value "Get-SemanticVersion"

function New-SemanticVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int] $Major,
        [Parameter(Mandatory = $true)]
        [int] $Minor,
        [Parameter(Mandatory = $true)]
        [int] $Patch,
        [string] $PreRelease,
        [string] $BuildMetaData
    )

    $version = "$Major.$Minor.$Patch"

    if ($PreRelease) {
        $version += "-$PreRelease"
    }

    if ($BuildMetaData) {
        $version += "+$BuildMetaData"
    }

    return $version
}

Set-Alias -Name "New-SemVer" -Value "New-SemanticVersion"

function Set-SemanticVersion {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$Version,
    [switch] $NextMajor,
    [switch] $NextMinor,
    [switch] $NextPatch,
    [string] $SetPreRelease,
    [string] $SetBuildMetaData
  )

  process {
    if (Test-SemanticVersion $version) {
      $semver = Get-SemanticVersion $version

      $major = $semver.Major
      $minor = $semver.Minor
      $patch = $semver.Patch
      $prerelease = $semver.PreRelease
      $buildmetadata = $semver.BuildMetaData

      if ($NextMajor) {
        $major = ([int]$major) + 1
        $minor = 0
        $patch = 0
      }

      if ($NextMinor) {
        $minor = ([int]$minor) + 1
        $patch = 0
      }

      if ($NextPatch) {
        $patch = ([int]$patch) + 1
      }

      if ($SetPreRelease) {
        $prerelease = $SetPreRelease
      }

      if ($SetBuildMetaData) {
        $buildmetadata = $SetBuildMetaData
      }

      New-SemanticVersion -Major $major -Minor $minor -Patch $patch `
        -PreRelease $prerelease -BuildMetaData $buildmetadata
    }
  }
}

function Step-SemanticMajorVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Version
    )

    process {
        Set-SemanticVersion -Version $Version -NextMajor
    }
}

function Step-SemanticMinorVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Version
    )

    process {
        Set-SemanticVersion -Version $Version -NextMinor
    }
}

function Step-SemanticPatchVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Version
    )

    process {
        Set-SemanticVersion -Version $Version -NextPatch
    }
}

function Test-SemanticVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Version
    )

    return ($Version -match $script:regexmatch)
}

Set-Alias -Name "Test-SemVer" -Value "Test-SemanticVersion"
