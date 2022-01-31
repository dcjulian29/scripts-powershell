---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Remove-DockerNetwork.md
schema: 2.0.0
---

# Remove-DockerNetwork

## SYNOPSIS

Remove a Docker network.

## SYNTAX

```powershell
Remove-DockerNetwork [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION

The Remove-DockerNetwork function removes a Docker network.

## EXAMPLES

### Example 1

```powershell
PS C:\> Remove-DockerNetwork -Name "gatenet"

gatenet
```

This example deletes the Docker network named gatenet.

## PARAMETERS

### -Name

Specify the name of the Docker network.

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
