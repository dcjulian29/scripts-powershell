---
external help file: PowershellForAnsible-help.xml
Module Name: PowershellForAnsible
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForAnsible/docs/Invoke-AnsiblePlayBase.md
schema: 2.0.0
---

# Invoke-AnsiblePlayBase

## SYNOPSIS

Play a my Ansible base role against the "development" VMs.

## SYNTAX

```powershell
Invoke-AnsiblePlayBase [[-Subset] <String>] [[-Tags] <String[]>] [-OnlyDevelopment] [-Minimal]
 [<CommonParameters>]
```

## DESCRIPTION

The Invoke-AnsiblePlayBase function plays my base role on my development Ansible environment.

## EXAMPLES

### Example 1

```powershell
PS C:\> Invoke-AnsiblePlayBase  -Minimal -OnlyDevelopment
ansible-playbook [core 2.12.2]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /opt/ansible/lib/python3.10/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /opt/ansible/bin/ansible-playbook
  python version = 3.10.2 (main, Jan 29 2022, 02:55:36) [GCC 10.2.1 20210110]
  jinja version = 3.0.3
  libyaml = True
Using /etc/ansible/ansible.cfg as config file
Skipping callback 'default', as we already have a stdout callback.
Skipping callback 'minimal', as we already have a stdout callback.
Skipping callback 'oneline', as we already have a stdout callback.

PLAYBOOK: base.yml *****************************************************************************************************
1 plays in ./playbooks/base.yml

PLAY [all] *************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
task path: /etc/ansible/playbooks/base.yml:2
[WARNING]: Platform linux on host ubuntu2004 is using the discovered Python interpreter at /usr/bin/python3.8, but
future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
ok: [ubuntu2004]
[WARNING]: Platform linux on host rocky8 is using the discovered Python interpreter at /usr/bin/python3.6, but future
installation of another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
core/2.12/reference_appendices/interpreter_discovery.html for more information.
ok: [rocky8]
META: ran handlers

TASK [julian_ca : install CA package on RedHat-based systems.] *********************************************************
task path: /etc/ansible/roles/julian_ca/tasks/main.yml:2
skipping: [ubuntu2004] => changed=false
  skip_reason: Conditional result was False
ok: [rocky8] => changed=false
  msg: Nothing to do
  rc: 0
  results: []

TASK [julian_ca : install CA package on Debian-based systems.] *********************************************************
task path: /etc/ansible/roles/julian_ca/tasks/main.yml:10
skipping: [rocky8] => changed=false
  skip_reason: Conditional result was False
ok: [ubuntu2004] => changed=false
  cache_update_time: 1646227828
  cache_updated: true

TASK [julian_ca : Ensure Root CA is present.] *********************************************************************
task path: /etc/ansible/roles/julian_ca/tasks/main.yml:19
ok: [ubuntu2004] => changed=false
  checksum: e17f7d77766509532cd7f58d0abca28815adc7e3
  dest: /usr/local/share/ca-certificates/julian_root.crt
  gid: 0
  group: root
  mode: '0444'
  owner: root
  path: /usr/local/share/ca-certificates/julian_root.crt
  size: 2532
  state: file
  uid: 0
ok: [rocky8] => changed=false
  checksum: e17f7d77766509532cd7f58d0abca28815adc7e3
  dest: /etc/pki/ca-trust/source/anchors/julian_root.crt
  gid: 0
  group: root
  mode: '0444'
  owner: root
  path: /etc/pki/ca-trust/source/anchors/julian_root.crt
  secontext: system_u:object_r:cert_t:s0
  size: 2532
  state: file
  uid: 0

TASK [base : Set timezone to America/New_York] *************************************************************************
task path: /etc/ansible/roles/base/tasks/main.yml:2
ok: [ubuntu2004] => changed=false
  dest: /etc/localtime
  gid: 0
  group: root
  mode: '0777'
  owner: root
  size: 36
  src: /usr/share/zoneinfo/America/New_York
  state: link
  uid: 0
ok: [rocky8] => changed=false
  dest: /etc/localtime
  gid: 0
  group: root
  mode: '0777'
  owner: root
  secontext: unconfined_u:object_r:etc_t:s0
  size: 36
  src: /usr/share/zoneinfo/America/New_York
  state: link
  uid: 0

META: role_complete for ubuntu2004
META: role_complete for rocky8
META: ran handlers
META: ran handlers

PLAY RECAP *************************************************************************************************************
rocky8                     : ok=12   changed=3    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
ubuntu2004                 : ok=13   changed=3    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

This example plays the base role against the development Ansible VMs.

## PARAMETERS

### -Minimal

Specify that only task with the `minimal` tag should be played.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OnlyDevelopment

Specify to limit the play to only the `ansibledev` group of machines.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: Dev, Development

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Subset

Specify the subset filter to limit play.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags

Specify the tags to include in the play.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
