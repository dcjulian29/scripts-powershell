---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/New-DockerVolume.md
schema: 2.0.0
---

# New-DockerVolume

## SYNOPSIS

Create a Docker volume.

## SYNTAX

### Name (Default)

```powershell
New-DockerVolume [-Name] <String> [<CommonParameters>]
```

### TempFS

```powershell
New-DockerVolume [-Name] <String> [-Size <String>] [-UserID <Int32>] [-TemporaryFS] [<CommonParameters>]
```

### Driver

```powershell
New-DockerVolume [-Name] <String> [-Driver] <String> [[-DriverOptions] <String[]>] [<CommonParameters>]
```

### Path

```powershell
New-DockerVolume [-Name] <String> [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION

The New-DockerVolume function creates a Docker volume. A temporary volume can also be created with a specific size.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-DockerVolume -Name Test3

Test3
```

This example adds a Docker volume named Test3.

### Example 2

```powershell
PS C:\> New-DockerVolume -Name Test4 -TempFS

Test4
```

This example adds a temporary filesystem Docker volume named Test4.

### Example 3

```powershell
PS C:\> New-DockerVolume -Name Test5 -Path ./

Test5
```

This example adds a Docker volume named Test5 mounted at the specified path.

## PARAMETERS

### -Driver

Specify volume driver name.

```yaml
Type: String
Parameter Sets: Driver
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DriverOptions

Specify volume driver specific options.

```yaml
Type: String[]
Parameter Sets: Driver
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

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

Specify the volume path.

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Size

In temporary filesystems, Specify the size of the temporary filesystem volume.

```yaml
Type: String
Parameter Sets: TempFS
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TemporaryFS

Specify that a temporary file system volume is to be created.

```yaml
Type: SwitchParameter
Parameter Sets: TempFS
Aliases: TempFS

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserID

In temporary filesystems, Specify the owner ID of the temporary filesystem volume.

```yaml
Type: Int32
Parameter Sets: TempFS
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
