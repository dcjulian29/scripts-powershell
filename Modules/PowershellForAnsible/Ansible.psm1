function Find-AnsibleConfig {
  [CmdletBinding()]
  param (
    [string] $Path = $PWD
  )

  if ($IsWindows) {
    $top = ($Path -replace (Split-Path -Path $PWD -Qualifier), '') + "\"
  }

  while (-not (Test-Path -Path (Join-Path $Path "ansible.cfg"))) {
    $Path = (Split-Path $Path -Parent)

    if (($Path.Length -eq 0) -or ($Path -eq $top)) {
      return $null
    }
  }

  if (Test-Path -Path (Join-Path $Path "ansible.cfg")) {
    return $Path
  }

  return $null
}

function Get-AnsibleConfig {
  Invoke-AnsibleConfig list
}

function Get-AnsibleConfigDump {
  Invoke-AnsibleConfig dump
}

function Get-AnsibleConfigFile {
  Invoke-AnsibleConfig view
}

function Invoke-AnsibleContainer {
  [CmdletBinding()]
  [Alias("ansible-container")]
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
        "$(Get-DockerMountPoint $PWD):/home/ansible/data"
        "$(Get-DockerMountPoint "${env:SYSTEMDRIVE}/etc/ssh/wsl"):/ssh"
      )
      Environment = $EnvironmentVariables
    }

    if ($EntryPoint) {
      $params.Add("EntryPoint", $EntryPoint)
    }

    if ($EntryScript) {
      $params.Volume += "$(Get-DockerMountPoint $EntryScript):/docker-entrypoint.d/01_entryscript"
    }

    if ($Command) {
      $params.Add("Command", """$Command""")
    }

    $params.GetEnumerator().ForEach({ Write-Verbose "$($_.Name)=$($_.Value)" })

    New-DockerContainer @params
  } else {
    Write-Error "Ansible module requires the Linux Docker Engine!" -Category ResourceUnavailable
  }
}

function Show-AnsibleFacts {
  [CmdletBinding()]
  [Alias("ansible-facts")]
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

function Show-AnsibleVariables {
  [CmdletBinding()]
  [Alias("ansible-variables", "ansible-vars")]
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
