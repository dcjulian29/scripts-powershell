---
external help file: WebCredential-help.xml
Module Name: WebCredential
online version:
schema: 2.0.0
---

# Set-WebCredential

## SYNOPSIS

Replace or create the user credentials with a new one.

## SYNTAX

### UserPass (Default)

```powershell
Set-WebCredential [-Name] <String> [-Username] <String> [-Password] <Object> [<CommonParameters>]
```

### Credential

```powershell
Set-WebCredential [-Name] <String> [-Credential] <PSCredential> [<CommonParameters>]
```

## DESCRIPTION

Set-WebCredential is a Powershell cmdlet for using the Windows OS
credential manager to securely store a username and password.

## EXAMPLES

### Example 1

```powershell
PS C:\> Set-WebCredential -Name "test" -User "User1" -Password "password123"
```

This example runs the command to set User1's username and password in
the Web Credential Store in the Windows operating system.

## PARAMETERS

### -Credential

Gets the credentials of the account to authenticate.

```yaml
Type: PSCredential
Parameter Sets: Credential
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

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

### -Password

New password to be applied to the store.

```yaml
Type: Object
Parameter Sets: UserPass
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Username

The user name associated with the credentials.

```yaml
Type: String
Parameter Sets: UserPass
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
