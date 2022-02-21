---
external help file: PowershellForAnsible-help.xml
Module Name: PowershellForAnsible
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForAnsible/docs/Get-AnsibleConfigDump.md
schema: 2.0.0
---

# Get-AnsibleConfigDump

## SYNOPSIS

Show the current settings for Ansible.

## SYNTAX

```powershell
Get-AnsibleConfigDump
```

## DESCRIPTION

The Get-AnsibleConfigDump function shows the current settings for Ansible.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-AnsibleConfigDump
Using /etc/ansible/ansible.cfg as config file
ACTION_WARNINGS(default) = True
AGNOSTIC_BECOME_PROMPT(default) = True
ALLOW_WORLD_READABLE_TMPFILES(default) = False
ANSIBLE_CONNECTION_PATH(default) = None
ANSIBLE_COW_ACCEPTLIST(default) = ['bud-frogs', 'bunny', 'cheese', 'daemon', 'default', 'dragon', 'elephant-in-snake', 'elephant', 'eyes', 'hellokitty', 'kitty', 'luke-koala', 'meow', 'milk', 'moofasa', 'moose', 'ren', 'sheep', 'small', 'stegosaurus', 'stimpy', 'supermilker', 'three-eyes', 'turkey', 'turtle', 'tux', 'udder', 'vader-koala', 'vader', 'www']
ANSIBLE_COW_PATH(default) = None
ANSIBLE_COW_SELECTION(default) = default
ANSIBLE_FORCE_COLOR(default) = False
ANSIBLE_NOCOLOR(default) = False
ANSIBLE_NOCOWS(default) = False
ANSIBLE_PIPELINING(/etc/ansible/ansible.cfg) = True
ANY_ERRORS_FATAL(default) = False
BECOME_ALLOW_SAME_USER(default) = False
BECOME_PASSWORD_FILE(default) = None
BECOME_PLUGIN_PATH(default) = ['/root/.ansible/plugins/become', '/usr/share/ansible/plugins/become']
CACHE_PLUGIN(default) = memory
CACHE_PLUGIN_CONNECTION(default) = None
CACHE_PLUGIN_PREFIX(default) = ansible_facts
CACHE_PLUGIN_TIMEOUT(default) = 86400
CALLABLE_ACCEPT_LIST(default) = []
CALLBACKS_ENABLED(default) = []
COLLECTIONS_ON_ANSIBLE_VERSION_MISMATCH(default) = warning
COLLECTIONS_PATHS(default) = ['/root/.ansible/collections', '/usr/share/ansible/collections']
COLLECTIONS_SCAN_SYS_PATH(default) = True
COLOR_CHANGED(default) = yellow
COLOR_CONSOLE_PROMPT(default) = white
COLOR_DEBUG(default) = dark gray
COLOR_DEPRECATE(default) = purple
COLOR_DIFF_ADD(default) = green
COLOR_DIFF_LINES(default) = cyan
COLOR_DIFF_REMOVE(default) = red
COLOR_ERROR(default) = red
COLOR_HIGHLIGHT(default) = white
COLOR_OK(default) = green
COLOR_SKIP(default) = cyan
COLOR_UNREACHABLE(default) = bright red
COLOR_VERBOSE(default) = blue
COLOR_WARN(default) = bright purple
COMMAND_WARNINGS(default) = False

...

TASK_TIMEOUT(default) = 0
TRANSFORM_INVALID_GROUP_CHARS(default) = never
USE_PERSISTENT_CONNECTIONS(/etc/ansible/ansible.cfg) = True
VALIDATE_ACTION_GROUP_METADATA(default) = True
VARIABLE_PLUGINS_ENABLED(default) = ['host_group_vars']
VARIABLE_PRECEDENCE(default) = ['all_inventory', 'groups_inventory', 'all_plugins_inventory', 'all_plugins_play', 'groups_plugins_inventory', 'groups_plugins_play']
VERBOSE_TO_STDERR(default) = False
WIN_ASYNC_STARTUP_TIMEOUT(default) = 5
WORKER_SHUTDOWN_POLL_COUNT(default) = 0
WORKER_SHUTDOWN_POLL_DELAY(default) = 0.1
YAML_FILENAME_EXTENSIONS(default) = ['.yml', '.yaml', '.json']
```

This example shows the current settings for Ansible.
