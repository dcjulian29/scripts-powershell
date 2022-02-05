---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Get-DockerContainerState.md
schema: 2.0.0
---

# Get-DockerContainerState

## SYNOPSIS

Get the state of container(s).

## SYNTAX

### All (Default)

```powershell
Get-DockerContainerState [-Running] [<CommonParameters>]
```

### Individual

```powershell
Get-DockerContainerState [[-Id] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Get-DockerContainerState function returns the state of containers. It can be filtered to return only running containers.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-DockerContainerState

Id                                                               State
--                                                               -----
9a66ed0f53d2b71fb031f15c161f70b239ec96188f359ff68f9a24ae32cc0d95 exited
d13a1b3408c9b399e20788ed211be9858597e86bed78ed81b3c898b217fa8cdc running
c3f015b67195997beaac3ea8f238d3b267ed0d97526614ddf47ffb793c011b6b running
```

This example shows the state of each container.

### Example 2

```powershell
PS C:\> Get-DockerContainerState d13a1b
running
```

This example shows the state of a specific container.

## PARAMETERS

### -Id

Specifies the UUID identifier that the Docker daemon uses to identify the container.

```yaml
Type: String
Parameter Sets: Individual
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Running

Limit to only running containers.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
