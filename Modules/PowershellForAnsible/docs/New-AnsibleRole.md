---
external help file: PowershellForAnsible-help.xml
Module Name: PowershellForAnsible
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForAnsible/docs/New-AnsibleRole.md
schema: 2.0.0
---

# New-AnsibleRole

## SYNOPSIS

Create the directory structure for a new Ansible role.

## SYNTAX

```powershell
New-AnsibleRole [-Role] <String> [-Force] [<CommonParameters>]
```

## DESCRIPTION

The New-AnsibleRole creates the directory structure and place-holder files for a new Ansible role.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-AnsibleRole -Role "NewTestRole" -Verbose

VERBOSE: Role Path: D:\ansible\roles\NewTestRole
VERBOSE: Creating directory for defaults...
VERBOSE: Creating directory for files...
VERBOSE: Creating directory for handlers...
VERBOSE: Creating directory for meta...
VERBOSE: Creating directory for tasks...
VERBOSE: Creating directory for templates...
VERBOSE: Creating directory for vars...
VERBOSE: Creating template for defaults...
VERBOSE: Creating readme for files...
VERBOSE: Creating template for handlers...
VERBOSE: Creating template for meta...
VERBOSE: Creating template for tasks...
VERBOSE: Creating readme for templates...
VERBOSE: Creating template for variables...
Role 'NewTestRole' created.
```

This example creates the NewTestRole Ansible role.

## PARAMETERS

### -Force

Specify that the directory should be removed prior to new role being created.

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

### -Role

Specify the name of the Ansible role.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
