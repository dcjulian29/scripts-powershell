---
external help file: Powershell-help.xml
Module Name: Powershell
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/Powershell/docs/Update-MyPublishedModules.md
schema: 2.0.0
---

# Update-MyPublishedModules

## SYNOPSIS

Update the list of my published modules and install or update them.

## SYNTAX

```powershell
Update-MyPublishedModules [-Verbose]
```

## DESCRIPTION

The Update-MyPublishedModules cmdlet will download the lastest list of my published modules from my chocolatey repository and then install or update any modules in that list.

## EXAMPLES

### Example 1

```powershell
PS C:\> Update-MyPublishedModules

```

This example downloads the latest list and installs or updates them.

## PARAMETERS

### -Verbose

Displays detailed information about the operation done by the command. This information resembles the information in a trace or in a transaction log.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```
