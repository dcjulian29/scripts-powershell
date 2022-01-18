---
external help file: VirtualBaseDisk-help.xml
Module Name: VirtualBaseDisk
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/VirtualBaseDisk/docs/New-BaseServerVhdxDisks.md
schema: 2.0.0
---

# New-BaseServerVhdxDisks

## SYNOPSIS

Create two "base" VHDX from a Windows Server image in a WIM or ISO file.

## SYNTAX

```powershell
New-BaseServerVhdxDisks [-OSVersion] <Int32> [-File] <String> [-Force] [-EvalIso] [<CommonParameters>]
```

## DESCRIPTION

The New-BaseServerVhdxDisks cmdlet creates two VHDX files from a Windows Server Image
contained in a WIM or ISO file.
One VHDX is the "Desktop Experience" and the other is
the "Core" style.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-BaseServerVhdxDisks -OSVersion 2022 -File .\windows_server_2022_updated_dec_2021_x64_dvd_6905f97b.iso
Creating a base disk using 'Windows Server 2022 Standard (Desktop Experience)' to 'C:\Virtual Machines\Discs\base\Win2022Base.vhdx' ...

Windows(R) Image to Virtual Hard Disk Converter for Windows(R) 10
Copyright (C) Microsoft Corporation.  All rights reserved.
Version 10.0.14278.1000.amd64fre.rs1_es_media.160201-1707

VERBOSE: Target Image Version 10.0.19044.1466
VERBOSE: isUserAdmin? True
VERBOSE: is Windows 8 or Higher? True
VERBOSE: Temporary VHDX path is : C:\Virtual Machines\Discs\base\abe92ff5-a6cf-49c8-ba0e-452146d2bca8.vhdx
INFO   : Looking for the requested Windows image in the WIM file
INFO   : Image 2 selected (ServerStandard)...
INFO   : Creating sparse disk...
INFO   : Mounting VHDX...
INFO   : Initializing disk...
INFO   : Creating EFI system partition...
INFO   : Formatting system volume...
INFO   : Applying image to VHDX. This could take a while...
INFO   : Image was applied successfully.
INFO   : Making image bootable...
VERBOSE: Running bcdboot.exe H:\Windows /s F: /v /f UEFI
VERBOSE: Return code was 0.
INFO   : Drive is bootable.  Cleaning up...
INFO   : Dismounting VHDX...
VERBOSE: VHDX final path is : C:\Virtual Machines\Discs\base\Win2022Base.vhdx
VERBOSE: Renaming VHDX at C:\Virtual Machines\Discs\base\abe92ff5-a6cf-49c8-ba0e-452146d2bca8.vhdx to Win2022Base.vhdx
INFO   : Closing Windows image...
INFO   : Done.
Creating a base disk using 'Windows Server 2022 Standard' to 'C:\Virtual Machines\Discs\base\Win2022BaseCore.vhdx'...

Windows(R) Image to Virtual Hard Disk Converter for Windows(R) 10
Copyright (C) Microsoft Corporation.  All rights reserved.
Version 10.0.14278.1000.amd64fre.rs1_es_media.160201-1707

VERBOSE: Target Image Version 10.0.19044.1466
VERBOSE: isUserAdmin? True
VERBOSE: is Windows 8 or Higher? True
VERBOSE: Temporary VHDX path is : C:\Virtual Machines\Discs\base\6e0c17f6-d98e-4b25-8774-2b2674630b98.vhdx
INFO   : Looking for the requested Windows image in the WIM file
INFO   : Image 1 selected (ServerStandardCore)...
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
VERBOSE: VHDX final path is : C:\Virtual Machines\Discs\base\Win2022BaseCore.vhdx
VERBOSE: Renaming VHDX at C:\Virtual Machines\Discs\base\6e0c17f6-d98e-4b25-8774-2b2674630b98.vhdx to
Win2022BaseCore.vhdx
INFO   : Closing Windows image...
INFO   : Done.
```

This example builds and creates two VHDX files: Win2022Base.vhdx and Win2022BaseCore.vhdx

## PARAMETERS

### -OSVersion

Specifies the version of the operating system in the WIM or ISO file.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -File

Specifies the location of a WIM or ISO file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

Specifies that the target VHDX files should be overwritten if it exists.

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

### -EvalIso

Specifies that the WIM or ISO is from an Evaluation Media source.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
