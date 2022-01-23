---
external help file: Powershell-help.xml
Module Name: Powershell
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/Powershell/docs/Import-Assembly.md
schema: 2.0.0
---

# Import-Assembly

## SYNOPSIS

Import a .Net Assembly.

## SYNTAX

```powershell
Import-Assembly [[-Assembly] <String>]
```

## DESCRIPTION

The Import-Assembly imports a .Net assembly based on the name of the assembly file or the name of assembly if loading from GAC.

## EXAMPLES

### Example 1

```powershell
PS C:\> Import-Assembly -Assembly "System.Text"

```

This example imports the System.Text assembly from the GAC.

## PARAMETERS

### -Assembly

Specifies the name of the assembly file or the name of assembly if loading from GAC.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```
