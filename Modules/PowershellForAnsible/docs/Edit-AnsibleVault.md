---
external help file: PowershellForAnsible-help.xml
Module Name: PowershellForAnsible
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForAnsible/docs/Edit-AnsibleVault.md
schema: 2.0.0
---

# Edit-AnsibleVault

## SYNOPSIS

Edit an Ansible vault.

## SYNTAX

```powershell
Edit-AnsibleVault [[-Vault] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Edit-AnsibleVault function uses the ansible-vault command to edit an Ansbile vault file.

## EXAMPLES

### Example 1

```powershell
PS C:\> Edit-AnsibleVault
```

This example edits the default secrets.yml file via ansible-vault.

## PARAMETERS

### -Vault

Specify the path the the vault YAML file.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
