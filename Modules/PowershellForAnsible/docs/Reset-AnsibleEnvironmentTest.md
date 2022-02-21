---
external help file: PowershellForAnsible-help.xml
Module Name: PowershellForAnsible
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForAnsible/docs/Reset-AnsibleEnvironmentTest.md
schema: 2.0.0
---

# Reset-AnsibleEnvironmentTest

## SYNOPSIS

Reset my Ansible test environment.

## SYNTAX

```powershell
Reset-AnsibleEnvironmentTest [[-Role] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Reset-AnsibleEnvironmentTest function reset my Ansible test environment. It does this by destroying each of the Vagrant VMs that are defined in the `vagrant.ini` file. It then recreates all of the VMs in that file and runs the base playbook with tasks identified by the 'minimal' tag.

## EXAMPLES

### Example 1

```powershell
PS C:\> Reset-AnsibleEnvironmentTest

Reset-AnsibleEnvironmentTest
==> fedora35: VM not created. Moving on...
==> debian11: VM not created. Moving on...
==> ubuntu1804: VM not created. Moving on...
==> alma8: VM not created. Moving on...
==> rocky8: VM not created. Moving on...
==> ubuntu2004: VM not created. Moving on...
==> ubuntu2004: Checking for updates to 'geerlingguy/ubuntu2004'
    ubuntu2004: Latest installed version: 1.0.3
    ubuntu2004: Version constraints:
    ubuntu2004: Provider: virtualbox
==> ubuntu2004: Box 'geerlingguy/ubuntu2004' (v1.0.3) is running the latest version.
==> rocky8: Checking for updates to 'rockylinux/8'
    rocky8: Latest installed version: 4.0.0
    rocky8: Version constraints:
    rocky8: Provider: virtualbox
==> rocky8: Box 'rockylinux/8' (v4.0.0) is running the latest version.
==> alma8: Checking for updates to 'almalinux/8'
    alma8: Latest installed version: 8.5.20211208
    alma8: Version constraints:
    alma8: Provider: virtualbox
==> alma8: Box 'almalinux/8' (v8.5.20211208) is running the latest version.
==> ubuntu1804: Checking for updates to 'geerlingguy/ubuntu1804'
    ubuntu1804: Latest installed version: 1.1.9
    ubuntu1804: Version constraints:
    ubuntu1804: Provider: virtualbox
==> ubuntu1804: Box 'geerlingguy/ubuntu1804' (v1.1.9) is running the latest version.
==> debian11: Checking for updates to 'debian/bullseye64'
    debian11: Latest installed version: 11.20211230.1
    debian11: Version constraints:
    debian11: Provider: virtualbox
==> debian11: Box 'debian/bullseye64' (v11.20211230.1) is running the latest version.
==> fedora35: Checking for updates to 'fedora/35-cloud-base'
    fedora35: Latest installed version: 35.20211026.0
    fedora35: Version constraints:
    fedora35: Provider: virtualbox
==> fedora35: Box 'fedora/35-cloud-base' (v35.20211026.0) is running the latest version.
The following boxes will be kept...
almalinux/8               (virtualbox, 8.5.20211208)
almalinux/centos-stream-9 (virtualbox, 9.20211127)
centos/7                  (virtualbox, 2004.01)
centos/8                  (virtualbox, 2011.0)
debian/bullseye64         (virtualbox, 11.20211230.1)
fedora/35-cloud-base      (virtualbox, 35.20211026.0)
geerlingguy/centos8       (virtualbox, 1.0.7)
geerlingguy/ubuntu1804    (virtualbox, 1.1.9)
geerlingguy/ubuntu2004    (virtualbox, 1.0.3)
generic/fedora33          (virtualbox, 3.2.16)
hashicorp/bionic64        (hyperv, 1.0.282)
rockylinux/8              (virtualbox, 4.0.0)
ubuntu/focal64            (virtualbox, 20210409.0.0)

Checking for older boxes...
No old versions of boxes to remove...
Bringing machine 'ubuntu2004' up with 'virtualbox' provider...
Bringing machine 'rocky8' up with 'virtualbox' provider...
Bringing machine 'alma8' up with 'virtualbox' provider...
Bringing machine 'ubuntu1804' up with 'virtualbox' provider...
Bringing machine 'debian11' up with 'virtualbox' provider...
Bringing machine 'fedora35' up with 'virtualbox' provider...
==> ubuntu2004: Importing base box 'geerlingguy/ubuntu2004'...
==> ubuntu2004: Matching MAC address for NAT networking...
==> ubuntu2004: Checking if box 'geerlingguy/ubuntu2004' version '1.0.3' is up to date...
==> ubuntu2004: Setting the name of the VM: ansible_ubuntu2004_1644241371648_81737
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
==> rocky8: Setting the name of the VM: ansible_rocky8_1644241417637_18687
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
==> alma8: Importing base box 'almalinux/8'...
==> alma8: Matching MAC address for NAT networking...
==> alma8: Checking if box 'almalinux/8' version '8.5.20211208' is up to date...
==> alma8: Setting the name of the VM: ansible_alma8_1644241466239_82631
==> alma8: Clearing any previously set network interfaces...
==> alma8: Preparing network interfaces based on configuration...
    alma8: Adapter 1: nat
    alma8: Adapter 2: hostonly
==> alma8: Forwarding ports...
    alma8: 22 (guest) => 8007 (host) (adapter 1)
==> alma8: Running 'pre-boot' VM customizations...
==> alma8: Booting VM...
==> alma8: Waiting for machine to boot. This may take a few minutes...
    alma8: SSH address: 127.0.0.1:8007
    alma8: SSH username: vagrant
    alma8: SSH auth method: private key
==> alma8: Machine booted and ready!
==> alma8: Checking for guest additions in VM...
==> alma8: Setting hostname...
==> alma8: Configuring and enabling network interfaces...
==> ubuntu1804: Importing base box 'geerlingguy/ubuntu1804'...
==> ubuntu1804: Matching MAC address for NAT networking...
==> ubuntu1804: Checking if box 'geerlingguy/ubuntu1804' version '1.1.9' is up to date...
==> ubuntu1804: Setting the name of the VM: ansible_ubuntu1804_1644241532244_7198
==> ubuntu1804: Clearing any previously set network interfaces...
==> ubuntu1804: Preparing network interfaces based on configuration...
    ubuntu1804: Adapter 1: nat
    ubuntu1804: Adapter 2: hostonly
==> ubuntu1804: Forwarding ports...
    ubuntu1804: 22 (guest) => 8008 (host) (adapter 1)
==> ubuntu1804: Running 'pre-boot' VM customizations...
==> ubuntu1804: Booting VM...
==> ubuntu1804: Waiting for machine to boot. This may take a few minutes...
    ubuntu1804: SSH address: 127.0.0.1:8008
    ubuntu1804: SSH username: vagrant
    ubuntu1804: SSH auth method: private key
==> ubuntu1804: Machine booted and ready!
==> ubuntu1804: Checking for guest additions in VM...
==> ubuntu1804: Setting hostname...
==> ubuntu1804: Configuring and enabling network interfaces...
==> debian11: Importing base box 'debian/bullseye64'...
==> debian11: Matching MAC address for NAT networking...
==> debian11: Checking if box 'debian/bullseye64' version '11.20211230.1' is up to date...
==> debian11: Setting the name of the VM: ansible_debian11_1644241576311_58495
==> debian11: Clearing any previously set network interfaces...
==> debian11: Preparing network interfaces based on configuration...
    debian11: Adapter 1: nat
    debian11: Adapter 2: hostonly
==> debian11: Forwarding ports...
    debian11: 22 (guest) => 8009 (host) (adapter 1)
==> debian11: Running 'pre-boot' VM customizations...
==> debian11: Booting VM...
==> debian11: Waiting for machine to boot. This may take a few minutes...
    debian11: SSH address: 127.0.0.1:8009
    debian11: SSH username: vagrant
    debian11: SSH auth method: private key
    debian11: Warning: Connection reset. Retrying...
    debian11: Warning: Connection aborted. Retrying...
==> debian11: Machine booted and ready!
==> debian11: Checking for guest additions in VM...
==> debian11: Setting hostname...
==> debian11: Configuring and enabling network interfaces...
==> fedora35: Importing base box 'fedora/35-cloud-base'...
==> fedora35: Matching MAC address for NAT networking...
==> fedora35: Checking if box 'fedora/35-cloud-base' version '35.20211026.0' is up to date...
==> fedora35: Setting the name of the VM: ansible_fedora35_1644241670077_59616
==> fedora35: Clearing any previously set network interfaces...
==> fedora35: Preparing network interfaces based on configuration...
    fedora35: Adapter 1: nat
    fedora35: Adapter 2: hostonly
==> fedora35: Forwarding ports...
    fedora35: 22 (guest) => 8010 (host) (adapter 1)
==> fedora35: Running 'pre-boot' VM customizations...
==> fedora35: Booting VM...
==> fedora35: Waiting for machine to boot. This may take a few minutes...
    fedora35: SSH address: 127.0.0.1:8010
    fedora35: SSH username: vagrant
    fedora35: SSH auth method: private key
==> fedora35: Machine booted and ready!
==> fedora35: Checking for guest additions in VM...
==> fedora35: Setting hostname...
==> fedora35: Configuring and enabling network interfaces...

==> debian11: Machine 'debian11' has a post `vagrant up` message. This is a message
==> debian11: from the creator of the Vagrantfile, and not from Vagrant itself:
==> debian11:
==> debian11: Vanilla Debian box. See https://app.vagrantup.com/debian for help and bug reports
Searching for 10.10.10.5... [Found]
Searching for 10.10.10.6... [Found]
Searching for 10.10.10.7... [Found]
Searching for 10.10.10.8... [Found]
Searching for 10.10.10.9... [Found]
Searching for 10.10.10.10... [Found]
ansible-playbook [core 2.12.1]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /opt/ansible/lib/python3.10/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /opt/ansible/bin/ansible-playbook
  python version = 3.10.1 (main, Dec 21 2021, 09:17:12) [GCC 10.2.1 20210110]
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
ok: [debian11]
[WARNING]: Platform linux on host ubuntu1804 is using the discovered Python interpreter at /usr/bin/python3.6, but
future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
ok: [ubuntu1804]
[WARNING]: Platform linux on host ubuntu2004 is using the discovered Python interpreter at /usr/bin/python3.8, but
future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
ok: [ubuntu2004]
[WARNING]: Platform linux on host rocky8 is using the discovered Python interpreter at /usr/libexec/platform-python,
but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
ok: [rocky8]
[WARNING]: Platform linux on host fedora35 is using the discovered Python interpreter at /usr/bin/python3.10, but
future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
ok: [fedora35]
[WARNING]: Platform linux on host alma8 is using the discovered Python interpreter at /usr/libexec/platform-python, but
future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
ok: [alma8]
META: ran handlers

TASK [julian_ca : install CA package on RedHat-based systems.] *********************************************************
task path: /etc/ansible/roles/julian_ca/tasks/main.yml:2
skipping: [ubuntu2004] => changed=false
  skip_reason: Conditional result was False
skipping: [ubuntu1804] => changed=false
  skip_reason: Conditional result was False
skipping: [debian11] => changed=false
  skip_reason: Conditional result was False
ok: [rocky8] => changed=false
  msg: Nothing to do
  rc: 0
  results: []
ok: [alma8] => changed=false
  msg: Nothing to do
  rc: 0
  results: []
ok: [fedora35] => changed=false
  msg: Nothing to do
  rc: 0
  results: []

TASK [julian_ca : install CA package on Debian-based systems.] *********************************************************
task path: /etc/ansible/roles/julian_ca/tasks/main.yml:10
skipping: [rocky8] => changed=false
  skip_reason: Conditional result was False
skipping: [fedora35] => changed=false
  skip_reason: Conditional result was False
skipping: [alma8] => changed=false
  skip_reason: Conditional result was False
ok: [debian11] => changed=false
  cache_update_time: 1644241852
  cache_updated: true
ok: [ubuntu2004] => changed=false
  cache_update_time: 1644241853
  cache_updated: true
ok: [ubuntu1804] => changed=false
  cache_update_time: 1644241857
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
-src: /usr/share/zoneinfo/Etc/UTC
+src: /usr/share/zoneinfo/America/New_York

changed: [debian11] => changed=true
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
-src: /usr/share/zoneinfo/Etc/UTC
+src: /usr/share/zoneinfo/America/New_York

changed: [ubuntu1804] => changed=true
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
--- before
+++ after
@@ -1,2 +1,2 @@
 path: /etc/localtime
-src: ../usr/share/zoneinfo/Etc/UTC
+src: /usr/share/zoneinfo/America/New_York

changed: [fedora35] => changed=true
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
--- before
+++ after
@@ -1,2 +1,2 @@
 path: /etc/localtime
-src: ../usr/share/zoneinfo/UTC
+src: /usr/share/zoneinfo/America/New_York

changed: [alma8] => changed=true
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

TASK [base : Include OS-specific tasks] ********************************************************************************
task path: /etc/ansible/roles/base/tasks/main.yml:18
included: /etc/ansible/roles/base/tasks/debian.yml for ubuntu2004, ubuntu1804, debian11
included: /etc/ansible/roles/base/tasks/redhat.yml for rocky8, fedora35, alma8
META: noop

TASK [base : Ensure EPEL installed] ************************************************************************************
task path: /etc/ansible/roles/base/tasks/redhat.yml:2
META: noop
skipping: [rocky8] => changed=false
  skip_reason: Conditional result was False
META: noop
skipping: [fedora35] => changed=false
  skip_reason: Conditional result was False
skipping: [alma8] => changed=false
  skip_reason: Conditional result was False

RUNNING HANDLER [julian_ca : Update trusted CA for Debian.] ************************************************************
task path: /etc/ansible/roles/julian_ca/handlers/main.yml:2
skipping: [rocky8] => changed=false
  skip_reason: Conditional result was False
skipping: [fedora35] => changed=false
  skip_reason: Conditional result was False
skipping: [alma8] => changed=false
  skip_reason: Conditional result was False
changed: [debian11] => changed=true
  cmd: /usr/sbin/update-ca-certificates
  delta: '0:00:02.315447'
  end: '2022-02-07 08:52:49.622834'
  msg: ''
  rc: 0
  start: '2022-02-07 08:52:47.307387'
  stderr: ''
  stderr_lines: <omitted>
  stdout: |-
    Updating certificates in /etc/ssl/certs...
    4 added, 0 removed; done.
    Running hooks in /etc/ca-certificates/update.d...
    done.
  stdout_lines: <omitted>
changed: [ubuntu2004] => changed=true
  cmd: /usr/sbin/update-ca-certificates
  delta: '0:00:02.371686'
  end: '2022-02-07 08:52:49.939983'
  msg: ''
  rc: 0
  start: '2022-02-07 08:52:47.568297'
  stderr: ''
  stderr_lines: <omitted>
  stdout: |-
    Updating certificates in /etc/ssl/certs...
    4 added, 0 removed; done.
    Running hooks in /etc/ca-certificates/update.d...
    done.
  stdout_lines: <omitted>
changed: [ubuntu1804] => changed=true
  cmd: /usr/sbin/update-ca-certificates
  delta: '0:00:02.132270'
  end: '2022-02-07 08:52:50.561533'
  msg: ''
  rc: 0
  start: '2022-02-07 08:52:48.429263'
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
skipping: [debian11] => changed=false
  skip_reason: Conditional result was False
skipping: [ubuntu1804] => changed=false
  skip_reason: Conditional result was False
skipping: [ubuntu2004] => changed=false
  skip_reason: Conditional result was False
changed: [rocky8] => changed=true
  cmd: /bin/update-ca-trust
  delta: '0:00:00.652223'
  end: '2022-02-07 08:52:51.801514'
  msg: ''
  rc: 0
  start: '2022-02-07 08:52:51.149291'
  stderr: ''
  stderr_lines: <omitted>
  stdout: ''
  stdout_lines: <omitted>
changed: [alma8] => changed=true
  cmd: /bin/update-ca-trust
  delta: '0:00:00.806559'
  end: '2022-02-07 08:52:52.410778'
  msg: ''
  rc: 0
  start: '2022-02-07 08:52:51.604219'
  stderr: ''
  stderr_lines: <omitted>
  stdout: ''
  stdout_lines: <omitted>
changed: [fedora35] => changed=true
  cmd: /bin/update-ca-trust
  delta: '0:00:00.751963'
  end: '2022-02-07 08:52:52.762533'
  msg: ''
  rc: 0
  start: '2022-02-07 08:52:52.010570'
  stderr: ''
  stderr_lines: <omitted>
  stdout: ''
  stdout_lines: <omitted>
META: ran handlers
META: ran handlers

PLAY RECAP *************************************************************************************************************
alma8                      : ok=13   changed=9    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0
debian11                   : ok=13   changed=9    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
fedora35                   : ok=13   changed=9    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0
rocky8                     : ok=13   changed=9    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0
ubuntu1804                 : ok=13   changed=9    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0
ubuntu2004                 : ok=14   changed=10   unreachable=0    failed=0    skipped=2    rescued=0    ignored=0

```

This example resets my Ansible test environment.

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
