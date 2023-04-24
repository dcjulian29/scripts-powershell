$script:vaultPasswd = "./.tmp/.vault_pass"

function ensureAnsibleRoot {
  $root = Find-AnsibleConfig

  Write-Verbose "Ansible root folder: $root"

  if ($null -eq $root) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "Unable to determine the root Ansible folder. Could not find ansible.cfg." `
      -ExceptionType "System.InvalidOperationException" `
      -ErrorId "System.InvalidOperation" `
      -ErrorCategory "InvalidOperation"))
  }

  Push-Location -Path $root

  if (-not (Test-Path -Path ".tmp" -PathType Container)) {
    New-Item -Path ".tmp" -ItemType Directory -Force | Out-Null
  }
}

function returnAnsibleRoot {
  Pop-Location

  if ($isWindows) {
    Get-DockerContainer | Where-Object { $_.Name -eq "ansible_shell" } `
      | Remove-DockerContainer | Out-Null
  }
}

#------------------------------------------------------------------------------

function Assert-AnsibleProvision {
  [CmdletBinding()]
  [Alias("ansible-provision-assert", "ansible-provision-check")]
  param (
    [Parameter(Mandatory=$true)]
    [string] $ComputerName
  )

  ensureAnsibleRoot

  $param  = "--ask-vault-password --check --diff"
  $param += " -i ./inventories/hosts.ini ./playbooks/$ComputerName.yml"

  if ($isWindows) {
    Invoke-AnsibleContainer -Command "ansible-playbook $param" -EnvironmentVariables @{
      "ANSIBLE_HOST_KEY_CHECKING" = "true"
      "ANSIBLE_DISPLAY_OK_HOSTS" = "no"
      "ANSIBLE_DISPLAY_SKIPPED_HOSTS" = "no"
    }
  } else {
    $original_host_key = $env:ANSIBLE_HOST_KEY_CHECKING
    $orginal_display_ok = $env:ANSIBLE_DISPLAY_OK_HOSTS
    $original_display_skip = $env:ANSIBLE_DISPLAY_SKIPPED_HOSTS

    $env:ANSIBLE_HOST_KEY_CHECKING = "true"
    $env:ANSIBLE_DISPLAY_OK_HOSTS = "no"
    $env:ANSIBLE_DISPLAY_SKIPPED_HOSTS = "no"

    ansible-playbook $param

    $env:ANSIBLE_HOST_KEY_CHECKING = $original_host_key
    $env:ANSIBLE_DISPLAY_OK_HOSTS = $orginal_display_ok
    $env:ANSIBLE_DISPLAY_SKIPPED_HOSTS = $original_display_skip
  }

  returnAnsibleRoot
}

function Export-AnsibleFacts {
  [CmdletBinding()]
  [Alias("ansible-save-facts", "ansible-facts-save")]
  param (
    [string] $ComputerName = "all",
    [string] $InventoryFile = "./inventories/vagrant.ini",
    [switch] $IncludeVars
  )

  ensureAnsibleRoot

  if ($IncludeVars) {
    $facts = "vars"
  } else {
    $facts = "setupvar.ansible_facts"
  }

  $play  = "---`n"
  $play += "- hosts: $ComputerName`n"
  $play += "  tasks:`n"
  $play += "    - setup:`n"
  $play += "      register: setupvar`n"
  $play += "    - copy:`n"
  $play += "        content: `"{{ $facts | to_nice_json }}`"`n"
  $play += "        dest: `"{{ ansible_host }}.json`"`n"
  $play += "      delegate_to: localhost`n"

  Set-Content -Path ".tmp/play.yml" -Value $play -Force -NoNewline

  $param = "-v --limit $ComputerName "
  $param += "-i $(Get-FilePathForContainer $InventoryFile -MustBeChild) .tmp/play.yml"

  ansible-playbook $param

  returnAnsibleRoot
}

function Get-AnsibleFacts {
  [CmdletBinding()]
  [Alias("ansible-show-facts", "ansible-facts-show")]
  param (
    [string] $ComputerName = "all",
    [string] $InventoryFile = "./inventories/vagrant.ini",
    [switch] $OnlyAnsible
  )

  ensureAnsibleRoot

  $play  = "---`n"
  $play += "- hosts: $ComputerName`n"
  $play += "  tasks:`n"
  $play += "    - ansible.builtin.debug:`n"
  $play += "        msg: `"{{ vars | to_yaml }}`"`n"
  $play += "      tags:`n"
  $play += "        - printall`n"
  $play += "    - ansible.builtin.debug:`n"
  $play += "        var: ansible_facts`n"
  $play += "      tags:`n"
  $play += "        - printfacts`n"

  Set-Content -Path ".tmp/play.yml" -Value $play -Force -NoNewline

  $param = "-v --limit $ComputerName --tags "

  if ($OnlyAnsible) {
    $param += "printfacts "
  } else {
    $param += "printall "
  }

  $param += "-i $(Get-FilePathForContainer $InventoryFile -MustBeChild) .tmp/play.yml"

  ansible-playbook $param

  returnAnsibleRoot
}

function Get-AnsibleHostVariables {
  [CmdletBinding()]
  [Alias("ansible-show-hostvars")]
  param (
    [Parameter(Mandatory=$true)]
    [string] $ComputerName,
    [string] $InventoryFile = "./inventories/vagrant.ini"
  )

  ensureAnsibleRoot

  $p = "-i $(Get-FilePathForContainer $InventoryFile -MustBeChild) " `
    + "--yaml --vars --host $ComputerName"

  ansible-inventory $p

  returnAnsibleRoot
}

function Get-AnsibleVariables {
  [CmdletBinding()]
  [Alias("ansible-show-vars")]
  param (
    [string] $InventoryFile = "./inventories/vagrant.ini"
  )

  ensureAnsibleRoot

  $p = "-i $(Get-FilePathForContainer $InventoryFile -MustBeChild) --graph --vars -vvv"

  ansible-inventory $p

  returnAnsibleRoot
}

function Import-AnsibleFacts {
  [CmdletBinding()]
  [Alias("ansible-load-facts", "ansible-facts-load")]
  param (
    [string] $ComputerName = "all",
    [string] $InventoryFile = "./inventories/vagrant.ini",
    [switch] $IncludeVars
  )

  Remove-Item -Path .tmp/*.json -Force

  Export-AnsibleFacts -ComputerName $ComputerName -InventoryFile $InventoryFile -IncludeVars:$IncludeVars `
    | Out-Null

  return (Get-Content -Raw -Path .tmp/*.json | ConvertFrom-Json)
}

function Invoke-AnsibleProvision {
  [CmdletBinding()]
  [Alias("ansible-provision-server")]
  param (
    [Parameter(Mandatory=$true)]
    [string] $ComputerName
  )

  ensureAnsibleRoot

  $logfile = "$(Get-LogFileName -Suffix "provision-$ComputerName")"
  $fileName = Split-Path -Path $logfile -Leaf
  $param  = "--ask-vault-password --ask-become-pass -v"
  $param += " -i ./inventories/hosts.ini ./playbooks/$ComputerName.yml"
  $ep  = "#!/bin/bash`n`nansible-playbook $param | tee .tmp/$fileName`n"

  Set-Content -Path ".tmp/entrypoint.sh" -Value $ep -Force -NoNewline

  if ($isWindows) {
    Invoke-AnsibleContainer -EntryScript ".tmp/entrypoint.sh" `
      -EnvironmentVariables @{
        "ANSIBLE_NOCOLOR" = "1"
      }
  } else {
    $original = $env:ANSIBLE_NOCOLOR
    ansible-playbook "$param | tee .tmp/$fileName`n"
    $env:ANSIBLE_NOCOLOR = $original
  }

  if (Test-Path .tmp/$fileName) {
    Move-Item -Path .tmp/$fileName -Destination $logfile
  }

  returnAnsibleRoot
}

function Remove-AnsibleVaultPassword {
  [CmdletBinding(SupportsShouldProcess)]
  param ()

  if (Test-Path $script:vaultPasswd) {
    if ($PSCmdlet.ShouldProcess("Stored Ansible Vault Password")) {
      Remove-Item $script:vaultPasswd -Force

      Write-Output "Ok."
    }
  } else {
    Write-Output "Ansible vault password is not currently stored."
  }
}

function Set-AnsibleVaultPassword {
  [CmdletBinding(SupportsShouldProcess)]
  param (
      [Parameter(Mandatory = $true)]
      [string] $Passwd,
      [Alias('AllowClobber')]
      [switch] $Force
  )

  ensureAnsibleRoot

  if (Test-Path $script:vaultPasswd) {
    if (-not $Force) {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "Ansible Vault password already set! Use -AllowClobber to overwrite." `
        -ExceptionType "System.Management.Automation.RuntimeException" `
        -ErrorId "RuntimeException" -ErrorCategory "ResourceExists"))
    }

    Remove-Item $script:vaultPasswd -Force
  }

  if ($Force -or ($PSCmdlet.ShouldContinue( `
      "Are you sure you want to store the Ansible Vault password unencrypted?", `
      "Ansible Vault Password"))) {

    @(
      "#!/usr/bin/env python`n`n"
      "import os`n"
      "print(`"$($Passwd)`")`n"
    ) | Set-Content -Path $script:vaultPasswd -NoNewLine

    Write-Output "Done."
  } else {
    Write-Output "Ok, password not stored."
  }

  returnAnsibleRoot
}

function Update-AnsibleHost {
  [CmdletBinding()]
  [Alias("ansible-host-update")]
  param (
    [string] $Role = "updateos",
    [string] $Subset = "all",
    [string] $InventoryFile = "inventories\vagrant.ini",
    [switch] $AskBecomePassword
  )

  ensureAnsibleRoot

  $logfile = "$(Get-LogFileName -Suffix "ansible-$Role-$Subset")"
  $fileName = Split-Path -Path $logfile -Leaf

  $play  = "---`n- hosts: $Subset`n"
  $play += "  any_errors_fatal: true`n  become: true`n"
  $play += "  roles:`n     - $Role`n"

  Set-Content -Path ".tmp/play.yml" -Value $play -Force -NoNewline

  if ($PSBoundParameters.ContainsKey('Verbose')) {
    $param = "-vvv"
  } else {
    $param = "-v"
  }

  $param += " --limit $Subset"

  if ($AskBecomePassword) {
    $param += " --ask-become-pass"
  }

  $param += " -i $(Get-FilePathForContainer $InventoryFile -MustBeChild) .tmp/play.yml"

  $ep  = "#!/bin/bash`n`nansible-playbook $param | tee .tmp/$fileName`n"

  Set-Content -Path ".tmp/entrypoint.sh" -Value $ep -Force -NoNewline

  if ($isWindows) {
    Invoke-AnsibleContainer -EntryScript ".tmp/entrypoint.sh" `
      -EnvironmentVariables @{
        "ANSIBLE_NOCOLOR" = "1"
      }
  } else {
    $original = $env:ANSIBLE_NOCOLOR
    ansible-playbook "$param | tee .tmp/$fileName`n"
    $env:ANSIBLE_NOCOLOR = $original
  }

  if (Test-Path .tmp/$fileName) {
    Move-Item -Path .tmp/$fileName -Destination $logfile
  }

  returnAnsibleRoot
}

function Update-AnsibleProvision {
  [CmdletBinding()]
  [Alias("ansible-provision-update")]
  param (
    [Parameter(Mandatory=$true)]
    [string] $ComputerName,
    [switch] $AskBecomePassword
  )

  ensureAnsibleRoot

  $logfile = "$(Get-LogFileName -Suffix "provision-update-$ComputerName")"
  $fileName = Split-Path -Path $logfile -Leaf
  $param = "--ask-vault-password"

  if ($AskBecomePassword) {
    $param += " --ask-become-pass"
  }

  $param += " -i ./inventories/hosts.ini ./playbooks/$ComputerName.yml"

  $ep  = "#!/bin/bash`n`nansible-playbook $param | tee .tmp/$fileName`n"

  Set-Content -Path ".tmp/entrypoint.sh" -Value $ep -Force -NoNewline

  if ($isWindows) {
    Invoke-AnsibleContainer -EntryScript ".tmp/entrypoint.sh" `
      -EnvironmentVariables @{
        "ANSIBLE_NOCOLOR" = "1"
        "ANSIBLE_HOST_KEY_CHECKING" = "true"
        "ANSIBLE_DISPLAY_OK_HOSTS" = "no"
        "ANSIBLE_DISPLAY_SKIPPED_HOSTS" = "no"
      }
  } else {
    $original_nocolor = $env:ANSIBLE_NOCOLOR
    $original_host_key = $env:ANSIBLE_HOST_KEY_CHECKING
    $orginal_display_ok = $env:ANSIBLE_DISPLAY_OK_HOSTS
    $original_display_skip = $env:ANSIBLE_DISPLAY_SKIPPED_HOSTS

    $env:ANSIBLE_NOCOLOR = "1"
    $env:ANSIBLE_HOST_KEY_CHECKING = "true"
    $env:ANSIBLE_DISPLAY_OK_HOSTS = "no"
    $env:ANSIBLE_DISPLAY_SKIPPED_HOSTS = "no"

    ansible-playbook $param

    $env:ANSIBLE_NOCOLOR = $original_nocolor
    $env:ANSIBLE_HOST_KEY_CHECKING = $original_host_key
    $env:ANSIBLE_DISPLAY_OK_HOSTS = $orginal_display_ok
    $env:ANSIBLE_DISPLAY_SKIPPED_HOSTS = $original_display_skip
  }

  if (Test-Path .tmp/$fileName) {
    Move-Item -Path .tmp/$fileName -Destination $logfile
  }

  returnAnsibleRoot
}
