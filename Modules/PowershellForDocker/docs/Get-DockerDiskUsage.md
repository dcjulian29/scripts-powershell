---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Get-DockerDiskUsage.md
schema: 2.0.0
---

# Get-DockerDiskUsage

## SYNOPSIS

Get the amount of disk space Docker is consuming.

## SYNTAX

```powershell
Get-DockerDiskUsage
```

## DESCRIPTION

The Get-DockerDiskUsage function returns the amount of disk space used by Docker images, containers local volumes, and the build cache. It also includes the reclaimable space as well.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-DockerDiskUsage | Format-Table


Type          Total Active        Size Reclaimable
----          ----- ------        ---- -----------
Images        19    0       9718437249  9718437249
Containers    0     0                0           0
Local Volumes 0     0                0           0
Build Cache   139   0      20884278477 20884278477
```

This example shows the current disk used by Docker.

## PARAMETERS

### None
