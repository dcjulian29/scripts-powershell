---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Start-DockerCompose.md
schema: 2.0.0
---

# Start-DockerCompose

## SYNOPSIS

Builds, (re)creates, and starts containers specified in the Compose file.

## SYNTAX

```powershell
Start-DockerCompose [[-ComposeFile] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Start-DockerCompose function calls the docker compose up command using the specified Compose file.

If there are existing containers for a service, and the service’s configuration or image was changed after the container’s creation, docker compose picks up the changes by stopping and recreating the containers (preserving mounted volumes).

## EXAMPLES

### Example 1

```powershell
PS C:\> Start-DockerCompose

Creating network "portainer_default" with the default driver
Creating portainer_portainer_1 ... done
```

This example starts a Portainer container.

## PARAMETERS

### -ComposeFile

Specify a docker compose file. (default: docker-compose.yml)

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
