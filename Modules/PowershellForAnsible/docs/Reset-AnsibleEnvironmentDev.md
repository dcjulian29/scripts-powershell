---
external help file: PowershellForAnsible-help.xml
Module Name: PowershellForAnsible
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForAnsible/docs/Reset-AnsibleEnvironmentDev.md
schema: 2.0.0
---

# Reset-AnsibleEnvironmentDev

## SYNOPSIS

Reset my Ansible development environment.

## SYNTAX

```powershell
Reset-AnsibleEnvironmentDev [[-Role] <String>] [<CommonParameters>]
```

## DESCRIPTION

It does this by destroying each of the Vagrant VMs that are defined in the `vagrant.ini` file. It then recreates a Ubuntu (ubunutu2004) and a Red-Hat (rocky8) VMs from that file and runs the base playbook with tasks identified by the 'minimal' tag.

## EXAMPLES

### Example 1

```powershell
PS C:\> Reset-AnsibleEnvironmentDev

==> alma9: VM not created. Moving on...
==> fedora35: VM not created. Moving on...
==> debian11: VM not created. Moving on...
==> rocky8: Forcing shutdown of VM...
==> rocky8: Destroying VM and associated drives...
==> ubuntu1804: VM not created. Moving on...
==> ubuntu2004: Forcing shutdown of VM...
==> ubuntu2004: Destroying VM and associated drives...
Bringing machine 'ubuntu2004' up with 'virtualbox' provider...
Bringing machine 'rocky8' up with 'virtualbox' provider...
==> ubuntu2004: Importing base box 'geerlingguy/ubuntu2004'...
==> ubuntu2004: Matching MAC address for NAT networking...
==> ubuntu2004: Checking if box 'geerlingguy/ubuntu2004' version '1.0.3' is up to date...
==> ubuntu2004: Setting the name of the VM: ansible_ubuntu2004_1644110771454_63516
==> ubuntu2004: Clearing any previously set network interfaces...
==> ubuntu2004: Preparing network interfaces based on configuration...
    ubuntu2004: Adapter 1: nat
    ubuntu2004: Adapter 2: hostonly
==> ubuntu2004: Forwarding ports...
    ubuntu2004: 22 (guest) => 8005 (host) (adapter 1)
==> ubuntu2004: Running 'pre-boot' VM customizations...
==> ubuntu2004: Booting VM...
==> ubuntu2004: Waiting for machine to boot. This may take a few minutes...
    ubuntu2004: SSH address: 127.0.0.1:8005
    ubuntu2004: SSH username: vagrant
    ubuntu2004: SSH auth method: private key
==> ubuntu2004: Machine booted and ready!
==> ubuntu2004: Checking for guest additions in VM...
==> ubuntu2004: Setting hostname...
==> ubuntu2004: Configuring and enabling network interfaces...
==> rocky8: Importing base box 'rockylinux/8'...
==> rocky8: Matching MAC address for NAT networking...
==> rocky8: Checking if box 'rockylinux/8' version '4.0.0' is up to date...
==> rocky8: Setting the name of the VM: ansible_rocky8_1644110813976_71402
==> rocky8: Clearing any previously set network interfaces...
==> rocky8: Preparing network interfaces based on configuration...
    rocky8: Adapter 1: nat
    rocky8: Adapter 2: hostonly
==> rocky8: Forwarding ports...
    rocky8: 22 (guest) => 8006 (host) (adapter 1)
==> rocky8: Running 'pre-boot' VM customizations...
==> rocky8: Booting VM...
==> rocky8: Waiting for machine to boot. This may take a few minutes...
    rocky8: SSH address: 127.0.0.1:8006
    rocky8: SSH username: vagrant
    rocky8: SSH auth method: private key
==> rocky8: Machine booted and ready!
==> rocky8: Checking for guest additions in VM...
==> rocky8: Setting hostname...
==> rocky8: Configuring and enabling network interfaces...
Searching for 10.10.10.5..... [Found]
Searching for 10.10.10.6... [Found]
ansible-playbook [core 2.12.2]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /opt/ansible/lib/python3.10/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /opt/ansible/bin/ansible-playbook
  python version = 3.10.2 (main, Jan 29 2022, 02:55:36) [GCC 10.2.1 20210110]
  jinja version = 3.0.3
  libyaml = False
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
[WARNING]: Platform linux on host rocky8 is using the discovered Python interpreter at /usr/libexec/platform-python,
but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
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
  cache_update_time: 1644110915
  cache_updated: true

TASK [base : Set timezone to America/New_York] *************************************************************************
task path: /etc/ansible/roles/base/tasks/main.yml:2
--- before
+++ after
@@ -1,2 +1,2 @@
 path: /etc/localtime
-src: /usr/share/zoneinfo/Etc/UTC
+src: /usr/share/zoneinfo/America/New_York

changed: [ubuntu2004] => changed=true
  dest: /etc/localtime
  gid: 0
  group: root
  mode: '0777'
  owner: root
  size: 36
  src: /usr/share/zoneinfo/America/New_York
  state: link
  uid: 0
--- before
+++ after
@@ -1,2 +1,2 @@
 path: /etc/localtime
-src: ../usr/share/zoneinfo/UTC
+src: /usr/share/zoneinfo/America/New_York

changed: [rocky8] => changed=true
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

TASK [base : Include OS-specific variables.] ***************************************************************************
task path: /etc/ansible/roles/base/tasks/main.yml:13
ok: [ubuntu2004] => changed=false
  ansible_facts:
    security_ssh_config_path: /etc/ssh/sshd_config
    security_ssh_name: ssh
  ansible_included_var_files:
  - /etc/ansible/roles/base/vars/debian.yml
ok: [rocky8] => changed=false
  ansible_facts:
    security_ssh_config_path: /etc/ssh/sshd_config
    security_ssh_name: sshd
  ansible_included_var_files:
  - /etc/ansible/roles/base/vars/redhat.yml

TASK [base : Include OS-specific tasks] ********************************************************************************
task path: /etc/ansible/roles/base/tasks/main.yml:18
included: /etc/ansible/roles/base/tasks/debian.yml for ubuntu2004
included: /etc/ansible/roles/base/tasks/redhat.yml for rocky8
META: noop

TASK [base : Ensure EPEL installed] ************************************************************************************
task path: /etc/ansible/roles/base/tasks/redhat.yml:2
skipping: [rocky8] => changed=false
  skip_reason: Conditional result was False

RUNNING HANDLER [julian_ca : Update trusted CA for Debian.] ************************************************************
task path: /etc/ansible/roles/julian_ca/handlers/main.yml:2
skipping: [rocky8] => changed=false
  skip_reason: Conditional result was False
changed: [ubuntu2004] => changed=true
  cmd: /usr/sbin/update-ca-certificates
  delta: '0:00:01.335204'
  end: '2022-02-05 20:29:05.903354'
  msg: ''
  rc: 0
  start: '2022-02-05 20:29:04.568150'
  stderr: ''
  stderr_lines: <omitted>
  stdout: |-
    Updating certificates in /etc/ssl/certs...
    4 added, 0 removed; done.
    Running hooks in /etc/ca-certificates/update.d...
    done.
  stdout_lines: <omitted>

RUNNING HANDLER [julian_ca : Update trusted CA for RedHat.] ************************************************************
task path: /etc/ansible/roles/julian_ca/handlers/main.yml:6
skipping: [ubuntu2004] => changed=false
  skip_reason: Conditional result was False
changed: [rocky8] => changed=true
  cmd: /bin/update-ca-trust
  delta: '0:00:00.370566'
  end: '2022-02-05 20:29:07.187817'
  msg: ''
  rc: 0
  start: '2022-02-05 20:29:06.817251'
  stderr: ''
  stderr_lines: <omitted>
  stdout: ''
  stdout_lines: <omitted>
META: ran handlers
META: ran handlers

PLAY RECAP *************************************************************************************************************
rocky8                     : ok=13   changed=9    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0
ubuntu2004                 : ok=14   changed=10   unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
```

This example resets my Ansible development environment.

## PARAMETERS

### -Role

Specify the name of the Ansible role.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).
