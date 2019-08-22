function Get-WindowsImageInWIM {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $WimFile
    )

    Get-WindowsImage -ImagePath $WimFile `
    | Sort-Object ImageIndex `
    | Select-Object `
        @{Label="#"; Expression={$_.ImageIndex}}, `
        @{Label="Name"; Expression={$_.ImageName}} `
    | Format-Table -AutoSize
}

function New-BaseVhdxDisk {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string] $WimFile,
        [string] $VhdxFile,
        [ValidateSet("2008", "2008R2", "2012", "2012R2", "2016", "2019")]
        $OsVersion = "2019",
        [string] $Edition = "Standard (Desktop Experience)",
        [switch] $Force
    )

    if (-not $VhdxFile ) {
        $File = "Win${OsVersion}Base.vhdx"
    } else {
        $File = $VhdxFile
    }

    if (-not (Test-Path "$File") -and $force) {
        Write-Warning "$File already exists, Not Overwriting..."
        return
    }

    if ((Test-Path "$File") -and $force) {
        Remove-Item -Path "$File" -Force
    }

    $partition = "UEFI"

    if ($OsVersion -like "*2008*") {
        $partition = "BIOS"
    }

    Push-Location $((Get-VMHost).VirtualHardDiskPath)

    Write-Output "Creating a base disk using [$WimFile] for $OsVersion [$Edition] to $File..."

    Convert-WindowsImage -SourcePath $WimFile -Edition $Edition `
        -DiskLayout $partition  -VHDPath $file `
        -VHDFormat VHDX -SizeBytes 100GB -Verbose

    Pop-Location
}

###############################################################################

Export-ModuleMember New-BaseVhdxDisk
