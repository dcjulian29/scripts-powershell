---
external help file: PSExtensions-help.xml
Module Name: PSExtensions
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PSExtensions/docs/Get-Profile.md
schema: 2.0.0
---

# Get-Profile

## SYNOPSIS

Get the contents of the currently loaded profile script.

## SYNTAX

```powershell
Get-Profile [<CommonParameters>]
```

## DESCRIPTION

The Get-Profile cmdlet returns the contents of the currently loaded profile script.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-Profile

function prompt {
  ...
}
```

This example shows the contents of the currently loaded profile script.

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
