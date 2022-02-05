---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Get-DockerContainerIds.md
schema: 2.0.0
---

# Get-DockerContainerIds

## SYNOPSIS

Get container IDs.

## SYNTAX

```powershell
Get-DockerContainerIds [-Running] [-NoTruncate]
```

## DESCRIPTION

The Get-DockerContainerIds function gets and outputs the ID(s) of Docker containers. By default, the ID are truncated but can be output without truncation.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-DockerContainerIds

d13a1b3408c9
c3f015b67195
```

This example returns the two IDs for the two containers that are running.

## PARAMETERS

### -NoTruncate

Don't truncate output.

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
