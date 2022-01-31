---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Pop-DockerImage.md
schema: 2.0.0
---

# Pop-DockerImage

## SYNOPSIS

Pull an Docker image from a registry.

## SYNTAX

```powershell
Pop-DockerImage [-Name] <String> [[-Tag] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Pop-DockerImage function is a basic wrapper around the docker pull command but allows the Name and Tag to be separate parmeters.

## EXAMPLES

### Example 1

```powershell
PS C:\> Pop-DockerImage -Name "ubuntu" -Tag "22.04"

22.04: Pulling from library/ubuntu
25f4cd1d54a5: Pull complete
Digest: sha256:0ad36748089181d832164977bdeb56d08672e352173127d8bfcd9aa4f7b3bd41
Status: Downloaded newer image for ubuntu:22.04
docker.io/library/ubuntu:22.04
```

This example pulls the ubuntu image with the 22.04 tag.

## PARAMETERS

### -Name

Specify the name of the Docker image.

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

### -Tag

Specify the tag of the Docker image.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
