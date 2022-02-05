---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Invoke-DockerLog.md
schema: 2.0.0
---

# Invoke-DockerLog

## SYNOPSIS

Get a container's logs.

## SYNTAX

```powershell
Invoke-DockerLog [-Id] <String> [<CommonParameters>]
```

## DESCRIPTION

The Invoke-DockerLog function retrieves the logs for the specified container.

## EXAMPLES

### Example 1

```powershell
PS C:\> Invoke-DockerLog -Id 9a66ed0f

2022/01/29 15:01:53 server: Reverse tunnelling enabled
2022/01/29 15:01:53 server: Fingerprint 5e:ea:82:36:f1:bc:63:3a:8e:d9:0b:10:c4:22:2e:1e
2022/01/29 15:01:53 server: Listening on 0.0.0.0:8000...
level=info msg="2022/01/29 15:01:53 [INFO] [cmd,main] Starting Portainer version 2.11.0"
level=info msg="2022/01/29 15:01:53 [DEBUG] [chisel, monitoring] [check_interval_seconds: 10.000000] [message: starting tunnel management process]"
level=info msg="2022/01/29 15:01:53 [DEBUG] [internal,init] [message: start initialization monitor ]"
level=info msg="2022/01/29 15:01:53 [INFO] [http,server] [message: starting HTTPS server on port :9443]"
level=info msg="2022/01/29 15:01:53 [INFO] [http,server] [message: starting HTTP server on port :9000]"
```

This example shows the log of a running Portainer container.

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
