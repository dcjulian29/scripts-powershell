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
    $wim = "{0}:\sources\install.wim" -f $(mountISO $wim)
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
  param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [Alias("Path")]
    [string] $IsoFile
  )

  $IsoFile = (Resolve-Path $IsoFile).Path

  if (isIsoFile($IsoFile)) {
    $wim = (getWimFileName $IsoFile)

    if (Test-Path $wim) {
      Get-WindowsImagesInWIM $wim
    }

    Get-DiskImage -ImagePath $IsoFile | Dismount-DiskImage | Out-Null
  }
}

function Get-WindowsImagesInWIM {
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

  $File = (Resolve-Path $File).Path

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

    $Index = Read-Host "Enter the number for the OS you want"
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
  $vhdx = "$env:SystemDrive\Virtual Machines\BaseVHDX\Win{0}Base{1}.vhdx" -f $OsVersion, $Suffix

  if (doesVhdxBlock -File $vhdx -Force $Force.IsPresent) {
    return
  }

  $partition = "UEFI"

  if ($OsVersion -like "*2008*") {
    $partition = "BIOS"
  }

  Push-Location "$env:SystemDrive\Virtual Machines\BaseVHDX"

  Write-Output "Creating a base disk using '$($image.ImageName)' to '$vhdx'..."

  . $PSScriptRoot\Convert-WindowsImage.ps1;Convert-WindowsImage -SourcePath $wim `
    -Edition $Index -DiskLayout $partition  -VHDPath $vhdx `
    -VHDFormat VHDX -SizeBytes 100GB -Verbose

  Pop-Location

  if (isIsoFile($File)) {
    Get-DiskImage -ImagePath $File | Dismount-DiskImage | Out-Null
  }
}

function New-BaseServerVhdxDisk {
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
