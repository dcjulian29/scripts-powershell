---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Remove-DockerContainer.md
schema: 2.0.0
---

# Remove-DockerContainer

## SYNOPSIS

Removes one or more containers.

## SYNTAX

### ID (Default)

```powershell
Remove-DockerContainer [-Id] <String> [<CommonParameters>]
```

### Container

```powershell
Remove-DockerContainer [-Container <PSObject>] [<CommonParameters>]
```

### All

```powershell
Remove-DockerContainer [-All] [<CommonParameters>]
```

### Other

```powershell
Remove-DockerContainer [-Exited] [-NonRunning] [<CommonParameters>]
```

## DESCRIPTION

The Remove-DockerContainer function removes on or more containers. It can also remove all exited or non-running containers.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-DockerContainer -Id 9a66ed | Remove-DockerContainer
9a66ed0f53d2b71fb031f15c161f70b239ec96188f359ff68f9a24ae32cc0d95
```

This example removed the specified container.

### Example 2

```powershell
PS C:\> Remove-DockerContainer -Exited
20e11a17233e8506868dc17ab9de9291fcccaba839dc610581ccdd60f5e5c258
31bdb168cafd07ef16159139f862efe202b8ecf67e0d2cd0a331240430718b54
```

This example removed container that were exited.

## PARAMETERS

### -All

Remove all containers regardless of state.

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

### -Container

A container object returned from Get-DockerContainer.

```yaml
Type: PSObject
Parameter Sets: Container
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Exited

Only remove containers that have exited.

```yaml
Type: SwitchParameter
Parameter Sets: Other
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
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -NonRunning

Only remove non-running containers.

```yaml
Type: SwitchParameter
Parameter Sets: Other
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
