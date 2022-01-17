function doesVhdxBlock {
  param (
    [string] $File,
    [switch] $Force
  )

  if (Test-Path $File) {
    if ($Force) {
      Remove-Item -Path $File -Force
    } else {
      Write-Warning "$File already exists, Not Overwriting..."
      return $true
    }
  }

  return $false
}

function getWIMFileName($File) {
  $wim = Resolve-Path $File

  if (isIsoFile($File)) {
    $wim = "{0}:\sources\install.wim" -f $(mountISO $File)
  }

  return $wim
}

function mountISO($File) {
  $image = Get-DiskImage -ImagePath $File

  if (-not $image.Attached) {
    $image = Mount-DiskImage -ImagePath $image.ImagePath -Access ReadOnly
  }

  do {
   $drive = ($image | Get-Volume).DriveLetter
  } while ($drive -eq "")

  return $drive
}

function isWimFile($File) {
  return ($File.EndsWith(".wim"))
}

function isIsoFile($File) {
  return ($File.EndsWith(".iso"))
}

#------------------------------------------------------------------------------

function Get-WindowsImagesInISO {
  <#
  .SYNOPSIS
    Gets information about all Windows images in an ISO file.
  .DESCRIPTION
    The Get-WindowsImagesInISO cmdlet gets a list of Windows images in an ISO file.
  .PARAMETER IsoFile
    Specifies the location of an ISO file.
  #>
  param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [Alias("Path")]
    [string] $IsoFile
  )

  if (isIsoFile($IsoFile)) {
    $wim = (getWimFileName $IsoFile)

    if (Test-Path $wim) {
      Get-WindowsImagesInWIM $wim
    }

    Get-DiskImage -ImagePath $IsoFile | Dismount-DiskImage | Out-Null
  }
}

function Get-WindowsImagesInWIM {
  <#
  .SYNOPSIS
    Gets information about all Windows images in an WIM file.
  .DESCRIPTION
    The Get-WindowsImagesInWIM cmdlet gets a list of Windows images in a WIM file.
  .PARAMETER IsoFile
    Specifies the location of an WIM file.
  #>
  param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [Alias("Path")]
    [string] $WimFile
  )

  if (isWimFile($WimFile)) {
    Get-WindowsImage -ImagePath $WimFile `
      | Sort-Object ImageIndex `
      | Select-Object `
        @{Label="#"; Expression={$_.ImageIndex}}, `
        @{Label="Name"; Expression={$_.ImageName}} `
      | Format-Table -AutoSize
  }
}

function New-BaseVhdxDisk {
  <#
  .SYNOPSIS
    Create a "base" VHDX from the Windows image in a WIM or ISO file.
  .DESCRIPTION
    The New-BaseVhdxDisk cmdlet creates a VHDX file from a Windows Image contained
    in a WIM or ISO file.
  .PARAMETER File
    Specifies the location of a WIM or ISO file.
  .PARAMETER Index
    Specifies the index number of a Windows image in a WIM or ISO file.
  .PARAMETER Force
    Specifies that the target VHDX file should be overwritten if it exists.
  .PARAMETER Suffix
    Specifies a suffix to add to the generated VHDX file name.
  #>
  param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [Alias("Path")]
    [string] $File,
    [string] $Index,
    [switch] $Force,
    [string] $Suffix
  )

  if ((-not (isWimFile($File))) -and (-not (isIsoFile($File)))) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "File provided is not a WIM or ISO file!" `
      -ExceptionType "System.IO.FileFormatException" `
      -ErrorId "FileFormatException" `
      -ErrorCategory InvalidArgument `
      -TargetObject $File))
  }

  if (-not $Index) {
    Get-WindowsImagesInWIM -WimFile $File
    Get-WindowsImagesInISO -IsoFile $File

    $Index = Read-Host "Enter the number for the OS you want:"
  }

  if (-not $index) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "Index is required!" `
      -ExceptionType "System.IndexOutOfRangeException" `
      -ErrorId "IndexOutOfRangeException" `
      -ErrorCategory InvalidArgument `
      -TargetObject $Index))
  }

  $wim = getWIMFileName($File)
  $image = Get-WindowsImage -ImagePath $wim | Where-Object { $_.ImageIndex -eq $Index }

  if (-not $image) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "Image for the Index does not exist!" `
      -ExceptionType "System.IndexOutOfRangeException" `
      -ErrorId "IndexOutOfRangeException" `
      -ErrorCategory InvalidArgument `
      -TargetObject $Index))
  }

  $OsVersion = $image.ImageName -replace '[^0-9]'
  $vhdx = "$((Get-VMHost).VirtualHardDiskPath)\base\Win{0}Base{1}.vhdx" -f $OsVersion, $Suffix

  if (doesVhdxBlock -File $vhdx -Force $Force.IsPresent) {
    return
  }

  $partition = "UEFI"

  if ($OsVersion -like "*2008*") {
    $partition = "BIOS"
  }

  Push-Location "$((Get-VMHost).VirtualHardDiskPath)\base"

  Write-Output "Creating a base disk using '$($image.ImageName)' to '$vhdx'..."

  . $PSScriptRoot\Convert-WindowsImage.ps1;Convert-WindowsImage -SourcePath $wim `
    -Edition $Index -DiskLayout $partition  -VHDPath $vhdx `
    -VHDFormat VHDX -SizeBytes 100GB -Verbose

  Pop-Location

  if (isIsoFile($File)) {
    Get-DiskImage -ImagePath $File | Dismount-DiskImage | Out-Null
  }
}

function New-BaseServerVhdxDisks {
  <#
  .SYNOPSIS
    Create two "base" VHDX from a Windows Server image in a WIM or ISO file.
  .DESCRIPTION
    The New-BaseServerVhdxDisk cmdlet creates two VHDX files from a Windows Server Image
    contained in a WIM or ISO file. One VHDX is the "Desktop Experience" and the other is
    the "Core" style.
  .PARAMETER OsVersion
    Specifies the version of the operating system in the WIM or ISO file.
  .PARAMETER File
    Specifies the location of a WIM or ISO file.
  .PARAMETER Force
    Specifies that the target VHDX files should be overwritten if it exists.
  .PARAMETER EvalIso
    Specifies that the WIM or ISO is from an Evaluation Media source.
  #>
  param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [int] $OSVersion,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $File,
    [switch] $Force,
    [switch] $EvalIso
  )

  if ((-not (isWimFile($File))) -and (-not (isIsoFile($File)))) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "File provided is not a WIM or ISO file!" `
      -ExceptionType "System.IO.FileFormatException" `
      -ErrorId "FileFormatException" `
      -ErrorCategory InvalidArgument `
      -TargetObject $File))
  }

  $wim = getWIMFileName($File)
  $eval = ""

  if ($EvalIso) {
    $eval = " Evaluation"
  }

  $baseName = "Windows Server $OSVersion Standard$eval"

  $desktopImage = Get-WindowsImage -ImagePath $wim `
    | Where-Object { $_.ImageName -eq "$baseName (Desktop Experience)" }

  $coreImage = Get-WindowsImage -ImagePath $wim `
    | Where-Object { $_.ImageName -eq $baseName }

  if (-not $desktopImage) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "'$baseName (Desktop Experience)' image does not exists in '$wim'!" `
      -ExceptionType "System.IO.FileFormatException" `
      -ErrorId "FileFormatException" `
      -ErrorCategory InvalidArgument `
      -TargetObject $File))
  }

  if (-not $coreImage) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "'$baseName' image does not exists in '$wim'!" `
      -ExceptionType "System.IO.FileFormatException" `
      -ErrorId "FileFormatException" `
      -ErrorCategory InvalidArgument `
      -TargetObject $File))
  }

  $desktopIndex = $desktopImage.ImageIndex
  New-BaseVhdxDisk -File $wim -Index $desktopIndex -Force:$Force.IsPresent

  $coreIndex = $coreImage.ImageIndex
  New-BaseVhdxDisk -File $wim -Index $coreIndex -Suffix "Core" -Force:$Force.IsPresent
}

function New-DevBaseVhdxDisk {
  <#
  .SYNOPSIS
    Create a "base" VHDX from the Windows Insiders image in a WIM or ISO file.
  .DESCRIPTION
    The New-DevBaseVhdxDisk cmdlet creates a VHDX file from a Windows Insiders Image contained
    in a WIM or ISO file.
  .PARAMETER File
    Specifies the location of a Windows Insiders WIM or ISO file.
  .PARAMETER OsVersion
    Specifies the version of the operating system in the WIM or ISO file.
  #>
  param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $File,
    [int] $OSVersion = 11
  )

  if ((-not (isWimFile($File))) -and (-not (isIsoFile($File)))) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "File provided is not a WIM or ISO file!" `
      -ExceptionType "System.IO.FileFormatException" `
      -ErrorId "FileFormatException" `
      -ErrorCategory InvalidArgument `
      -TargetObject $File))
  }

  $wim = getWIMFileName($File)

  $image = Get-WindowsImage -ImagePath $wim `
    | Where-Object { $_.ImageName -eq "Windows $OSVersion Pro" }

  if ($image) {
    $index = $image.ImageIndex

    $build = (dism /Get-WimInfo /WimFile:$wim /index:$index `
      | Select-String Version)[1] -Replace('Version : ', '')

    New-BaseVhdxDisk -File $wim -Index $index -Suffix "Insider-$Build"
  } else {
    Write-Output "Windows $OSVersion Pro image does not exists in that file!"
  }
}
