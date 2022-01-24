---
external help file: Powershell-help.xml
Module Name: Powershell
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/Powershell/docs/Test-IsNonInteractive.md
schema: 2.0.0
---

# Test-IsNonInteractive

## SYNOPSIS

Test if the current Powershell session is non-interactive.

## SYNTAX

```powershell
Test-IsNonInteractive
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

### None
