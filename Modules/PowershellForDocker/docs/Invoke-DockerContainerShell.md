---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Invoke-DockerContainerShell.md
schema: 2.0.0
---

# Invoke-DockerContainerShell

## SYNOPSIS

Invoke a container shell to interact with it.

## SYNTAX

```powershell
Invoke-DockerContainerShell [-Id] <String> [<CommonParameters>]
```

## DESCRIPTION

The Invoke-DockerContainerShell function attaches interactively to a container.

## EXAMPLES

### Example 1

```powershell
PS C:\> Invoke-DockerContainerShell -Id c3f015b
#
```

This example invokes the shell on the specified container.

## PARAMETERS

### -Id

Specifies the UUID identifier that the Docker daemon uses to identify the container.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
