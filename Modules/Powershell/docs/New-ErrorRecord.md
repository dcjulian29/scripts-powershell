---
external help file: Powershell-help.xml
Module Name: Powershell
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/Powershell/docs/New-ErrorRecord.md
schema: 2.0.0
---

# New-ErrorRecord

## SYNOPSIS

Create a new Error Record.

## SYNTAX

### Message (Default)

```powershell
New-ErrorRecord [-Message] <String> [-ExceptionType] <String> [-ErrorId] <String>
 [-ErrorCategory] <ErrorCategory> [[-TargetObject] <Object>] [-InnerException <Exception>] [<CommonParameters>]
```

### Exception

```powershell
New-ErrorRecord [-ErrorId] <String> [-ErrorCategory] <ErrorCategory> [[-TargetObject] <Object>]
 [-Exception] <Exception> [<CommonParameters>]
```

## DESCRIPTION

The New-ErrorRecord cmdlet wraps an exception into a Powershell Error Record.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-ErrorRecord -Message "New Error Record" -ExceptionType "System.Exception" -ErrorId "EX01" -ErrorCategory NotSpecified

New Error Record
    + CategoryInfo          : NotSpecified: (:) [], Exception
    + FullyQualifiedErrorId : EX01
```

This example produces a new error record based on the message provided.

### Example 2

```powershell
PS C:\> New-ErrorRecord -Exception $(New-Object System.Exception) -ErrorId "4567" -ErrorCategory NotSpecified

Exception of type 'System.Exception' was thrown.
    + CategoryInfo          : NotSpecified: (:) [], Exception
    + FullyQualifiedErrorId : 4567
```

This example produces a new error record base on the exception provided.

## PARAMETERS

### -ErrorCategory

Information regarding the ErrorCategory associated with this error, and with the categorized error message for that ErrorCategory.

```yaml
Type: ErrorCategory
Parameter Sets: (All)
Aliases: Category
Accepted values: NotSpecified, OpenError, CloseError, DeviceError, DeadlockDetected, InvalidArgument, InvalidData, InvalidOperation, InvalidResult, InvalidType, MetadataError, NotImplemented, NotInstalled, ObjectNotFound, OperationStopped, OperationTimeout, SyntaxError, ParserError, PermissionDenied, ResourceBusy, ResourceExists, ResourceUnavailable, ReadError, WriteError, FromStdErr, SecurityError

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ErrorId

String which uniquely identifies this error condition.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Id

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exception

An Exception describing the error.

```yaml
Type: Exception
Parameter Sets: Exception
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExceptionType

Human-readable text that describes the error.

```yaml
Type: String
Parameter Sets: Message
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InnerException

The Exception instance that caused the current exception.

```yaml
Type: Exception
Parameter Sets: Message
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Message

The message that describes the current exception.

```yaml
Type: String
Parameter Sets: Message
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetObject

This is the object against which the cmdlet or provider was operating when the error occurred. This is optional.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
