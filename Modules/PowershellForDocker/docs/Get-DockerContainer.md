---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Get-DockerContainer.md
schema: 2.0.0
---

# Get-DockerContainer

## SYNOPSIS

Get information about docker containers.

## SYNTAX

### All (Default)

```powershell
Get-DockerContainer [-Running] [<CommonParameters>]
```

### Individual

```powershell
Get-DockerContainer [[-Id] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Get-DockerContainer function returns information about docker containers. If the ID is provided, the container is inspected and the information returned. Otherwise, a brief summary is returned.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-DockerContainer

Id      : d13a1b3408c9b399e20788ed211be9858597e86bed78ed81b3c898b217fa8cdc
Image   : alpine:latest
Command : "/bin/sh"
Created : 6 seconds ago
Status  : Up 5 seconds
Ports   :
Name    : alpine_shell
Size    : 0

Id      : c3f015b67195997beaac3ea8f238d3b267ed0d97526614ddf47ffb793c011b6b
Image   : debian:buster-slim
Command : "bash"
Created : 2 minutes ago
Status  : Up 2 minutes
Ports   :
Name    : debian_shell
Size    : 0
```

This example returns a brief list of containers.

### Example 2

```powershell
PS C:\> Get-DockerContainer -Id d13a1b34

Id              : d13a1b3408c9b399e20788ed211be9858597e86bed78ed81b3c898b217fa8cdc
Created         : 2022-01-29T01:38:38.3986918Z
Path            : /bin/sh
Args            : {}
State           : @{Status=running; Running=True; Paused=False; Restarting=False; OOMKilled=False; Dead=False;
                  Pid=3532; ExitCode=0; Error=; StartedAt=2022-01-29T01:38:39.0010509Z;
                  FinishedAt=0001-01-01T00:00:00Z}
Image           : sha256:c059bfaa849c4d8e4aecaeb3a10c2d9b3d85f5165c66ad3a4d937758128c4d18
ResolvConfPath  : /var/lib/docker/containers/d13a1b3408c9b399e20788ed211be9858597e86bed78ed81b3c898b217fa8cdc/resolv.co
                  nf
HostnamePath    : /var/lib/docker/containers/d13a1b3408c9b399e20788ed211be9858597e86bed78ed81b3c898b217fa8cdc/hostname
HostsPath       : /var/lib/docker/containers/d13a1b3408c9b399e20788ed211be9858597e86bed78ed81b3c898b217fa8cdc/hosts
LogPath         : /var/lib/docker/containers/d13a1b3408c9b399e20788ed211be9858597e86bed78ed81b3c898b217fa8cdc/d13a1b340
                  8c9b399e20788ed211be9858597e86bed78ed81b3c898b217fa8cdc-json.log
Name            : /alpine_shell
RestartCount    : 0
Driver          : overlay2
Platform        : linux
MountLabel      :
ProcessLabel    :
AppArmorProfile :
ExecIDs         :
HostConfig      : @{Binds=; ContainerIDFile=; LogConfig=; NetworkMode=default; PortBindings=; RestartPolicy=;
                  AutoRemove=True; VolumeDriver=; VolumesFrom=; CapAdd=; CapDrop=; CgroupnsMode=host;
                  Dns=System.Object[]; DnsOptions=System.Object[]; DnsSearch=System.Object[]; ExtraHosts=; GroupAdd=;
                  IpcMode=private; Cgroup=; Links=; OomScoreAdj=0; PidMode=; Privileged=False; PublishAllPorts=False;
                  ReadonlyRootfs=False; SecurityOpt=; UTSMode=; UsernsMode=; ShmSize=67108864; Runtime=runc;
                  ConsoleSize=System.Object[]; Isolation=; CpuShares=0; Memory=0; NanoCpus=0; CgroupParent=;
                  BlkioWeight=0; BlkioWeightDevice=System.Object[]; BlkioDeviceReadBps=; BlkioDeviceWriteBps=;
                  BlkioDeviceReadIOps=; BlkioDeviceWriteIOps=; CpuPeriod=0; CpuQuota=0; CpuRealtimePeriod=0;
                  CpuRealtimeRuntime=0; CpusetCpus=; CpusetMems=; Devices=System.Object[]; DeviceCgroupRules=;
                  DeviceRequests=; KernelMemory=0; KernelMemoryTCP=0; MemoryReservation=0; MemorySwap=0;
                  MemorySwappiness=; OomKillDisable=False; PidsLimit=; Ulimits=; CpuCount=0; CpuPercent=0;
                  IOMaximumIOps=0; IOMaximumBandwidth=0; MaskedPaths=System.Object[]; ReadonlyPaths=System.Object[]}
GraphDriver     : @{Data=; Name=overlay2}
Mounts          : {}
Config          : @{Hostname=d13a1b3408c9; Domainname=; User=; AttachStdin=True; AttachStdout=True; AttachStderr=True;
                  Tty=True; OpenStdin=True; StdinOnce=True; Env=System.Object[]; Cmd=System.Object[];
                  Image=alpine:latest; Volumes=; WorkingDir=; Entrypoint=; OnBuild=; Labels=}
NetworkSettings : @{Bridge=; SandboxID=a4e5309f22cec19be43cc236d310f017ee9d13eb2bcccbdb841b1ede384d8869;
                  HairpinMode=False; LinkLocalIPv6Address=; LinkLocalIPv6PrefixLen=0; Ports=;
                  SandboxKey=/var/run/docker/netns/a4e5309f22ce; SecondaryIPAddresses=; SecondaryIPv6Addresses=;
                  EndpointID=528c554b5ef07f81cf0e68a35f3123d39adedc2ce82f4e23b7e13cb1ef0ea7e1; Gateway=172.17.0.1;
                  GlobalIPv6Address=; GlobalIPv6PrefixLen=0; IPAddress=172.17.0.3; IPPrefixLen=16; IPv6Gateway=;
                  MacAddress=02:42:ac:11:00:03; Networks=}
```

This example returns detailed information about the container.

## PARAMETERS

### -Id

Specifies the UUID identifier that the Docker daemon uses to identify the container.

```yaml
Type: String
Parameter Sets: Individual
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Running

Limit to only running containers.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
