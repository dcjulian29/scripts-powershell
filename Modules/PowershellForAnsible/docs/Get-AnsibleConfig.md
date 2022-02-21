---
external help file: PowershellForAnsible-help.xml
Module Name: PowershellForAnsible
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForAnsible/docs/Get-AnsibleConfig.md
schema: 2.0.0
---

# Get-AnsibleConfig

## SYNOPSIS

List and output available configs.

## SYNTAX

```powershell
Get-AnsibleConfig
```

## DESCRIPTION

The Get-AnsibleConfig function lists the available config

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-AnsibleConfig
Using /etc/ansible/ansible.cfg as config file
ACTION_WARNINGS:
  default: true
  description:
  - By default Ansible will issue a warning when received from a task action (module
    or action plugin)
  - These warnings can be silenced by adjusting this setting to False.
  env:
  - name: ANSIBLE_ACTION_WARNINGS
  ini:
  - key: action_warnings
    section: defaults
  name: Toggle action warnings
  type: boolean
  version_added: '2.5'
AGNOSTIC_BECOME_PROMPT:
  default: true
  description: Display an agnostic become prompt instead of displaying a prompt containing
    the command line supplied become method
  env:
  - name: ANSIBLE_AGNOSTIC_BECOME_PROMPT
  ini:
  - key: agnostic_become_prompt
    section: privilege_escalation
  name: Display an agnostic become prompt
  type: boolean
  version_added: '2.5'
  yaml:
    key: privilege_escalation.agnostic_become_prompt
ALLOW_WORLD_READABLE_TMPFILES:
  default: false
  deprecated:
    alternatives: world_readable_tmp
    collection_name: ansible.builtin
    version: '2.14'
    why: moved to shell plugins
  description:
  - This setting has been moved to the individual shell plugins as a plugin option
    :ref:`shell_plugins`.
  - The existing configuration settings are still accepted with the shell plugin adding
    additional options, like variables.
  - This message will be removed in 2.14.
  name: Allow world-readable temporary files
  type: boolean
ANSIBLE_CONNECTION_PATH:
  default: null
  description:
  - Specify where to look for the ansible-connection script. This location will be
    checked before searching $PATH.
  - If null, ansible will start with the same directory as the ansible script.
  env:
  - name: ANSIBLE_CONNECTION_PATH
  ini:
  - key: ansible_connection_path
    section: persistent_connection
  name: Path of ansible-connection script
  type: path
  version_added: '2.8'
  yaml:
    key: persistent_connection.ansible_connection_path

...

WORKER_SHUTDOWN_POLL_COUNT:
  default: 0
  description:
  - The maximum number of times to check Task Queue Manager worker processes to verify
    they have exited cleanly.
  - After this limit is reached any worker processes still running will be terminated.
  - This is for internal use only.
  env:
  - name: ANSIBLE_WORKER_SHUTDOWN_POLL_COUNT
  name: Worker Shutdown Poll Count
  type: integer
  version_added: '2.10'
WORKER_SHUTDOWN_POLL_DELAY:
  default: 0.1
  description:
  - The number of seconds to sleep between polling loops when checking Task Queue
    Manager worker processes to verify they have exited cleanly.
  - This is for internal use only.
  env:
  - name: ANSIBLE_WORKER_SHUTDOWN_POLL_DELAY
  name: Worker Shutdown Poll Delay
  type: float
  version_added: '2.10'
YAML_FILENAME_EXTENSIONS:
  default:
  - .yml
  - .yaml
  - .json
  description:
  - Check all of these extensions when looking for 'variable' files which should be
    YAML or JSON or vaulted versions of these.
  - This affects vars_files, include_vars, inventory and vars plugins among others.
  env:
  - name: ANSIBLE_YAML_FILENAME_EXT
  ini:
  - key: yaml_valid_extensions
    section: defaults
  name: Valid YAML extensions
  type: list
```

This example list each available configuration element.
