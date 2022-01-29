---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Pop-DockerCompose.md
schema: 2.0.0
---

# Pop-DockerCompose

## SYNOPSIS

Pulls image(s) defined in a docker-compose.yml file, but does not start any containers based on those images.

## SYNTAX

```powershell
Pop-DockerCompose [[-ComposeFile] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Pop-DockerCompose calls out to docker-compose.exe to pull all images defined in the docker compose file. If the image already exists, no action is done.

## EXAMPLES

### Example 1

```powershell
PS C:\> Pop-DockerCompose

Pulling portainer ... done
```

This example pulls the latest Portainer image.

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
