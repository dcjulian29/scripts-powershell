---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Start-LinuxServerCommunityContainer.md
schema: 2.0.0
---

# Start-LinuxServerCommunityContainer

## SYNOPSIS

Start a [linuxserver.io](https://fleet.linuxserver.io/) image as a container.

## SYNTAX

```powershell
Start-LinuxServerCommunityContainer [-Image] <String> [[-Name] <String>] [[-Volumes] <String[]>] [[-Ports] <String[]>] [<CommonParameters>]
```

## DESCRIPTION

The Start-LinuxServerCommunityContainer function starts a [linuxserver.io](https://fleet.linuxserver.io/) image as a container.

## EXAMPLES

### Example 1

```powershell
PS C:\> Start-LinuxServerCommunityContainer -Image code-server -Ports "8000:8443"

Unable to find image 'linuxserver/code-server:latest' locally
latest: Pulling from linuxserver/code-server
965460678a8d: Pull complete
8ce3e9125882: Pull complete
2b7247a86269: Pull complete
b7af881e82cb: Pull complete
00b5a40f8145: Pull complete
96d7e89cf51e: Pull complete
af1459358d04: Pull complete
6a9a3a7734fb: Pull complete
98fd053a3550: Pull complete
Digest: sha256:223cef180487f0ed9bb96c79534681d441b663d9d4c98864b558e4601e515d56
Status: Downloaded newer image for linuxserver/code-server:latest
54efdb904ef9862b4a09402bd9b1548c8ff96889a07cca01123e349813aee736
```

This example starts a visual studio code editor container and exposes it on port 8000.

## PARAMETERS

### -Image

Specify the name of the [linuxserver.io](https://fleet.linuxserver.io/) image name.

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

### -Name

Specify the name of the container. If one is not provided a random GUID is used.

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

### -Ports

Specifies the list of port mappings.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Volumes

Specifies the list of volume mappings.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
