---
external help file: Powershell-help.xml
Module Name: Powershell
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/Powershell/docs/Get-Profile.md
schema: 2.0.0
---

# Get-Profile

## SYNOPSIS

Get the contents of the currently loaded profile script.

## SYNTAX

```powershell
Get-Profile
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

### None
