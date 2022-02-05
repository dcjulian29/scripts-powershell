---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Stop-DockerContainer.md
schema: 2.0.0
---

# Stop-DockerContainer

## SYNOPSIS

Stop one or more running containers.

## SYNTAX

### ID (Default)

```powershell
Stop-DockerContainer [-Id] <String> [[-TimeOut] <Int32>] [<CommonParameters>]
```

### All

```powershell
Stop-DockerContainer [[-TimeOut] <Int32>] [-All] [<CommonParameters>]
```

## DESCRIPTION

The Stop-DockerContainer functions stops one or more running containers.

## EXAMPLES

### Example 1

```powershell
PS C:\> Stop-DockerContainer 20e11a17233e8
20e11a17233e8
```

This example stops the specified container.

### Example 2

```powershell
PS C:\> Stop-DockerContainer -All
6abce5607388
ca0405e0daf8
20e11a17233e
31bdb168cafd
```

This example stops all running containers.

## PARAMETERS

### -All

Specify to stop all running containers.

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
Parameter Sets: ID
Aliases: Name

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeOut

Specifies the number of seconds to wait for container to exit before killing the container execution.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
