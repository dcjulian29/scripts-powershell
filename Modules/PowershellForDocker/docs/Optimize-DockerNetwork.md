---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Optimize-DockerNetwork.md
schema: 2.0.0
---

# Optimize-DockerNetwork

## SYNOPSIS

Remove all unused Docker networks.

## SYNTAX

```Powershell
Optimize-DockerNetwork [-Force]
```

## DESCRIPTION

The Optimize-DockerNetwork function removes all unused Docker networks. An option to force the removal is also available.

## EXAMPLES

### Example 1

```powershell
PS C:\> Optimize-DockerNetwork

WARNING! This will remove all custom networks not used by at least one container.
Are you sure you want to continue? [y/N] y
Deleted Networks:
dokuwiki_default
mynet
httpd_default
portainer_default
```

This example removes all of the unused Docker networks that are not used by at least one container.

## PARAMETERS

### -Force

Specify that the network should be removed by force if necessary.

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
