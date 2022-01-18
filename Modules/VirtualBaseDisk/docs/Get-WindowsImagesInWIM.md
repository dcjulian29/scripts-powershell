---
external help file: VirtualBaseDisk-help.xml
Module Name: VirtualBaseDisk
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/VirtualBaseDisk/docs/Get-WindowsImagesInWIM.md
schema: 2.0.0
---

# Get-WindowsImagesInWIM

## SYNOPSIS

Gets information about all Windows images in an WIM file.

## SYNTAX

```powershell
Get-WindowsImagesInWIM [-WimFile] <String> [<CommonParameters>]
```

## DESCRIPTION

The Get-WindowsImagesInWIM cmdlet gets a list of Windows images in a WIM file.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-WindowsImagesInWIM D:\sources\install.wim

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

This example list the Windows Images contained in the WIM file.

## PARAMETERS

### -WimFile

The WIM file is containing a file-based imaging format that are used
to manage files such as drivers, updates, and components without
booting the operating system image.

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
