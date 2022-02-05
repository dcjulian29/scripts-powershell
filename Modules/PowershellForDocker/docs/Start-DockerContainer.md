---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Start-DockerContainer.md
schema: 2.0.0
---

# Start-DockerContainer

## SYNOPSIS

Start one or more stopped containers.

## SYNTAX

### ID (Default)

```powershell
Start-DockerContainer [-Id] <String> [<CommonParameters>]
```

### All

```powershell
Start-DockerContainer [-All] [<CommonParameters>]
```

## DESCRIPTION

The Start-DockerContainer functions starts one or more stopped containers.

## EXAMPLES

### Example 1

```powershell
PS C:\> Start-DockerContainer 6abce5607
6abce5607
```

This example starts the specified container.

### Example 2

```powershell
PS C:\> Stop-DockerContainer -All
ca0405e0daf8
20e11a17233e
31bdb168cafd
```

This example starts all stopped containers.

## PARAMETERS

### -All

Specify to start all stopped containers.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

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
