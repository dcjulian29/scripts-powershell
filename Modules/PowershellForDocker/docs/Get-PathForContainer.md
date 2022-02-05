---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Get-PathForContainer.md
schema: 2.0.0
---

# Get-PathForContainer

## SYNOPSIS

Get a path that Docker can use for mounting a volume.

## SYNTAX

```powershell
Get-PathForContainer [-Path] <String> [-MustBeChild] [<CommonParameters>]
```

## DESCRIPTION

The Get-PathForContainer function gets a path that Docker can use for mounting a volume.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-FilePathForContainer .\d8f9687d-ca2d-4e84-bbf2-079cfbe5dad5.tmp.ico

/mnt/c/Users/user/AppData/Local/Temp/d8f9687d-ca2d-4e84-bbf2-079cfbe5dad5.tmp.ico
```

This example returns an absolute path to the specified directory.

### Example 2

```powershell
PS C:\> Get-PathForContainer .\d8c927966343e5fd6d2627f7999b82c9 -MustBeChild

./d8c927966343e5fd6d2627f7999b82c9
```

This example returns a relative path to the specified child directory.

### Example 3

```powershell
PS C:\> Get-PathForContainer $env:WINDIR -MustBeChild

Get-PathForContainer : Path 'C:\WINDOWS' is not a child of the current directory!
+ Get-PathForContainer $env:WINDIR -MustBeChild
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (:) [Get-PathForContainer], ItemNotFoundException
    + FullyQualifiedErrorId : ResourceUnavailable,Get-PathForContainer
```

This example shows an error because the Windows directory is not a child directory of the current directory.

## PARAMETERS

### -MustBeChild

Specifies that the directory must be a child item and to return a relative path to it.

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

### -Path

Specify the path to a file or folder.

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
