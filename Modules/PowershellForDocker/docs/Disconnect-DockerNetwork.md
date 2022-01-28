---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Disconnect-DockerNetwork.md
schema: 2.0.0
---

# Disconnect-DockerNetwork

## SYNOPSIS

Disconnect a container to a network.

## SYNTAX

```powershell
Disconnect-DockerNetwork [-NetworkName] <String> [-ContainerName] <String> [-Force] [<CommonParameters>]
```

## DESCRIPTION

The Disconnect-DockerNetwork function disconnect the specified docker-based network for the specified container.

## EXAMPLES

### Example 1

```powershell
PS C:\> Disconnect-DockerNetwork -NetworkName "testnet" -ContainerName "c760a7b628ba"

```

This example disconnects the testnet network from the identified container.

## PARAMETERS

### -ContainerName

Specifies the UUID identifier or container name that the Docker daemon uses to identify the container.

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

### -Force

Instruct Docker to force the removal of the network.

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

### -NetworkName

Specifies the name of the docker-based network to disconnect from.

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
