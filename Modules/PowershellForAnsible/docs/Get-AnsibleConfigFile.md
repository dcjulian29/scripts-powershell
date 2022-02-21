---
external help file: PowershellForAnsible-help.xml
Module Name: PowershellForAnsible
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForAnsible/docs/Get-AnsibleConfigFile.md
schema: 2.0.0
---

# Get-AnsibleConfigFile

## SYNOPSIS

Display the ansible.cfg file.

## SYNTAX

```powershell
Get-AnsibleConfigFile
```

## DESCRIPTION

The Get-AnsibleConfigFile function displays the ansible.cfg file.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-AnsibleConfigFile
Using /etc/ansible/ansible.cfg as config file
[defaults]
duplicate_dict_key          = error
error_on_undefined_vars     = true
gathering                   = smart
host_key_checking           = false
inventory                   = ./inventories/hosts.ini
log_path                    = ./ansible.log
roles_path                  = ./roles
stdout_callback             = community.general.yaml
use_persistent_connections  = true
verbosity                   = 1

[connection]
pipelining                  = true

[ssh_connection]
pipelining                  = true

[diff]
always                      = true
```

This example displays the ansible.cfg file.
