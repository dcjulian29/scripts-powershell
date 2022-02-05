---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Stop-DockerCompose.md
schema: 2.0.0
---

# Stop-DockerCompose

## SYNOPSIS

Stops containers and removes containers, networks, volumes, and images.

## SYNTAX

```powershell
Stop-DockerCompose
```

## DESCRIPTION

The Stop-DockerCompose function stops running containers, then removes any configured networks, volumes, and potentially images.

By default, the only things removed are:

- Containers for services defined in the Compose file
- Networks defined in the networks section of the Compose file
- The default network, if one is used

Networks and volumes defined as `external` are never removed.

## EXAMPLES

### Example 1

```powershell
PS C:\> Stop-DockerCompose

Removing portainer_portainer_1 ... done
Removing network portainer_default
```

This example stops and removes the Portainer container and removes the default network that was created.

## PARAMETERS

### None
