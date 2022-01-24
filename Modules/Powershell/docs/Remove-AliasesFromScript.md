---
external help file: Powershell-help.xml
Module Name: Powershell
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/Powershell/docs/Remove-AliasesFromScript.md
schema: 2.0.0
---

# Remove-AliasesFromScript

## SYNOPSIS

Remove Powershell aliases from a script file.

## SYNTAX

```powershell
Remove-AliasesFromScript [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION

The Remove-AliasesFromScript allows you to quickly create a Powershell script containing aliases and then remove them and replace them with the cmdlet names.

## EXAMPLES

### Example 1

```powershell
PS C:\> Remove-AliasesFromScript -Path test1.ps1

Replacing 'gci' with 'Get-ChildItem'...
Replacing '%' with 'ForEach-Object'...
```

This example replaces any Powershell aliases with their equivalent Powershell command.

## PARAMETERS

### -Path

Specifies a path to a Powershell script file.

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
