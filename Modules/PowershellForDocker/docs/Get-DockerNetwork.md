---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Get-DockerNetwork.md
schema: 2.0.0
---

# Get-DockerNetwork

## SYNOPSIS

List Docker networks.

## SYNTAX

```powershell
Get-DockerNetwork [[-Name] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Get-DockerNetwork function list docker networks.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-DockerNetwork

Id                                                               Name              Driver Scope
--                                                               ----              ------ -----
c6471619c507663f823f87c3fd72b42486a727d8a4c9544f66bc5ce5df760c6d bridge            bridge local
82df2171ed78ade718b6695627646076fdbcb2a5510d6334401eb1482622025a dokuwiki_default  bridge local
0fbb0d764be7ee2b1ca1717f15a34d71f78d6574e4b1b29b1badb38c43a7d52d host              host   local
71d314f064f61a846875cee608e66a689c2b8a249c8de8ca8f0acac76acb237f httpd_default     bridge local
f7b8121e978d934162d5fc77d9baf5028a7015b281ad48c4c3c9ea708f686f42 none              null   local
679101f3e46b4c73b594a5cc61d67662b16ce4a878a10e4c2870927488db3189 portainer_default bridge local
be2dcf0d72b7d95c5374e0da44ceea0c504e89b098a8a46474b64cb917883066 testnet           bridge local
```

This example shows all of the current Docker networks.

### Example 2

```powershell
PS C:\> Get-DockerNetwork -Name bridge

Name       : bridge
Id         : c6471619c507663f823f87c3fd72b42486a727d8a4c9544f66bc5ce5df760c6d
Created    : 2022-01-28T15:15:41.1203145Z
Scope      : local
Driver     : bridge
EnableIPv6 : False
IPAM       : @{Driver=default; Options=; Config=System.Object[]}
Internal   : False
Attachable : False
Ingress    : False
ConfigFrom : @{Network=}
ConfigOnly : False
Containers :
Options    : @{com.docker.network.bridge.default_bridge=true; com.docker.network.bridge.enable_icc=true;
             com.docker.network.bridge.enable_ip_masquerade=true; com.docker.network.bridge.host_binding_ipv4=0.0.0.0;
             com.docker.network.bridge.name=docker0; com.docker.network.driver.mtu=1500}
Labels     :
```

This example shows the details of the Docker network named `bridge`.

## PARAMETERS

### -Name

Specify the name of the Docker network.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
