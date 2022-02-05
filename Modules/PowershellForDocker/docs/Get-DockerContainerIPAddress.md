---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Get-DockerContainerIPAddress.md
schema: 2.0.0
---

# Get-DockerContainerIPAddress

## SYNOPSIS

Get the IP Address(es) of the container(s).

## SYNTAX

### All (Default)

```powershell
Get-DockerContainerIPAddress [-Running] [<CommonParameters>]
```

### Individual

```powershell
Get-DockerContainerIPAddress [[-Id] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Get-DockerContainerIPAddress function retrieves the assigned IP address of Docker containers.

## EXAMPLES

### Example 1

```powershell
PS C:\>  Get-DockerContainerIPAddress

Id                                                               IpAddress
--                                                               ---------
d13a1b3408c9b399e20788ed211be9858597e86bed78ed81b3c898b217fa8cdc 172.17.0.3
c3f015b67195997beaac3ea8f238d3b267ed0d97526614ddf47ffb793c011b6b 172.17.0.2
```

This example shows the IP address for the current containers.

### Example 2

```powershell
PS C:\>  Get-DockerContainerIPAddress -Id c3f015b67195997
172.17.0.2
```

This example shows the IP address for the specified container.

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
