---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Remove-DockerImage.md
schema: 2.0.0
---

# Remove-DockerImage

## SYNOPSIS

Remove one or more Docker images.

## SYNTAX

```powershell
Remove-DockerImage [[-Id] <String>] [[-Name] <String>] [-Unused] [-Force]
```

## DESCRIPTION

The Remove-DockerImage removes one or more Docker images.

## EXAMPLES

### Example 1

```powershell
PS C:\> Remove-DockerImage -Id 8ed4840f8ea533b6b4ada

Deleted: sha256:8ed4840f8ea533b6b4ada6c19eb6bed0c0762ab8c11e3e312a266a987d1fc48b
```

This example deletes the specified image.

## PARAMETERS

### -Force

Force removal of the image.

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

### -Id

Specifies the UUID identifier that the Docker daemon uses to identify the container.

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

### -Name

The name of the image.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Unused

Specifies to remove unused images.

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
