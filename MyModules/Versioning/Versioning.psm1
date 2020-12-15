$script:regexmicrosoft = '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:\.(0|[1-9]\d*))?$'

function ConvertFrom-DatedVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    if ((Test-Version $Version) -and ($Version.Split('.').Count -eq 4)) {
        $parts = $Version.Split('.')

        # I have existing released version during 2020 so dated versions for the rest of 2020
        # should be greater that 2020 but less than 2101.
        if ($parts[0] -eq '2020') {
            $major = $parts[0].Substring(2) + (12 + $parts[1])
        } else {
            $major = $parts[0].Substring(2) + $parts[1]
        }

        New-SemanticVersion -Major $major -Minor $parts[2] -Patch $parts[3]
    } else {
        throw "'$Version' isn't a dated version string!"
    }
}

function ConvertTo-AssemblyVersion {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    if (Test-SemanticVersion $Version) {
        New-Version -Major (Get-SemanticVersion $Version).Major -Minor 0 -Build 0 -Revision 0
    } else {
        New-Version -Major (Get-Version $Version).Major -Minor 0 -Build 0 -Revision 0
    }
}

function Get-Version {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Version
    )

    if (-not (Test-Version $Version)) {
        throw "'$Version' is not a Microsoft version. (Major.Minor.Build.Revision)"
    }

    $Version -match $script:regexmicrosoft | Out-Null

    $detail = New-Object PSObject

    $detail | Add-Member -Type NoteProperty -Name 'Major' -Value $Matches[1]
    $detail | Add-Member -Type NoteProperty -Name 'Minor' -Value $Matches[2]
    $detail | Add-Member -Type NoteProperty -Name 'Build' -Value $Matches[3]

    if ($Matches.Count -gt 3){
        $detail | Add-Member -Type NoteProperty -Name 'Revision' -Value $Matches[4]
    } else {
        $detail | Add-Member -Type NoteProperty -Name 'Revision' -Value $null
    }

    return $detail
}

function New-Version {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [int] $Major,
        [Parameter(Position = 1, Mandatory = $true)]
        [int] $Minor,
        [Parameter(Position = 2, Mandatory = $true)]
        [int] $Build,
        [Parameter(Position = 3)]
        [int] $Revision
    )

    $version = "$Major.$Minor.$Build"

    if ($PSBoundParameters.ContainsKey('Revision')) {
        $version = "$version.$Revision"
    }

    return $version
}

function Set-Version {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Version,
        [switch] $NextMajor,
        [switch] $NextMinor,
        [switch] $NextBuild,
        [switch] $NextRevision
    )

    process {
        $versions = @()

        if ($Version.GetType().BaseType.Name -eq "Array") {
            $versions = $Version
        } else {
            $versions += $Version
        }

        foreach ($item in $versions) {
            if (Test-Version $item) {
                $ver = Get-Version $item

                $major = $ver.Major
                $minor = $ver.Minor
                $build = $ver.Build
                $revision = $ver.Revision

                if ($NextMajor) {
                    $major = ([int]$major) + 1
                }

                if ($NextMinor) {
                    $minor = ([int]$minor) + 1
                }

                if ($NextBuild) {
                    $build = ([int]$build) + 1
                }

                if ($NextRevision) {
                    if ($null -eq $revision) {
                        $revision = 1
                    } else {
                        $revision = ([int]$revision) + 1
                    }
                }

                New-Version -Major $major -Minor $minor -Build $build -Revision $revision
            }
        }
    }
}

function Step-BuildVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Version
    )

    process {
        Set-Version -Version $Version -NextBuild
    }
}

function Step-MajorVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Version
    )

    process {
        Set-Version -Version $Version -NextMajor
    }
}

function Step-MinorVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Version
    )

    process {
        Set-Version -Version $Version -NextMinor
    }
}

function Step-RevisionVersion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Version
    )

    process {
        Set-Version -Version $Version -NextRevision
    }
}

function Test-Version {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $Version
    )

    return ($Version -match $script:regexmicrosoft)
}
