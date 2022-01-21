---
external help file: VirtualDevelopment-help.xml
Module Name: VirtualDevelopment
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/VirtualDevelopment/docs/New-LinuxDevVM.md
schema: 2.0.0
---

# New-LinuxDevVM

## SYNOPSIS

Create a Development Linux VM.

## SYNTAX

### Default (Default)

```powershell
New-LinuxDevVM [-IsoFilePath <String>] [<CommonParameters>]
```

### Ubuntu

```powershell
New-LinuxDevVM [-UseUbuntu] [<CommonParameters>]
```

### Xubuntu

```powershell
New-LinuxDevVM [-UseXubuntu] [<CommonParameters>]
```

### LinuxMint

```powershell
New-LinuxDevVM [-UseMint] [<CommonParameters>]
```

## DESCRIPTION

The New-DevVM cmdlet creates a Linux-based VM based on the Host machine's name using the specified ISO file. You can also specify some distributions to search and use that.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-LinuxDevVM

ComputerName            : HOSTNAME
Path                    : C:\Virtual Machines\Discs\HOSTNAMELNXDEV.vhdx
VhdFormat               : VHDX
VhdType                 : Dynamic
FileSize                : 4194304
Size                    : 85899345920
MinimumSize             :
LogicalSectorSize       : 512
PhysicalSectorSize      : 4096
BlockSize               : 33554432
ParentPath              :
DiskIdentifier          : F892C578-7DA2-4605-916D-29A91FEA3C97
FragmentationPercentage : 0
Alignment               : 1
Attached                : False
DiskNumber              :
IsPMEMCompatible        : False
AddressAbstractionType  : None
Number                  :

Name             : HOSTNAMELNXDEV
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

This example creates a Linux DevVM using the latest Pop-OS file in the ISO storage folder.

### Example 2

```powershell
PS C:\> New-LinuxDevVM -UseMint


ComputerName            : HOSTNAME
Path                    : C:\Virtual Machines\Discs\HOSTNAMELNXDEV.vhdx
VhdFormat               : VHDX
VhdType                 : Dynamic
FileSize                : 4194304
Size                    : 85899345920
MinimumSize             :
LogicalSectorSize       : 512
PhysicalSectorSize      : 4096
BlockSize               : 33554432
ParentPath              :
DiskIdentifier          : 0E521B93-9EB2-4EC2-AB78-003A44E99044
FragmentationPercentage : 0
Alignment               : 1
Attached                : False
DiskNumber              :
IsPMEMCompatible        : False
AddressAbstractionType  : None
Number                  :

Name             : HOSTNAMELNXDEV
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

This example creates a Linux DevVM using the latest Mint Linux file in the ISO storage folder.

## PARAMETERS

### -IsoFilePath

Specifies the path to an ISO file to use to attach to VM.

```yaml
Type: String
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseMint

Search the ISO storage folder for Mint Linux ISO and use that to attach to the VM.

```yaml
Type: SwitchParameter
Parameter Sets: LinuxMint
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseUbuntu

Search the ISO storage folder for Ubuntu Desktop Linux ISO and use that to attach to the VM.

```yaml
Type: SwitchParameter
Parameter Sets: Ubuntu
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseXubuntu

Search the ISO storage folder for Xbuntu Linux ISO and use that to attach to the VM.

```yaml
Type: SwitchParameter
Parameter Sets: Xubuntu
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
