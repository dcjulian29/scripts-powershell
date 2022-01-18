---
external help file: WebCredential-help.xml
Module Name: WebCredential
online version:https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/WebCredential/docs/Remove-WebCredential.md
schema: 2.0.0
---

# Remove-WebCredential

## SYNOPSIS

Removes named credentials.

## SYNTAX

```powershell
Remove-WebCredential [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION

Remove-WebCredential is a Powershell cmdlet for using the Windows OS credential manager to remove a username and password credential.

## EXAMPLES

### Example 1

```powershell
PS C:\> Remove-WebCredential -Name "test"
```

This example runs the command to remove User1's username and password in
the Web Credential Store in the Windows operating system identified by
the name "test".

## PARAMETERS

### -Name

The name of the resource containing the credential.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
