---
external help file: PowershellForAnsible-help.xml
Module Name: PowershellForAnsible
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForAnsible/docs/Export-AnsibleFacts.md
schema: 2.0.0
---

# Export-AnsibleFacts

## SYNOPSIS

Export a host's Ansible facts.

## SYNTAX

```powershell
Export-AnsibleFacts [[-ComputerName] <String>] [[-InventoryFile] <String>]
```

## DESCRIPTION

The Export-AnsibleFacts function export a host's Ansible facts to a JSON file. These files can then be used by any tool that understands JSON to work with the facts.

## EXAMPLES

### Example 1

```powershell
PS C:\> Export-AnsibleFacts -ComputerName kibana
```

This example exports the facts of the host named kibana.

## PARAMETERS

### -ComputerName

Specify the name of the host.

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

### -InventoryFile

Specify the path to the inventory file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```
