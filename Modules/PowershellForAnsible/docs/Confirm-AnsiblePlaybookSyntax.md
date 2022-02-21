---
external help file: PowershellForAnsible-help.xml
Module Name: PowershellForAnsible
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForAnsible/docs/Confirm-AnsiblePlaybookSyntax.md
schema: 2.0.0
---

# Confirm-AnsiblePlaybookSyntax

## SYNOPSIS

Confirm that a playbook is syntactically correct.

## SYNTAX

```powershell
Confirm-AnsiblePlaybookSyntax [-PlaybookPath] <String> [<CommonParameters>]
```

## DESCRIPTION

The Confirm-AnsiblePlaybookSyntax function runs a syntax check on the specified playbook.

## EXAMPLES

### Example 1

```powershell
PS C:\> Confirm-AnsiblePlaybookSyntax -PlaybookPath ./playbooks/elk.yml
```

This example validates the syntax of the elk.yml playbook.

## PARAMETERS

### -PlaybookPath

Specify the path to the playbook.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path, Playbook

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
