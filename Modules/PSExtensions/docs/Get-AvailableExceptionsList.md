---
external help file: PSExtensions-help.xml
Module Name: PSExtensions
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PSExtensions/docs/Get-AvailableExceptionsList.md
schema: 2.0.0
---

# Get-AvailableExceptionsList

## SYNOPSIS

Get a list of Exception classes available from the currently loaded assemblies.

## SYNTAX

```powershell
Get-AvailableExceptionsList [<CommonParameters>]
```

## DESCRIPTION

The Get-AvailableExceptionsList scans each loaded assembly for class names that end with the word Exception.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-AvailableExceptionsList

Microsoft.CSharp.RuntimeBinder.RuntimeBinderException
Microsoft.CSharp.RuntimeBinder.RuntimeBinderInternalCompilerException
Microsoft.Management.Infrastructure.CimException
Microsoft.PowerShell.Cmdletization.Cim.CimJobException
Microsoft.PowerShell.Commands.CertificateNotFoundException
Microsoft.PowerShell.Commands.CertificateProviderItemNotFoundException
Microsoft.PowerShell.Commands.CertificateStoreLocationNotFoundException
Microsoft.PowerShell.Commands.CertificateStoreNotFoundException
Microsoft.PowerShell.Commands.HelpCategoryInvalidException
Microsoft.PowerShell.Commands.HelpNotFoundException
Microsoft.PowerShell.Commands.HttpResponseException
Microsoft.PowerShell.Commands.ProcessCommandException
Microsoft.PowerShell.Commands.RestartComputerTimeoutException
Microsoft.PowerShell.Commands.ServiceCommandException
Microsoft.PowerShell.Commands.WriteErrorException
Microsoft.PowerShell.CrossCompatibility.CompatibilityAnalysisException
Microsoft.VisualBasic.FileIO.MalformedLineException
Newtonsoft.Json.JsonException
Newtonsoft.Json.JsonReaderException
Newtonsoft.Json.JsonSerializationException
Newtonsoft.Json.JsonWriterException
Newtonsoft.Json.Schema.JsonSchemaException
System.AccessViolationException
System.AggregateException
System.AppDomainUnloadedException
System.ApplicationException
System.ArgumentException
System.ArgumentNullException
System.ArgumentOutOfRangeException
System.ArithmeticException
System.ArrayTypeMismatchException
System.BadImageFormatException

...

System.Threading.ThreadAbortException
System.Threading.ThreadInterruptedException
System.Threading.ThreadStartException
System.Threading.ThreadStateException
System.Threading.WaitHandleCannotBeOpenedException
System.TimeoutException
System.TimeZoneNotFoundException
System.TypeAccessException
System.TypeInitializationException
System.TypeLoadException
System.TypeUnloadedException
System.UnauthorizedAccessException
System.UriFormatException
System.Xml.Schema.XmlSchemaException
System.Xml.Schema.XmlSchemaInferenceException
System.Xml.Schema.XmlSchemaValidationException
System.Xml.XmlException
System.Xml.XPath.XPathException
System.Xml.Xsl.XsltCompileException
System.Xml.Xsl.XsltException
```

This example returns the current available exception types.

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
