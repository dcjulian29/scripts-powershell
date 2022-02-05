---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Get-FilePathForContainer.md
schema: 2.0.0
---

# Get-FilePathForContainer

## SYNOPSIS

Get a file path that Docker can use for mounting a volume.

## SYNTAX

```powershell
Get-FilePathForContainer [-Path] <String> [-MustBeChild] [<CommonParameters>]
```

## DESCRIPTION

The Get-FilePathForContainer function gets a file path that Docker can use for mounting a volume. While similar to the Get-PathForContainer function, this function limits the operation to a file and will generate an error if the path doesn't point to a file.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-PathForContainer .\d8c927966343e5fd6d2627f7999b82c9 -MustBeChild

./d8c927966343e5fd6d2627f7999b82c9
```

This example returns the relative path to the specified child item.

### Example 2

```powershell
PS C:\> Get-FilePathForContainer .\d8c927966343e5fd6d2627f7999b82c9\

Get-FilePathForContainer : File does not exists or object is not a file!
At line:1 char:1
+ Get-FilePathForContainer .\d8c927966343e5fd6d2627f7999b82c9\
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (:) [Get-FilePathForContainer], ItemNotFoundException
    + FullyQualifiedErrorId : ResourceUnavailable,Get-FilePathForContainer
```

This example returns an error because the specified item was not a file.

## PARAMETERS

### -MustBeChild

Specifies that the file must be in the current directory or a child directory and to return a relative path to it.

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

Specify the path to a file.

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
