---
external help file: VirtualBaseDisk-help.xml
Module Name: VirtualBaseDisk
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/VirtualBaseDisk/docs/New-BaseVhdxDisk.md
schema: 2.0.0
---

# New-BaseVhdxDisk

## SYNOPSIS

Create a "base" VHDX from the Windows image in a WIM or ISO file.

## SYNTAX

```powershell
New-BaseVhdxDisk [-File] <String> [[-Index] <String>] [-Force] [[-Suffix] <String>] [<CommonParameters>]
```

## DESCRIPTION

The New-BaseVhdxDisk cmdlet creates a VHDX file from a Windows Image contained
in a WIM or ISO file.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-BaseVhdxDisk -File .\windows_11_consumer_editions_updated_dec_2021_x64_dvd_bcf90d0b.iso

 # Name
 - ----
 1 Windows 11 Home
 2 Windows 11 Home N
 3 Windows 11 Home Single Language
 4 Windows 11 Education
 5 Windows 11 Education N
 6 Windows 11 Pro
 7 Windows 11 Pro N
 8 Windows 11 Pro Education
 9 Windows 11 Pro Education N
10 Windows 11 Pro for Workstations
11 Windows 11 Pro N for Workstations


Enter the number for the OS you want: 6
Creating a base disk using 'Windows 11 Pro' to 'C:\Virtual Machines\BaseVHDX\Win11Base.vhdx'...

Windows(R) Image to Virtual Hard Disk Converter for Windows(R) 10
Copyright (C) Microsoft Corporation.  All rights reserved.
Version 10.0.14278.1000.amd64fre.rs1_es_media.160201-1707

VERBOSE: Target Image Version 10.0.19044.1466
VERBOSE: isUserAdmin? True
VERBOSE: is Windows 8 or Higher? True
VERBOSE: Temporary VHDX path is : C:\Virtual Machines\BaseVHDX\fda6df23-eb25-4751-9690-e382d49e5ed5.vhdx
INFO   : Looking for the requested Windows image in the WIM file
INFO   : Image 6 selected (Professional)...
INFO   : Creating sparse disk...
INFO   : Mounting VHDX...
INFO   : Initializing disk...
INFO   : Creating EFI system partition...
INFO   : Formatting system volume...
INFO   : Setting system partition as ESP...
INFO   : Creating MSR partition...
INFO   : Creating windows partition...
INFO   : Formatting windows volume...
INFO   : Windows path (I:) has been assigned.
INFO   : Windows path (I:) took 1 attempts to be assigned.
INFO   : System volume location: H:
INFO   : Applying image to VHDX. This could take a while...
INFO   : Image was applied successfully.
INFO   : Making image bootable...
VERBOSE: Running bcdboot.exe I:\Windows /s H: /v /f UEFI
VERBOSE: Return code was 0.
INFO   : Drive is bootable.  Cleaning up...
INFO   : Dismounting VHDX...
VERBOSE: VHDX final path is : C:\Virtual Machines\BaseVHDX\Win11Base.vhdx
VERBOSE: Renaming VHDX at C:\Virtual Machines\BaseVHDX\fda6df23-eb25-4751-9690-e382d49e5ed5.vhdx to Win11Base.vhdx
INFO   : Closing Windows image...
INFO   : Done.
```

This example generates a 'Win11Base.vhdx' file.

### Example 2

```powershell
PS C:\> New-BaseVhdxDisk -File .\windows_11_consumer_editions_updated_dec_2021_x64_dvd_bcf90d0b.iso -Index 1 -Suffix "Home"

Creating a base disk using 'Windows 11 Home' to 'C:\Virtual Machines\BaseVHDX\Win11BaseHome.vhdx'...

Windows(R) Image to Virtual Hard Disk Converter for Windows(R) 10
Copyright (C) Microsoft Corporation.  All rights reserved.
Version 10.0.14278.1000.amd64fre.rs1_es_media.160201-1707

VERBOSE: Target Image Version 10.0.19044.1466
VERBOSE: isUserAdmin? True
VERBOSE: is Windows 8 or Higher? True
VERBOSE: Temporary VHDX path is : C:\Virtual Machines\BaseVHDX\a3086fa8-892c-4d72-984d-d414e0ef1cb1.vhdx
INFO   : Looking for the requested Windows image in the WIM file
INFO   : Image 1 selected (Core)...
INFO   : Creating sparse disk...
INFO   : Mounting VHDX...
INFO   : Initializing disk...
INFO   : Creating EFI system partition...
INFO   : Formatting system volume...
INFO   : Setting system partition as ESP...
INFO   : Creating MSR partition...
INFO   : Creating windows partition...
INFO   : Formatting windows volume...
INFO   : Windows path (I:) has been assigned.
INFO   : Windows path (I:) took 1 attempts to be assigned.
INFO   : System volume location: H:
INFO   : Applying image to VHDX. This could take a while...
INFO   : Image was applied successfully.
INFO   : Making image bootable...
VERBOSE: Running bcdboot.exe I:\Windows /s H: /v /f UEFI
VERBOSE: Return code was 0.
INFO   : Drive is bootable.  Cleaning up...
INFO   : Dismounting VHDX...
VERBOSE: VHDX final path is : C:\Virtual Machines\BaseVHDX\Win11BaseHome.vhdx
VERBOSE: Renaming VHDX at C:\Virtual Machines\BaseVHDX\a3086fa8-892c-4d72-984d-d414e0ef1cb1.vhdx to
Win11BaseHome.vhdx
INFO   : Closing Windows image...
INFO   : Done.
```

This example generates a 'Win11BaseHome.vhdx' file.

## PARAMETERS

### -File

Specifies the location of a WIM or ISO file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Index

Specifies the index number of a Windows image in a WIM or ISO file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

Specifies that the target VHDX file should be overwritten if it exists.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Suffix

Specifies a suffix to add to the generated VHDX file name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
