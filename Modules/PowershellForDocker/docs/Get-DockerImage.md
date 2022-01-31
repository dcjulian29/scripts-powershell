---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Get-DockerImage.md
schema: 2.0.0
---

# Get-DockerImage

## SYNOPSIS

List images.

## SYNTAX

```powershell
Get-DockerImage [[-Name] <String>] [-Unused]
```

## DESCRIPTION

The Get-DockerImage function lists the Docker images as specified. For example, when you want to remove any unused images from the cache.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-DockerImage | Format-Table

Id                                                               Name                                          Tag
--                                                               ----                                          ---
13e536207cb55de00ed69ba6076f318a368ace9a22b41710c8c8e0e42aee44e2 apt-mirror_apt-mirror                         latest
bcd3df1f148a04d1919759c913884dc54664b10da4c99ee5b3ae19ab63907a67 linuxserver/code-server                       latest
da2cb49d7a8d1416cfc2ec6fb47b60112b3a2f276bcf7439ef18e7c505b83fc6 postgres                                      latest
4400e68786e0f67a6a5d951bf2598bd56d42c10a7f1541913e3f4b5f4d43b3e1 dcjulian29/ansible                            5.1.0
4400e68786e0f67a6a5d951bf2598bd56d42c10a7f1541913e3f4b5f4d43b3e1 dcjulian29/ansible                            latest
f7bf2c631c3ff770c7258568dbaaf3106ca4e8486c34557f5176ea3d5f626097 mbentley/bind-tools                           latest
8ed4840f8ea533b6b4ada6c19eb6bed0c0762ab8c11e3e312a266a987d1fc48b <none>                                        <none>
0df02179156afbf727443d0be50e8b9cdab8c044050691517539cea2e3ed01fd portainer/portainer-ce                        latest
66e8ab9bb6f0de97f47bd2537ffdca48e3bab6bcfb0abc7bf586ffdc1dc82a0e debian                                        buste...
c059bfaa849c4d8e4aecaeb3a10c2d9b3d85f5165c66ad3a4d937758128c4d18 alpine                                        latest
e347b2b2d6c139e00250755db2a77c993176bdbbc5daecc5c0c3a3b04004b186 docker.elastic.co/elasticsearch/elasticsearch 7.14.0
58dffcbc8caa43c7bb0084fb51b29706bc0dca39405b39b67f4923988b11c527 docker.elastic.co/kibana/kibana               7.14.0
3453a70d3577c8fceede441d17fd91fa15451b58bace60e15e294919f04d7a65 dcjulian29/nmap                               latest
822b23d200a33eed21f5a9635f36bf14b34e86007424442e1d62a1077a710081 wagoodman/dive                                latest
```

This example list all of the current Docker images in the cache.

### Example 2

```powershell
PS C:\> Get-DockerImage -Name postgres


Id      : da2cb49d7a8d1416cfc2ec6fb47b60112b3a2f276bcf7439ef18e7c505b83fc6
Name    : postgres
Tag     : latest
Created : 3 days ago
Size    : 392167424
```

This example shows the details for the postgres image.

## PARAMETERS

### -Name

Specify the name of the image.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Unused

Only show Unused images.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```
