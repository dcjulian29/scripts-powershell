---
external help file: VirtualDevelopment-help.xml
Module Name: VirtualDevelopment
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/VirtualDevelopment/docs/Update-DevVmPackages.md
schema: 2.0.0
---

# Update-DevVmPackages

## SYNOPSIS

Update all of the installed chocolatey packages and log it.

## SYNTAX

```powershell
Update-DevVmPackages [-DebugVerbose]
```

## DESCRIPTION

The Update-DevVmPackages cmdlet updates all installed chocolatey and logs it.

## EXAMPLES

### Example 1

```powershell
PS C:\> Update-DevVmPackages


Transcript started, output file is C:\etc\log\20220121_163842-HOSTNAMEDEV-upgrade.log
Chocolatey v0.12.0
Upgrading the following packages:
all
By upgrading, you accept licenses for the packages.
7zip v21.7 is the latest version available based on your source(s).
7zip.install v21.7 is the latest version available based on your source(s).
AdoptOpenJDKjre v16.0.1.900 is the latest version available based on your source(s).
baretail v3.50.0.20120226 is the latest version available based on your source(s).
chocolatey v0.12.0 is the latest version available based on your source(s).
chocolatey-core.extension v1.3.5.1 is the latest version available based on your source(s).

...

mycomputers-common v2201.8.1 is the latest version available based on your source(s).

You have mypowershell v2201.17.1 installed. Version 2201.19.1 is available based on your source(s).
Progress: Downloading mypowershell 2201.19.1... 100%

mypowershell v2201.19.1
mypowershell package files upgrade completed. Performing other installation steps.
Removing previous version of package...

Making sure all runtime assemblies are pre-compiled if necessary...
Running ngen.exe on 'mscorlib.dll'...
Running ngen.exe on 'choco.exe'...
Running ngen.exe on 'System.dll'...
Running ngen.exe on 'System.Core.dll'...

...

mytools-scm v2111.26.1 is the latest version available based on your source(s).

You have myvm-development v2201.19.4 installed. Version 2201.19.5 is available based on your source(s).
Progress: Downloading myvm-development 2201.19.5... 100%

myvm-development v2201.19.5
myvm-development package files upgrade completed. Performing other installation steps.
WARNING: Package already installed, no need to upgrade...
 The upgrade of myvm-development was successful.
  Software install location not explicitly set, it could be in package or
  default install location of installer.
myvm-workstation v2201.6.3 is the latest version available based on your source(s).
netfx-4.5.2-devpack v4.5.5165101.20180721 is the latest version available based on your source(s).

...

winmerge v2.16.16 is the latest version available based on your source(s).
xmlquire v1.17.220120 is the latest version available based on your source(s).

Chocolatey upgraded 2/123 packages.
 See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).

Upgraded:
 - mypowershell v2201.19.1
 - myvm-development v2201.19.5
Transcript stopped, output file is C:\etc\log\20220121_163842-HOSTNAMEDEV-upgrade.log
```

This example updates the installed chocolatey packages.

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
