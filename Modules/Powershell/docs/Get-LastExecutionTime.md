---
external help file: Powershell-help.xml
Module Name: Powershell
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/Powershell/docs/Get-LastExecutionTime.md
schema: 2.0.0
---

# Get-LastExecutionTime

## SYNOPSIS

Return the elapsed time of the last command.

## SYNTAX

```powershell
Get-LastExecutionTime
```

## DESCRIPTION

The Get-LastExecutionTime cmdlet returns the elapsed time of the last command executed.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-LastExecutionTime

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 1
Milliseconds      : 716
Ticks             : 17161638
TotalDays         : 1.98630069444444E-05
TotalHours        : 0.000476712166666667
TotalMinutes      : 0.02860273
TotalSeconds      : 1.7161638
TotalMilliseconds : 1716.1638
```

This example returns the elapsed time of the last command.

## PARAMETERS

### None
