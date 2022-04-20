---
external help file: PSExtensions-help.xml
Module Name: PSExtensions
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PSExtensions/docs/Search-Command.md
schema: 2.0.0
---

# Search-Command

## SYNOPSIS

Display a list of matching commands.

## SYNTAX

```powershell
Search-Command [-Filter] <String> [<CommonParameters>]
```

## DESCRIPTION

The Search-Command cmdlet will search for a command that matches a filter. Sometimes it is helpful to search for a part of a cmdlet's name when you can't remember the exact spelling of the cmdlet.

## EXAMPLES

### Example 1

```powershell
PS C:\> Search-Command -Filter "Assert-"

Name                   Version Source
----                   ------- ------
Assert-Elevation       0.0     Elevation
Assert-MockCalled      3.4.0   Pester
Assert-PSRule          1.11.0  PSRule
Assert-VerifiableMocks 3.4.0   Pester
```

This example shows all available commands that start with 'Assert-'.

### Example 2

```powershell
PS C:\> Search-Command -Filter "container"

Name                                        Version Source
----                                        ------- ------
Add-AppProvisionedSharedPackageContainer    3.0     Dism
Add-AppSharedPackageContainer               2.0.1.0 Appx
Add-ProvisionedAppSharedPackageContainer    3.0     Dism
Get-AppProvisionedSharedPackageContainer    3.0     Dism
Get-AppSharedPackageContainer               2.0.1.0 Appx
Get-ProvisionedAppSharedPackageContainer    3.0     Dism
Get-PveContainerStatus                      0.0     Proxmox
New-HTMLContainer                           0.0.164 PSWriteHTML
Remove-AppProvisionedSharedPackageContainer 3.0     Dism
Remove-AppSharedPackageContainer            2.0.1.0 Appx
Remove-ProvisionedAppSharedPackageContainer 3.0     Dism
Reset-AppSharedPackageContainer             2.0.1.0 Appx
```

This example shows all available commands that contain the word 'container'.

## PARAMETERS

### -Filter

Specify a filter to look for.

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

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
