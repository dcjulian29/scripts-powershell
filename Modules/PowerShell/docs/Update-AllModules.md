---
external help file: Powershell-help.xml
Module Name: Powershell
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/Powershell/docs/Update-AllModules.md
schema: 2.0.0
---

# Update-AllModules

## SYNOPSIS

Update all modules that can be updated.

## SYNTAX

```powershell
Update-AllModules
```

## DESCRIPTION

The Update-AllModules wraps Update-InstalledModules and Update-MyModules to update all available modules that can be updated.

## EXAMPLES

### Example 1

```powershell
PS C:\> Update-AllModules

Updating third-party Powershell modules...


Updating my Powershell modules...

```

This example updated both installed modules and my modules.

## PARAMETERS

### None
