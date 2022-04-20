---
external help file: PSExtensions-help.xml
Module Name: PSExtensions
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PSExtensions/docs/Test-PowershellVerb.md
schema: 2.0.0
---

# Test-PowershellVerb

## SYNOPSIS

Test if a verb is an approved Powershell verb.

## SYNTAX

```powershell
Test-PowershellVerb [-Verb] <String> [<CommonParameters>]
```

## DESCRIPTION

The Test-PowershellVerb is a way to test if the specified verb is on the approved list. While Powershell doesn't prevent someone from using a non-approved verb in cmdlets, it does generate warnings when imported.

## EXAMPLES

### Example 1

```powershell
PS C:\> Test-PowershellVerb -Verb Get
True
```

This example returns true because 'get' is an approved Powershell verb.

### Example 2

```powershell
PS C:\> Test-PowershellVerb -Verb Unload
False
```

This example returns false because 'unload' is not an approved Powershell verb.

## PARAMETERS

### -Verb

Specifies the name of the Powershell verb to test.

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

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
