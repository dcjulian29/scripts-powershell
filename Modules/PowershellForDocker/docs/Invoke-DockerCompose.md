---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Invoke-DockerCompose.md
schema: 2.0.0
---

# Invoke-DockerCompose

## SYNOPSIS

Invoke docker-compose.exe

## SYNTAX

```powershell
Invoke-DockerCompose
```

## DESCRIPTION

The Invoke-DockerCompose function wraps the docker-compose.exe to define and run multi-container services with Docker.

> **_NOTE:_** Anything after the function name is passed unmodified as arguments.

## EXAMPLES

### Example 1

```powershell
PS C:\> Invoke-DockerCompose

Define and run multi-container applications with Docker.

Usage:
  docker-compose [-f <arg>...] [--profile <name>...] [options] [--] [COMMAND] [ARGS...]
  docker-compose -h|--help

Options:
  -f, --file FILE             Specify an alternate compose file
                              (default: docker-compose.yml)
  -p, --project-name NAME     Specify an alternate project name
                              (default: directory name)
  --profile NAME              Specify a profile to enable
  -c, --context NAME          Specify a context name
  --verbose                   Show more output
  --log-level LEVEL           Set log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
  --ansi (never|always|auto)  Control when to print ANSI control characters
  --no-ansi                   Do not print ANSI control characters (DEPRECATED)
  -v, --version               Print version and exit
  -H, --host HOST             Daemon socket to connect to

  --tls                       Use TLS; implied by --tlsverify
  --tlscacert CA_PATH         Trust certs signed only by this CA
  --tlscert CLIENT_CERT_PATH  Path to TLS certificate file
  --tlskey TLS_KEY_PATH       Path to TLS key file
  --tlsverify                 Use TLS and verify the remote
  --skip-hostname-check       Don't check the daemon's hostname against the
                              name specified in the client certificate
  --project-directory PATH    Specify an alternate working directory
                              (default: the path of the Compose file)
  --compatibility             If set, Compose will attempt to convert keys
                              in v3 files to their non-Swarm equivalent (DEPRECATED)
  --env-file PATH             Specify an alternate environment file

Commands:
  build              Build or rebuild services
  config             Validate and view the Compose file
  create             Create services
  down               Stop and remove resources
  events             Receive real time events from containers
  exec               Execute a command in a running container
  help               Get help on a command
  images             List images
  kill               Kill containers
  logs               View output from containers
  pause              Pause services
  port               Print the public port for a port binding
  ps                 List containers
  pull               Pull service images
  push               Push service images
  restart            Restart services
  rm                 Remove stopped containers
  run                Run a one-off command
  scale              Set number of containers for a service
  start              Start services
  stop               Stop services
  top                Display the running processes
  unpause            Unpause services
  up                 Create and start containers
  version            Show version information and quit

Docker Compose is now in the Docker CLI, try `docker compose`
```

This example invokes docker-compose.exe without any parameters.

### Example 2

```powershell
PS C:\> Invoke-DockerCompose config

services:
  apt-mirror:
    build:
      context: C:\docker\apt-mirror
    environment:
      TZ: America/New_York
    ports:
    - published: 8080
      target: 80
    volumes:
    - C:\docker\apt-mirror:/var/spool/apt-mirror/mirror:rw
    - C:\docker\apt-mirror.list:/etc/apt/mirror.list:ro
version: '3.9'
```
