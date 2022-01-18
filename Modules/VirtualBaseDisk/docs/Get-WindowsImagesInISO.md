---
external help file: VirtualBaseDisk-help.xml
Module Name: VirtualBaseDisk
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/VirtualBaseDisk/docs/Get-WindowsImagesInISO.md
schema: 2.0.0
---

# Get-WindowsImagesInISO

## SYNOPSIS

Gets information about all Windows images in an ISO file.

## SYNTAX

```powershell
Get-WindowsImagesInISO [-IsoFile] <String> [<CommonParameters>]
```

## DESCRIPTION

The Get-WindowsImagesInISO cmdlet gets a list of Windows images in an ISO file.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-WindowsImagesInISO Windows11_InsiderPreview_Client_x64_en-us_22533.iso

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
```

This example list the Windows Images contained in the install.wim file inside the ISO file..

## PARAMETERS

### -IsoFile

Specifies the location of an ISO file.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
