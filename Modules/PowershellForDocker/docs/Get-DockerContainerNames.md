---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Get-DockerContainerNames.md
schema: 2.0.0
---

# Get-DockerContainerNames

## SYNOPSIS

Get the container names.

## SYNTAX

```powershell
Get-DockerContainerNames [-Running] [-Image]
```

## DESCRIPTION

The Get-DockerContainerNames function returns the names of the Docker containers. It can also show the image name that the container is using.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-DockerContainerNames

portainer_portainer_1
alpine_shell
debian_shell
```

This example shows the names of the current containers.

### Example 2

```powershell
PS C:\> Get-DockerContainerNames -Image

Name                  Image
----                  -----
portainer_portainer_1 portainer/portainer-ce
alpine_shell          alpine:latest
debian_shell          debian:buster-slim
```

This example shows the current containers and the image that they use.

## PARAMETERS

### -Image

Include the image name used for the container.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: IncludeImage

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Running

Limit to only running containers.

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
