---
external help file: PSExtensions-help.xml
Module Name: PSExtensions
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PSExtensions/docs/Test-IsNonInteractive.md
schema: 2.0.0
---

# Test-IsNonInteractive

## SYNOPSIS

Test if the current Powershell session is non-interactive.

## SYNTAX

```powershell
Test-IsNonInteractive [<CommonParameters>]
```

## DESCRIPTION

The Test-IsNonInteractive cmdlet will test if the powershell session is non-interactive or launched as a interactive process.

## EXAMPLES

### Example 1

```powershell
PS C:\> Test-IsNonInteractive
False
```

This example returns false when executed from a Powershell console host.

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
