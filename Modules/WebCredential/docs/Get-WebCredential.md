---
external help file: WebCredential-help.xml
Module Name: webcredential
online version:
schema: 2.0.0
---

# Get-WebCredential

## SYNOPSIS

Retrive the user credentials.

## SYNTAX

```powershell
Get-WebCredential [-Name] <String> [-SecurePassword] [-Password] [-Username] [<CommonParameters>]
```

## DESCRIPTION

Get-WebCredential is a Powershell cmdlet for using the Windows OS
credential manager to securely retrieving a username and password.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-WebCredential -Name "test"

UserName                     Password
--------                     --------
User1    System.Security.SecureString
```

This example returns a PSCredential object representing the user's name and password.

### Example 2

```powershell
PS C:\> Get-WebCredential -Name "test" -SecurePassword
System.Security.SecureString
```

This example returns just the password as an secure string.

### Example 3

```powershell
PS C:\> Get-WebCredential -Name "test" -Password
password123
```

This example returns just the password as an insecure string.

### Example 4

```powershell
PS C:\> Get-WebCredential -Name "test" -Username
User1
```

This example returns just the user name as a string.

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

### -Password

Return the password for the user name associated with the credentials

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

### -SecurePassword

Return the password for the user name associated with the credentials
as a SecureString instance.

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

### -Username

Return the user name associated with the credentials.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
