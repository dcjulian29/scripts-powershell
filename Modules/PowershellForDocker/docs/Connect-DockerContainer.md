---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Connect-DockerContainer.md
schema: 2.0.0
---

# Connect-DockerContainer

## SYNOPSIS

Attach local standard input, output, and error streams to a running container.

## SYNTAX

```powershell
Connect-DockerContainer [-Id] <String> [<CommonParameters>]
```

## DESCRIPTION

The Connect-DockerContainer attaches the host's standard input, output, and error streams to a running container.

## EXAMPLES

### Example 1

```powershell
PS C:\> Connect-DockerContainer -Id 03afcf02260f
/ #
```

This example attaches to the container identified.

## PARAMETERS

### -Id

Specifies the UUID identifier that the Docker daemon uses to identify the container.

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
