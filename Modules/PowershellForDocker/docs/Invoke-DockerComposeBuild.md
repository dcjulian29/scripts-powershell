---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Invoke-DockerComposeBuild.md
schema: 2.0.0
---

# Invoke-DockerComposeBuild

## SYNOPSIS

Build or rebuild services.

## SYNTAX

```powershell
Invoke-DockerComposeBuild [[-ComposeFile] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Invoke-DockerComposeBuild function will call docker compose cli to build or rebuild services defined in the docker compose file.

## EXAMPLES

### Example 1

```powershell
PS C:\> Invoke-DockerComposeBuild -ComposeFile ./docker-compose.yml

Building apt-mirror
[+] Building 3.8s (8/8) FINISHED
 => [internal] load build definition from Dockerfile                                                               0.0s
 => => transferring dockerfile: 32B                                                                                0.0s
 => [internal] load .dockerignore                                                                                  0.0s
 => => transferring context: 2B                                                                                    0.0s
 => [internal] load metadata for docker.io/library/alpine:latest                                                   0.0s
 => CACHED [1/3] FROM docker.io/library/alpine:latest                                                              0.0s
 => [internal] load build context                                                                                  0.0s
 => => transferring context: 651B                                                                                  0.0s
 => [2/3] RUN apk add --update --no-cache gzip xz bzip2 tzdata perl wget curl ca-certificates thttpd   && wget -O  2.8s
 => [3/3] COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh                                                        0.1s
 => exporting to image                                                                                             0.7s
 => => exporting layers                                                                                            0.7s
 => => writing image sha256:13e536207cb55de00ed69ba6076f318a368ace9a22b41710c8c8e0e42aee44e2                       0.0s
 => => naming to docker.io/library/apt-mirror_apt-mirror                                                           0.0s

```

This example builds the apt-mirror docker compose file.

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
