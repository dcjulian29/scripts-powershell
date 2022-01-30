---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/New-DockerContainer.md
schema: 2.0.0
---

# New-DockerContainer

## SYNOPSIS

Create and start a new Docker container.

## SYNTAX

```powershell
New-DockerContainer [-Image] <String> [[-Tag] <String>] [-Name <String>] [-HostName <String>] [-Volume <String[]>] [-EnvironmentVariables <Hashtable>] [-ReadOnly] [-EntryPoint <String>] [-EntryScript <String>] [-Command <String>] [-AdditionalArgs <String>] [-Interactive] [-Keep] [<CommonParameters>]
```

## DESCRIPTION

The New-DockerContainer function creates and starts a new Docker container.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-DockerContainer -Image "dcjulian29/ansible" -Tag "latest" -Interactive -Volume @(
        "$(Get-DockerMountPoint $PWD):/etc/ansible"
        "$(Get-DockerMountPoint "D:/ssh/"):/root/.ssh"
      ) -Entrypoint "/bin/bash"

$
```

This example spins up a new ansible control node container and maps the configuration and ssh volumes and the executes a bash shell.

## PARAMETERS

### -AdditionalArgs

Specify addition argument to pass to the docker executable.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Command

Override the default CMD of the image.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EntryPoint

Override the default ENTRYPOINT of the image.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EntryScript

Specify a script file to be mounted in container and override the default ENTRYPOINT.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnvironmentVariables

Specify the environment variables to pass to container.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: env

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HostName

Specify the container host name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Image

Specify the name of the image to use.

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

### -Interactive

Stay attached to the container after starting.

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

### -Keep

Specifies to not remove the container when it exits.

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

### -Name

Assign a name to the container.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReadOnly

Mount the container's root filesystem as read only.

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

### -Tag

Specify the image tag to use for the container.

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

### -Volume

Specify the list of volume mounts for the container.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
