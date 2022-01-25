---
external help file: Powershell-help.xml
Module Name: Powershell
online version:https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/Powershell/docs/Update-MyThirdPartyModules.md
schema: 2.0.0
---

# Update-MyThirdPartyModules

## SYNOPSIS

Update the list of installed third-party modules and install or update them.

## SYNTAX

```powershell
Update-MyThirdPartyModules [-Verbose]
```

## DESCRIPTION

The Update-MyThirdPartyModules cmdlet will download the lastest list of third-party modules from my chocolatey repository and then install or update any modules in that list.

## EXAMPLES

### Example 1

```powershell
PS C:\> Update-MyThirdPartyModules

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
