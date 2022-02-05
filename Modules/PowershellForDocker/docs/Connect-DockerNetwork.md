---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Connect-DockerNetwork.md
schema: 2.0.0
---

# Connect-DockerNetwork

## SYNOPSIS

Connect a container to a network.

## SYNTAX

```powershell
Connect-DockerNetwork [-NetworkName] <String> [-ContainerName] <String> [[-IPv4] <String>] [[-IPv6] <String>]
 [[-Aliases] <String[]>] [<CommonParameters>]
```

## DESCRIPTION

The Connect-DockerNetwork function connect a container to a preexisting docker-based network and assigns the IP Address for the network interface for that container.

## EXAMPLES

### Example 1

```powershell
PS C:\> Connect-DockerNetwork -NetworkName "testnet" -ContainerName "c760a7b628ba" -IPv4 172.16.88.20

```

This example connects the specify container to the testnet network and assign the IP address.

## PARAMETERS

### -Aliases

Specifies the network-scoped aliases for the container.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

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

### -IPv4

Specifies the IPv4 address. (example: 172.30.100.104)

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

### -IPv6

Specifies the IPv6 address. (example: 2001:db8::33)


```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NetworkName

Specifies the name of the docker-based network to connect to.

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
