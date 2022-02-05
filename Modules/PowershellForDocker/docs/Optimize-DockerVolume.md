---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Optimize-DockerVolume.md
schema: 2.0.0
---

# Optimize-DockerVolume

## SYNOPSIS

Remove all unused local volumes.

## SYNTAX

```powershell
Optimize-DockerVolume [-Force]
```

## DESCRIPTION

The Optimize-DockerVolume function removes all unused local volumes. Once removed, there is no way to recover the volume.

## EXAMPLES

### Example 1

```powershell
PS C:\> Optimize-DockerVolume

WARNING! This will remove all local volumes not used by at least one container.
Are you sure you want to continue? [y/N] y
Deleted Volumes:
Test1
Test2
Test3

Total reclaimed space: 10B
```

This example removes all unused Docker volumes.

## PARAMETERS

### -Force

Specify not to prompt for confirmation.

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
