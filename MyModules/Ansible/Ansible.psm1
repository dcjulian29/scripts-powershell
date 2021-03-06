function Invoke-AnsibleContainer {
    [CmdletBinding()]
    param (
        [string]$EntryPoint,
        [string]$Command
    )

    if (Test-DockerLinuxEngine) {
        $workingPath = "/" + (($pwd.Path -replace "\\","/") -replace ":","").ToLower().Trim("/")

        $params = @{
          Image = "dcjulian29/ansible"
          Tag = "latest"
          Interactive = $true
          Name = "ansible_shell"
          Volume = @(
            "${workingPath}:/etc/ansible"
            "/mnt/c/etc/ssh/wsl:/root/.ssh"
          )
        }

        if ($EntryPoint) {
          $params.Add("EntryPoint", $EntryPoint)
        }

        if ($Command) {
          $params.Add("Command", $Command)
        }

        New-DockerContainer @params
    } else {
        Write-Error "Ansible requires the Linux Docker Engine!" -Category ResourceUnavailable
    }
}

function Invoke-Ansible {
    Invoke-AnsibleContainer -EntryPoint "/usr/bin/ansible" -Command "$args"
}

Set-Alias -Name ansible -Value Invoke-Ansible

function Invoke-AnsibleDoc {
    Invoke-AnsibleContainer -EntryPoint "/usr/bin/ansible-doc" -Command "$args"
}

Set-Alias -Name ansible-doc -Value Invoke-AnsibleDoc

function Invoke-AnsibleGalaxy {
    Invoke-AnsibleContainer -EntryPoint "/usr/bin/ansible-galaxy" -Command "$args"
}

Set-Alias -Name ansible-galaxy -Value Invoke-AnsibleGalaxy

function Invoke-AnsibleInventory {
    Invoke-AnsibleContainer -EntryPoint "/usr/bin/ansible-inventory" -Command "$args"
}

Set-Alias -Name ansible-inventory -Value Invoke-AnsibleInventory

function Invoke-AnsibleLint {
    Invoke-AnsibleContainer -EntryPoint "/usr/bin/ansible-lint" -Command "$args"
}

Set-Alias -Name ansible-lint -Value Invoke-AnsibleLint

function Invoke-AnsiblePlaybook {
    Invoke-AnsibleContainer -EntryPoint "/usr/bin/ansible-playbook" -Command "$args"
}

Set-Alias -Name ansible-playbook -Value Invoke-AnsiblePlaybook

function Invoke-AnsibleVault {
    Invoke-AnsibleContainer -EntryPoint "/usr/bin/ansible-vault" -Command "$args"
}

Set-Alias -Name ansible-vault -Value Invoke-AnsibleVault

function Show-AnsibleFacts {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [Alias("Path")]
        [string] $InventoryFile
    )

    $workingPath = (($InventoryFile -replace "\\","/") -replace ":","").ToLower().Trim("/")

    if ((Resolve-Path $workingPath).Path.Contains($pwd.Path)) {
        $playbook = "./$((New-Guid).Guid).yml"

        Set-Content -Path $playbook -Value @"
---
- hosts: all
  become: true
  tasks:
    - name: Print All Ansible Facts
      ansible.builtin.debug:
        var: ansible_facts
"@

        Invoke-AnsiblePlaybook --inventory $workingPath $playbook

        Remove-Item -Path $playbook -Force
    } else {
        Write-Warning "Current PowerShell wrapper only supports files as a child of the current working directory."
    }
}

Set-Alias -Name ansible-facts -Value Show-AnsibleFacts

function Show-AnsibleVariables {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [Alias("Path")]
        [string] $InventoryFile
    )

    $workingPath = (($InventoryFile -replace "\\","/") -replace ":","").ToLower().Trim("/")

    if ((Resolve-Path $workingPath).Path.Contains($pwd.Path)) {
        Invoke-AnsibleInventory --graph --vars --inventory $workingPath
    } else {
        Write-Warning "Current PowerShell wrapper only supports files as a child of the current working directory."
    }
}

Set-Alias -Name ansible-variables -Value Show-AnsibleVariables
Set-Alias -Name ansible-vars -Value Show-AnsibleVariables

function Protect-AnsibleVariable {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Value,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $VariableName
    )

    Invoke-AnsibleVault encrypt_string `"$Value`" --name $VariableName
}

Set-Alias -Name ansible-encrypt -Value Protect-AnsibleVariable
