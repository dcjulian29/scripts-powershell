---
external help file: VirtualDevelopment-help.xml
Module Name: VirtualDevelopment
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/VirtualDevelopment/docs/Install-DevVmPackage.md
schema: 2.0.0
---

# Install-DevVmPackage

## SYNOPSIS

Install a chocolatey package in a Development VM.

## SYNTAX

```powershell
Install-DevVmPackage [-Package] <String> [-DebugVerbose] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet installs a Chocolatey package in a Development VM with logging. It is designed to run meta-packages that install the entire system.

## EXAMPLES

### Example 1

```powershell
PS C:\> Install-DevVmPackage -Package "mytools-scm"

Transcript started, output file is C:\etc\log\20220118_190837-HOSTMACHINEDEV-mytools-scm.log
Chocolatey v0.12.0
Installing the following packages:
mytools-scm
By installing, you accept licenses for the packages.

git.install v2.34.1
git.install package files install completed. Performing other installation steps.
Using Git LFS
Installing 64-bit git.install...
git.install has been installed.
WARNING: Can't find git.install install location
  git.install can be automatically uninstalled.
Environment Vars (like PATH) have changed. Close/reopen your shell to
 see the changes (or in powershell/cmd.exe just type `refreshenv`).
 The install of git.install was successful.
  Software installed to 'C:\Program Files\Git\'

git v2.34.1
git package files install completed. Performing other installation steps.
 The install of git was successful.
  Software installed to 'C:\ProgramData\chocolatey\lib\git'

mysettings-git v2201.14.1
mysettings-git package files install completed. Performing other installation steps.

...

mytools-scm v2111.26.1
mytools-scm package files install completed. Performing other installation steps.
 The install of mytools-scm was successful.
  Software installed to 'C:\ProgramData\chocolatey\lib\mytools-scm'

Chocolatey installed 11/11 packages.
 See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).

Installed:
 - dotnet4.6.1 v4.6.01055.20170308
 - lazygit v0.32.1
 - mysettings-winmerge v2019.12.27.1
 - winmerge v2.16.16
 - mytools-scm v2111.26.1
 - mysettings-git v2201.14.1
 - git.install v2.34.1
 - gitextensions v3.5.4
 - poshgit v0.7.3.1
 - mysettings-gitextensions v2020.5.7.1
 - git v2.34.1

Enjoy using Chocolatey? Explore more amazing features to take your
experience to the next level at
 https://chocolatey.org/compare
Transcript stopped, output file is C:\etc\log\20220118_190837-HOSTMACHINEDEV-mytools-scm.log
```

This example installs the 'mytools-scm' meta-package.

## PARAMETERS

### -DebugVerbose

Pass the 'debug' and 'verbose' flags to Chocolatey.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: dv

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Package

Specify the name of the Chocolatey package.

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
