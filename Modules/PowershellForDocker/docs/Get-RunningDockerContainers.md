---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Get-RunningDockerContainers.md
schema: 2.0.0
---

# Get-RunningDockerContainers

## SYNOPSIS

Get the running containers.

## SYNTAX

```powershell
Get-RunningDockerContainers
```

## DESCRIPTION

The Get-RunningDockerContainers function returns the currently running containers.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-RunningDockerContainers


Id      : d13a1b3408c9b399e20788ed211be9858597e86bed78ed81b3c898b217fa8cdc
Image   : alpine:latest
Command : "/bin/sh"
Created : 14 hours ago
Status  : Up 14 hours
Ports   :
Name    : alpine_shell
Size    : 0

Id      : c3f015b67195997beaac3ea8f238d3b267ed0d97526614ddf47ffb793c011b6b
Image   : debian:buster-slim
Command : "bash"
Created : 14 hours ago
Status  : Up 14 hours
Ports   :
Name    : debian_shell
Size    : 0
```

This example returns the currently running containers.

## PARAMETERS

### None
