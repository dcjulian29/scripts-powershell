---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Get-DockerMountPoint.md
schema: 2.0.0
---

# Get-DockerMountPoint

## SYNOPSIS

Convert a path to a mountpoint that Docker can use.

## SYNTAX

```powershell
Get-DockerMountPoint [-Path] <String> [-UnixStyle] [<CommonParameters>]
```

## DESCRIPTION

The Get-DockerMountPoint function coverts a relative or absolute folder/file path to a format that Docker can use to bind mount volumes.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-DockerMountPoint $env:TEMP

C:/Users/julian/AppData/Local/Temp
```

This example shows a Windows-style mount point for Docker.

### Example 2

```powershell
PS C:\> Get-DockerMountPoint $env:TEMP -UnixStyle

/mnt/c/Users/julian/AppData/Local/Temp
```

This example shows a UNIX-style mount point for Docker.

## PARAMETERS

### -Path

Specify a path to a file or folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UnixStyle

Specify to return the path as a UNIX style.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
