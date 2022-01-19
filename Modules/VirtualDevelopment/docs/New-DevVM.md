---
external help file: VirtualDevelopment-help.xml
Module Name: VirtualDevelopment
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/VirtualDevelopment/docs/New-DevVM.md
schema: 2.0.0
---

# New-DevVM

## SYNOPSIS

Create a Development VM.

## SYNTAX

```powershell
New-DevVM
```

## DESCRIPTION

The New-DevVM cmdlet creates a VM based on the Host machine's name using the latest Windows Insiders base disk.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-DevVM

Creating a Differencing Disk [HOSTMACHINEDEV.vhdx] based on [C:\Virtual Machines\Discs\base\Win11BaseInsider-10.0.22533.vhdx]

ComputerName            : HOSTMACHINE
Path                    : C:\Virtual Machines\Discs\HOSTMACHINEDEV.vhdx
VhdFormat               : VHDX
VhdType                 : Differencing
FileSize                : 4194304
Size                    : 107374182400
MinimumSize             : 107373150720
LogicalSectorSize       : 512
PhysicalSectorSize      : 4096
BlockSize               : 2097152
ParentPath              : C:\Virtual Machines\Discs\base\Win11BaseInsider-10.0.22533.vhdx
DiskIdentifier          : B87479B3-E57C-4029-BE23-F9CD995E325B
FragmentationPercentage :
Alignment               : 1
Attached                : False
DiskNumber              :
IsPMEMCompatible        : False
AddressAbstractionType  : None
Number                  :

Creating HOSTMACHINEDEV VM...

Name             : HOSTMACHINEDEV
State            : Off
CpuUsage         : 0
MemoryAssigned   : 0
MemoryDemand     : 0
MemoryStatus     :
Uptime           : 00:00:00
Status           : Operating normally
ReplicationState : Disabled
Generation       : 2
```

This example creates the Development VM based on the host computer's name.

## PARAMETERS

### None
