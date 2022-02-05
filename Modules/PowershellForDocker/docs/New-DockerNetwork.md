---
external help file: PowershellForDocker-help.xml
Module Name: Powershellfordocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/New-DockerNetwork.md
schema: 2.0.0
---

# New-DockerNetwork

## SYNOPSIS

Create a Docker network.

## SYNTAX

```powershell
New-DockerNetwork [-Name] <String> [[-Driver] <String>] [[-Gateway] <String>] [[-Subnet] <String>] [[-IpRange] <String>] [-Internal] [-IPv6] [<CommonParameters>]
```

## DESCRIPTION

The New-DockerNetwork function creates new Docker networks. You can let Docker control the network settings or they can be specify during creation. All networks created with this function are attachable by containers.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-DockerNetwork -Name "gatenet" -Gateway "172.16.8.1" -Subnet "172.16.8.0/24"

935ab241a7c4c47f757795290249d0d8a7aa2be125970383888e8c6c5298c502
```

This example creates a Docker bridge network.

## PARAMETERS

### -Driver

Specify the driver to manage the network. Defaults to `bridge` driver.

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

### -Gateway

Specify the IPv4 or IPv6 Gateway for the subnet.

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

### -Internal

Restrict external access to the network.

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

### -IpRange

Allocate IPs from a range.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IPv6

Enable IPv6 networking.

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

Specify the name of the Docker network.

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

### -Subnet

Specify the Subnet for network.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
