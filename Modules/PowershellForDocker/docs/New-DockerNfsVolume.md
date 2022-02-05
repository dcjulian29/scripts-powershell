---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/New-DockerNfsVolume.md
schema: 2.0.0
---

# New-DockerNfsVolume

## SYNOPSIS

Create a Docker volume backed by an NFS share.

## SYNTAX

```powershell
New-DockerNfsVolume [-Name] <String> [-Server] <String> [-Path] <String> [-ReadOnly] [<CommonParameters>]
```

## DESCRIPTION

The New-DockerNfsVolume function Create a Docker volume backed by an NFS share. It does no validation of the NFS share.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-DockerNfsVolume -Name "NfsTest1" -Server 10.10.10.10 -Path "/mnt/nfstest1"

NfsTest1
```

This example creates a Docker volume that is backed by the specified NFS share.

## PARAMETERS

### -Name

Specify volume name.

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

### -Path

Specify the path of the NFS share.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReadOnly

Specify that the volume should only be mounted read only.

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

### -Server

Specify the name or IP Address of the host exporting the NFS share.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
