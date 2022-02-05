---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Invoke-DockerComposeLogTail.md
schema: 2.0.0
---

# Invoke-DockerComposeLogTail

## SYNOPSIS

Display and follow log output from service(s).

## SYNTAX

```powershell
Invoke-DockerComposeLogTail [[-ComposeFile] <String>] [[-Lines] <Int32>] [[-Service] <String>]
```

## DESCRIPTION

The Invoke-DockerComposeLogTail function uses docker compose to output the log(s) from the services identified in the docker compose file and specific service if specified. It also provides a way of limiting the number of lines to output prior to following and outputting new logs.

## EXAMPLES

### Example 1

```powershell
PS C:\> Invoke-DockerComposeLog -Service apt_mirror -Lines 30

Attaching to apt-mirror_apt-mirror_1
apt-mirror_1  | Downloading 333 index files using 20 threads...
apt-mirror_1  | Begin time: Fri Jan 28 11:31:42 2022
apt-mirror_1  | [20]... [19]... [18]... [17]... [16]... [15]... [14]... [13]... [12]... [11]... [10]... [9]... [8]... [7]... [6]... [5]... [4]... [3]... [2]... [1]... [0]...
apt-mirror_1  | End time: Fri Jan 28 11:33:50 2022
apt-mirror_1  |
apt-mirror_1  | Processing translation indexes: [TTTTTTTTT]
apt-mirror_1  |
apt-mirror_1  | Downloading 1156 translation files using 20 threads...
apt-mirror_1  | Begin time: Fri Jan 28 11:33:50 2022
apt-mirror_1  | [20]... [19]... [18]... [17]... [16]... [15]... [14]... [13]... [12]... [11]... [10]... [9]... [8]... [7]... [6]... [5]... [4]... [3]... [2]... [1]... Downloading 333 index files using 20 threads...
apt-mirror_1  | Begin time: Fri Jan 28 12:51:53 2022
apt-mirror_1  | [20]... [19]... [18]... [17]... [16]... [15]... [14]... [13]... [12]... [11]... [10]... [9]... [8]... [7]... [6]... [5]... [4]... [3]... [2]... [1]... [0]...
apt-mirror_1  | End time: Fri Jan 28 12:51:59 2022
apt-mirror_1  |
apt-mirror_1  | Processing translation indexes: [TTTTTTTTT]
apt-mirror_1  |
apt-mirror_1  | Downloading 1156 translation files using 20 threads...
apt-mirror_1  | Begin time: Fri Jan 28 12:51:59 2022
apt-mirror_1  | [20]... [19]... [18]... [17]... [16]... [15]... [14]... [13]... [12]... [11]... [10]... [9]... [8]... [7]... [6]... [5]... [4]... [3]... [2]... [1]... [0]...
apt-mirror_1  | End time: Fri Jan 28 12:52:09 2022
apt-mirror_1  |
apt-mirror_1  | Processing DEP-11 indexes: [DDDDDDDDD]
apt-mirror_1  |
apt-mirror_1  | Downloading 155 dep11 files using 20 threads...
apt-mirror_1  | Begin time: Fri Jan 28 12:52:09 2022
apt-mirror_1  | [20]... [19]... [18]... [17]... [16]... [15]... [14]... [13]... [12]... [11]... [10]... [9]... [8]... [7]... [6]... [5]... [4]... [3]... [2]... [1]... [0]...
apt-mirror_1  | End time: Fri Jan 28 12:52:44 2022
```

This example shows the last 30 lines pf the logs from the apt-mirror service.

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

### -Service

Specifies the name of the service to get logs from.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```
