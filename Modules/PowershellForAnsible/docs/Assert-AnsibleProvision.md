---
external help file: PowershellForAnsible-help.xml
Module Name: PowershellForAnsible
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForAnsible/docs/Assert-AnsibleProvision.md
schema: 2.0.0
---

# Assert-AnsibleProvision

## SYNOPSIS

Run the provision playbook in check mode.

## SYNTAX

```powershell
Assert-AnsibleProvision [-ComputerName] <String> [<CommonParameters>]
```

## DESCRIPTION

The Assert-AnsibleProvision runs a provisioning playbook in check mode. This can be used to determine if the provisioned server has drifted from the playbook.

## EXAMPLES

### Example 1

```powershell
PS C:\> Assert-AnsibleProvision
```

This example start the check process.

## PARAMETERS

### -ComputerName

Specify the name of the provisioned server.

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
