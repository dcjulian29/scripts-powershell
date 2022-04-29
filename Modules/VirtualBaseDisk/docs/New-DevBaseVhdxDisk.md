---
external help file: VirtualBaseDisk-help.xml
Module Name: VirtualBaseDisk
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/VirtualBaseDisk/docs/New-DevBaseVhdxDisk.md
schema: 2.0.0
---

# New-DevBaseVhdxDisk

## SYNOPSIS

Create a "base" VHDX from the Windows Insiders image in a WIM or ISO file.

## SYNTAX

```powershell
New-DevBaseVhdxDisk [-File] <String> [[-OSVersion] <Int32>] [<CommonParameters>]
```

## DESCRIPTION

The New-DevBaseVhdxDisk cmdlet creates a VHDX file from a Windows Insiders Image contained
in a WIM or ISO file.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-DevBaseVhdxDisk -File .\Windows11_InsiderPreview_Client_x64_en-us_22533.iso
Creating a base disk using 'Windows 11 Pro' to 'C:\Virtual Machines\BaseVHDX\Win11BaseInsider-10.0.22533.vhdx'...

Windows(R) Image to Virtual Hard Disk Converter for Windows(R) 10
Copyright (C) Microsoft Corporation.  All rights reserved.
Version 10.0.14278.1000.amd64fre.rs1_es_media.160201-1707

VERBOSE: Target Image Version 10.0.19044.1466
VERBOSE: isUserAdmin? True
VERBOSE: is Windows 8 or Higher? True
VERBOSE: Temporary VHDX path is : C:\Virtual Machines\BaseVHDX\e59134c9-3c70-4b9c-81f3-cd494d76c4fe.vhdx
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
INFO   : Windows path (H:) has been assigned.
INFO   : Windows path (H:) took 1 attempts to be assigned.
INFO   : System volume location: F:
INFO   : Applying image to VHDX. This could take a while...
INFO   : Image was applied successfully.
INFO   : Making image bootable...
VERBOSE: Running bcdboot.exe H:\Windows /s F: /v /f UEFI
VERBOSE: Return code was 0.
INFO   : Drive is bootable.  Cleaning up...
INFO   : Dismounting VHDX...
VERBOSE: VHDX final path is : C:\Virtual Machines\BaseVHDX\Win11BaseInsider-10.0.22533.vhdx
VERBOSE: Renaming VHDX at C:\Virtual Machines\BaseVHDX\e59134c9-3c70-4b9c-81f3-cd494d76c4fe.vhdx to
Win11BaseInsider-10.0.22533.vhdx
INFO   : Closing Windows image...
INFO   : Done.
```

This example generates a 'Win11BaseInsider-10.0.22533.vhdx' file.

## PARAMETERS

### -File

Specifies the location of a Windows Insiders WIM or ISO file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSVersion

Specifies the version of the operating system in the WIM or ISO file.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 11
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
