---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Get-DockerVolume.md
schema: 2.0.0
---

# Get-DockerVolume

## SYNOPSIS

List Docker volumes.

## SYNTAX

```powershell
Get-DockerVolume [[-Name] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Get-DockerVolume function list Docker volumes. If a name is provided, the function will display detailed information about the volume.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-DockerVolume -Name test2

CreatedAt  : 2022-02-03T10:35:08Z
Driver     : local
Labels     :
Mountpoint : /var/lib/docker/volumes/test2/_data
Name       : test2
Options    :
Scope      : local
```

This example shows the detailed information about the specified Docker volume.

## PARAMETERS

### -Name

Specify the name of the Docker volume.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
