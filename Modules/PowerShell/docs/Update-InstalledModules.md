---
external help file: Powershell-help.xml
Module Name: Powershell
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/Powershell/docs/Update-InstalledModules.md
schema: 2.0.0
---

# Update-InstalledModules

## SYNOPSIS

Update, if available, modules installed via a repository.

## SYNTAX

```powershell
Update-InstalledModules
```

## DESCRIPTION

The Update-InstalledModules cmdlet updates modules installed via a repository. If an update is not available, nothing is done.

## EXAMPLES

### Example 1

```powershell
PS C:\> Update-InstalledModules

```

This example updates all of the installed modules.

## PARAMETERS

### -Verbose

Displays detailed information about the operation done by the command. This information resembles the information in a trace or in a transaction log.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: None

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```
