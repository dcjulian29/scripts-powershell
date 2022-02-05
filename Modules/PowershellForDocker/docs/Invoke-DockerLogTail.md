---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Invoke-DockerLogTail.md
schema: 2.0.0
---

# Invoke-DockerLogTail

## SYNOPSIS

Get and follow a container's logs.

## SYNTAX

```powershell
Invoke-DockerLogTail [-ContainerName] <String> [[-Lines] <Int32>] [<CommonParameters>]
```

## DESCRIPTION

The Invoke-DockerLog function retrieves the logs for the specified container Aat the time of execution.

> **_NOTE_**
>
> This command is only functional for containers that are started with the json-file or journald logging driver. The docker logs command will continue streaming the new output from the container’s `STDOUT` and `STDERR`.

## EXAMPLES

### Example 1

```powershell
PS C:\> Invoke-DockerLogTail -Id a89ab3a5d4690338
2022-01-29T15:58:27.549652700Z selecting default shared_buffers ... 128MB
2022-01-29T15:58:27.579035600Z selecting default time zone ... Etc/UTC
2022-01-29T15:58:27.596614300Z creating configuration files ... ok
2022-01-29T15:58:30.292118500Z running bootstrap script ... ok
2022-01-29T15:58:35.806071000Z performing post-bootstrap initialization ... ok
2022-01-29T15:58:38.951075000Z initdb: warning: enabling "trust" authentication for local connections
2022-01-29T15:58:38.951191900Z You can change this by editing pg_hba.conf or using the option -A, or
2022-01-29T15:58:38.951207000Z --auth-local and --auth-host, the next time you run initdb.
2022-01-29T15:58:38.951076500Z syncing data to disk ... ok
2022-01-29T15:58:38.951222900Z
2022-01-29T15:58:38.951228700Z
2022-01-29T15:58:38.951234300Z Success. You can now start the database server using:
2022-01-29T15:58:38.951240000Z
2022-01-29T15:58:38.951245400Z     pg_ctl -D /var/lib/postgresql/data -l logfile start
2022-01-29T15:58:38.951251000Z
2022-01-29T15:58:39.034193800Z waiting for server to start....2022-01-29 15:58:39.033 UTC [57] LOG:  starting PostgreSQL 14.1 (Debian 14.1-1.pgdg110+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
2022-01-29T15:58:39.038879900Z 2022-01-29 15:58:39.038 UTC [57] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2022-01-29T15:58:39.077064800Z 2022-01-29 15:58:39.076 UTC [58] LOG:  database system was shut down at 2022-01-29 15:58:35 UTC
2022-01-29T15:58:39.110038900Z 2022-01-29 15:58:39.109 UTC [57] LOG:  database system is ready to accept connections
2022-01-29T15:58:39.193643200Z  done
2022-01-29T15:58:39.193679200Z server started
2022-01-29T15:58:41.799471200Z CREATE DATABASE
2022-01-29T15:58:41.800161500Z
2022-01-29T15:58:41.800202100Z
2022-01-29T15:58:41.800424200Z /usr/local/bin/docker-entrypoint.sh: ignoring /docker-entrypoint-initdb.d/*
2022-01-29T15:58:41.800439200Z
2022-01-29T15:58:41.808080900Z 2022-01-29 15:58:41.807 UTC [57] LOG:  received fast shutdown request
2022-01-29T15:58:41.812575500Z waiting for server to shut down...2022-01-29 15:58:41.812 UTC [57] LOG:  aborting any active transactions
2022-01-29T15:58:41.814301900Z 2022-01-29 15:58:41.814 UTC [57] LOG:  background worker "logical replication launcher" (PID 64) exited with exit code 1
2022-01-29T15:58:41.814864300Z 2022-01-29 15:58:41.814 UTC [59] LOG:  shutting down
2022-01-29T15:58:41.889012300Z .2022-01-29 15:58:41.888 UTC [57] LOG:  database system is shut down
2022-01-29T15:58:41.919605600Z  done
2022-01-29T15:58:41.919647000Z server stopped
2022-01-29T15:58:41.919817100Z
2022-01-29T15:58:41.919831700Z PostgreSQL init process complete; ready for start up.
2022-01-29T15:58:41.919838200Z
2022-01-29T15:58:41.964098200Z 2022-01-29 15:58:41.963 UTC [1] LOG:  starting PostgreSQL 14.1 (Debian 14.1-1.pgdg110+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 10.2.1-6) 10.2.1 20210110, 64-bit
2022-01-29T15:58:41.964313400Z 2022-01-29 15:58:41.964 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
2022-01-29T15:58:41.964432600Z 2022-01-29 15:58:41.964 UTC [1] LOG:  listening on IPv6 address "::", port 5432
2022-01-29T15:58:41.973875900Z 2022-01-29 15:58:41.973 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
2022-01-29T15:58:42.002187600Z 2022-01-29 15:58:42.001 UTC [71] LOG:  database system was shut down at 2022-01-29 15:58:41 UTC
2022-01-29T15:58:42.036355200Z 2022-01-29 15:58:42.036 UTC [1] LOG:  database system is ready to accept connections
```

This example shows and follows the log from a recently started Postgres container.

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

### -Lines

Specify the number of lines to include.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
