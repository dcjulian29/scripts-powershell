---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Read-DockerCompose.md
schema: 2.0.0
---

# Read-DockerCompose

## SYNOPSIS

Validate and view the Compose file.

## SYNTAX

```powershell
Read-DockerCompose [[-ComposeFile] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Read-DockerCompose function reads a docker compose file, validates it and outputs the validated results.

## EXAMPLES

### Example 1

```powershell
PS C:\> Read-DockerCompose

services:
  portainer:
    environment:
      TZ: America/New_York
    image: portainer/portainer-ce
    ports:
    - published: 9000
      target: 9000
    - published: 8000
      target: 8000
    volumes:
    - /var/run/docker.sock:/var/run/docker.sock:rw
    - D:\dockerdata\portainer:/data:rw
version: '3.9'
```

This example validates a docker compose file configured for Portainer and outputs the result.

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
