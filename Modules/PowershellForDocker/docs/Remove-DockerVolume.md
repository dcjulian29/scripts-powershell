---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Remove-DockerVolume.md
schema: 2.0.0
---

# Remove-DockerVolume

## SYNOPSIS

Remove a Docker volume.

## SYNTAX

```powershell
Remove-DockerVolume [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION

The Remove-DockerVolume removes a Docker volume.

## EXAMPLES

### Example 1

```powershell
PS C:\> Remove-DockerVolume -Name Test6

Test6
```

This example removes the specified Docker volume.

## PARAMETERS

### -Name

Specify the name of the Docker volume.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
