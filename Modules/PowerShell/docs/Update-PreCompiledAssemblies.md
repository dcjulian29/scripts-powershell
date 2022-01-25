---
external help file: Powershell-help.xml
Module Name: Powershell
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/Powershell/docs/Update-PreCompiledAssemblies.md
schema: 2.0.0
---

# Update-PreCompiledAssemblies

## SYNOPSIS

Update all of the pre-compiled assemblies.

## SYNTAX

```powershell
Update-PreCompiledAssemblies
```

## DESCRIPTION

The Update-PreCompiledAssemblies cmdlet gathers all of the loaded assemblies and runs ngen.exe on each.

## EXAMPLES

### Example 1

```powershell
PS C:\> Update-PreCompiledAssemblies
Ensuring all currently loaded runtime assemblies are pre-compiled...


Running ngen.exe on 'mscorlib.dll'...
All compilation targets are up to date.


Running ngen.exe on 'Microsoft.PowerShell.ConsoleHost.dll'...
All compilation targets are up to date.


Running ngen.exe on 'System.dll'...
All compilation targets are up to date.


Running ngen.exe on 'System.Core.dll'...
All compilation targets are up to date.

...

Running ngen.exe on 'Windows.Security.winmd'...
All compilation targets are up to date.


Running ngen.exe on 'Microsoft.HostCompute.PowerShell.Cmdlets.dll'...
2>    Compiling assembly Microsoft.HostCompute.PowerShell.Views, Version=10.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35 (CLR v4.0.30319) ...
1>    Compiling assembly C:\Windows\Microsoft.Net\assembly\GAC_64\Microsoft.HostCompute.PowerShell.Cmdlets\v4.0_10.0.0.0__31bf3856ad364e35\Microsoft.HostCompute.PowerShell.Cmdlets.dll (CLR v4.0.30319) ...
1>    Compiling assembly Microsoft.HostCompute.Interop, Version=10.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35 (CLR v4.0.30319) ...


Running ngen.exe on 'Microsoft.CertificateServices.PKIClient.Cmdlets.dll'...
All compilation targets are up to date.
```

This example updates all of the loaded assemblies pre-compile.

## PARAMETERS

### None
