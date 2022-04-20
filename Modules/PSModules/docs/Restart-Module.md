---
external help file: PSModules-help.xml
Module Name: PSModules
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/Powershell/docs/Restart-Module.md
schema: 2.0.0
---

# Restart-Module

## SYNOPSIS

Import a Powershell module after unloading it if it is loaded.

## SYNTAX

```powershell
Restart-Module [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION

The Restart-Module cmdlet will unload a Powershell module with the same name before attempting to import the specified module.

## EXAMPLES

### Example 1

```powershell
PS C:\> Restart-Module -Name Powershell
```

This example will unload the module, if loaded, before importing the module.

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
