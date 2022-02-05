---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Get-DockerComposeLog.md
schema: 2.0.0
---

# Get-DockerComposeLog

## SYNOPSIS

Displays log output from services.

## SYNTAX

```powershell
Get-DockerComposeLog
```

## DESCRIPTION

The Get-DockerComposeLog function uses docker compose to output the logs from the services identified in the docker-compose.yml file.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-DockerComposeLog

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
apt-mirror_1  |
```

This example outputs the logs of the services identified in the docker-compose.yml file.

## PARAMETERS

### None
