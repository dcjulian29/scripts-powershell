---
external help file: PSModules-help.xml
Module Name: PSModules
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PSModules/docs/Reset-Module.md
schema: 2.0.0
---

# Reset-Module

## SYNOPSIS

Unload a Powershell module loaded into the current session.

## SYNTAX

```powershell
Reset-Module [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION

The Reset-Module command unloads a module if it is loaded within the current Powershell session.

## EXAMPLES

### Example 1

```powershell
PS C:\> Reset-Module -Name Powershell
```

This example unloads the Powershell module if it is loaded.

## PARAMETERS

### -Name

Specifies the name of the module.

```yaml
Type: String
Parameter Sets: (All)
Aliases: ModuleName

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
