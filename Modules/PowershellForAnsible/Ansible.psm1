$script:AnsibleDir = "/root/ansible/bin"

function Get-AnsibleConfig {
  Invoke-AnsibleConfig list
}

function Get-AnsibleConfigDump {
  Invoke-AnsibleConfig dump
}

function Get-AnsibleConfigFile {
  Invoke-AnsibleConfig view
}

function Invoke-Ansible {
  Invoke-AnsibleContainer -EntryPoint "${script:AnsibleDir}/ansible" -Command "$args"
}

Set-Alias -Name ansible -Value Invoke-Ansible

function Invoke-AnsibleConfig {
  Invoke-AnsibleContainer -EntryPoint "${script:AnsibleDir}/ansible-config" -Command "$args"
}

Set-Alias -Name ansible-config -Value Invoke-AnsibleConfig

function Invoke-AnsibleContainer {
  [CmdletBinding()]
  param (
    [string]$EntryPoint,
    [string]$Command,
    [Alias("env")]
    [hashtable]$EnvironmentVariables,
    [string]$EntryScript
  )

  if (Test-DockerLinuxEngine) {
    $params = @{
      Image = "dcjulian29/ansible"
      Tag = "latest"
      Interactive = $true
      Name = "ansible_shell"
      Volume = @(
        "$(Get-DockerMountPoint $PWD):/etc/ansible"
        "$(Get-DockerMountPoint "${env:SYSTEMDRIVE}/etc/ssh/wsl"):/root/.ssh"
        "$(Get-DockerMountPoint "${env:USERPROFILE}/.azure"):/root/.azure"
        "$(Get-DockerMountPoint "${env:USERPROFILE}/.aws"):/root/.aws"
      )
      Environment = $EnvironmentVariables
    }

    if ($EntryPoint) {
      $params.Add("EntryPoint", $EntryPoint)
    }

    if ($EntryScript) {
      $params.Add("EntryScript", $EntryScript)
    }

    if ($Command) {
      $params.Add("Command", "$Command")
    }

    $params.GetEnumerator().ForEach({ Write-Verbose "$($_.Name)=$($_.Value)" })

    New-DockerContainer @params
  } else {
    Write-Error "Ansible module requires the Linux Docker Engine!" -Category ResourceUnavailable
  }
}

Set-Alias -Name ansible-container -Value Invoke-AnsibleContainer

function Invoke-AnsibleDoc {
  Invoke-AnsibleContainer -EntryPoint "${script:AnsibleDir}/ansible-doc" -Command "$args"
}

Set-Alias -Name ansible-doc -Value Invoke-AnsibleDoc

function Invoke-AnsibleGalaxy {
  Invoke-AnsibleContainer -EntryPoint "${script:AnsibleDir}/ansible-galaxy" -Command "$args"
}

Set-Alias -Name ansible-galaxy -Value Invoke-AnsibleGalaxy

function Invoke-AnsibleInventory {
  $params = "$args"
  Invoke-AnsibleContainer -EntryPoint "${script:AnsibleDir}/ansible-inventory" -Command $params
}

Set-Alias -Name ansible-inventory -Value Invoke-AnsibleInventory

function Invoke-AnsibleLint {
  Invoke-AnsibleContainer -EntryPoint "${script:AnsibleDir}/ansible-lint" -Command "$args"
}

Set-Alias -Name ansible-lint -Value Invoke-AnsibleLint

function Invoke-AnsiblePlaybook {
    Invoke-AnsibleContainer -EntryPoint "${script:AnsibleDir}/ansible-playbook" -Command "$args"
}

Set-Alias -Name ansible-playbook -Value Invoke-AnsiblePlaybook

function Invoke-AnsibleVault {
    Invoke-AnsibleContainer -EntryPoint "${script:AnsibleDir}/ansible-vault" -Command "$args"
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
