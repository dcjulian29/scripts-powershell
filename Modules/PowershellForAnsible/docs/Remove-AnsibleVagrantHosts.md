---
external help file: PowershellForAnsible-help.xml
Module Name: PowershellForAnsible
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForAnsible/docs/Remove-AnsibleVagrantHosts.md
schema: 2.0.0
---

# Remove-AnsibleVagrantHosts

## SYNOPSIS

Remove the Vagrant VMs from the host.

## SYNTAX

```powershell
Remove-AnsibleVagrantHosts
```

## DESCRIPTION

The Remove-AnsibleVagrantHosts removes any VMs that are defined in the Vagrant file.

## EXAMPLES

### Example 1

```powershell
PS C:\> Remove-AnsibleVagrantHosts

==> fedora35: VM not created. Moving on...
==> debian11: VM not created. Moving on...
==> ubuntu1804: VM not created. Moving on...
==> alma8: VM not created. Moving on...
==> rocky8: VM not created. Moving on...
==> ubuntu2004: Forcing shutdown of VM...
==> ubuntu2004: Destroying VM and associated drives...
```

This example removes any created VMs defined in the Vagrant file.

## PARAMETERS

### None
