$script:vaultPasswd = "./.tmp/.vault_pass"

function checkReset([string[]]$pingHosts) {
  foreach ($ping in $pingHosts) {
    Write-Output " "
    switch ($ping)
    {
      5 {
        Write-Verbose "Bringing Ubuntu VM online..."
        & vagrant up ubuntu
      }
      6 {
        Write-Verbose "Bringing Rocky Linux VM online..."
        & vagrant up rocky
      }
      7 {
        Write-Verbose "Bringing Alma Linux VM online..."
        & vagrant up alma
      }
      8 {
        Write-Verbose "Bringing Fedora VM online..."
        & vagrant up fedora
      }
      9 {
        Write-Verbose "Bringing Debian VM online..."
        & vagrant up debian
      }
      default {
        $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
          -Message "Vagrant host '$ping' is not configured!" `
          -ExceptionType "System.NotImplementedException" `
          -ErrorId "NotImplementedException" -ErrorCategory "NotImplemented"))
      }
    }

    if (-not $?) {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "Vagrant host failed to spin up!" `
        -ExceptionType "System.Management.Automation.RuntimeException" `
        -ErrorId "RuntimeException" -ErrorCategory "DeviceError"))
    }

    Write-Output " "
    Write-Host -NoNewline "Searching for 192.168.57.$ping..."
    $found = $false
    $count = 0

    while (-not $found) {
      $found = Test-Connection -ComputerName "192.168.57.$ping" -Quiet -Count 1

      if ($found) {
        Write-Host -ForegroundColor Green " [Found]"
      } else {
        if ($count -lt 20) {
          Write-Host -NoNewline "."
          $count++
        } else {
          Write-Host -ForegroundColor Red " [NotFound]"
          $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
            -Message "Vagrant host is not responding via networking!" `
            -ExceptionType "System.Runtime.Remoting.RemotingTimeoutException" `
            -ErrorId "RemotingTimeoutException" -ErrorCategory "ObjectNotFound"))
        }
      }
    }
  }
}

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

    Invoke-AnsiblePlaybook $param

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

  Invoke-AnsiblePlaybook $param

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

  Invoke-AnsiblePlaybook $param

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

  Invoke-AnsibleInventory $p

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

  Invoke-AnsibleInventory $p

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

function Invoke-AnsibleHostCommand {
  [CmdletBinding()]
  [Alias("ansible-host-exec")]
  param (
      [Parameter(Mandatory=$true)]
      [string] $Command,
      [string] $Subset = "all",
      [string] $InventoryFile = "inventories\vagrant.ini"
  )

  ensureAnsibleRoot

  $p  = "-i $(Get-FilePathForContainer $InventoryFile -MustBeChild) "
  $p += "-m command -a `"$Command`" $Subset"

  Invoke-Ansible $p

  returnAnsibleRoot
}

function Invoke-AnsiblePlayBase {
  [CmdletBinding()]
  [Alias("ansible-play-base")]
  param (
      [string] $Subset,
      [string[]] $Tags,
      [Alias("Dev", "Development")]
      [switch] $OnlyDevelopment,
      [switch] $Minimal
  )

  ensureAnsibleRoot

  if ($PSBoundParameters.ContainsKey('Verbose')) {
    $param = "-vvv"
  } else {
    $param = "-v"
  }

  if ($PSBoundParameters.ContainsKey('OnlyDevelopment')) {
    if ($Subset.Length -gt 0) {
      $param += " --limit $Subset"
    } else {
      $param += " --limit ansibledev"
    }
  } else {
    if ($Subset.Length -gt 0) {
      $param += " --limit $Subset"
    }
  }

  if ($PSBoundParameters.ContainsKey('Minimal')) {
    $Tags = @("minimal")
  } else {
    $Tags = @("all")
  }

  $param += " --tags " + $Tags -join ","
  $param += " -i ./inventories/vagrant.ini ./playbooks/base.yml"

  Write-Verbose $param

  Invoke-AnsiblePlaybook $param

  returnAnsibleRoot
}

function Invoke-AnsiblePlayDev {
  [CmdletBinding()]
  [Alias("ansible-dev-play", "ansible-play-dev")]
  param (
      [Parameter(Mandatory=$true)]
      [string] $Role,
      [string] $Subset = "ansibledev",
      [string[]] $Tags = @("all"),
      [switch] $NoStep,
      [switch] $Step
  )

  ensureAnsibleRoot

  $play  = "---`n- hosts: $Subset`n"
  $play += "  any_errors_fatal: true`n  become: true`n"
  $play += "  roles:`n     - $Role`n"

  Set-Content -Path ".tmp/play.yml" -Value $play -Force -NoNewline

  if ($PSBoundParameters.ContainsKey('Verbose')) {
    $param = "-vvv "
  } else {
    $param = "-v "
  }

  if ($PSBoundParameters.ContainsKey('Step')) {
    $param += "--step "
  }

  $param += "--limit $Subset --tags " + $Tags -join ","
  $param += " -i ./inventories/vagrant.ini .tmp/play.yml"

  Invoke-AnsiblePlaybook $param

  returnAnsibleRoot
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
    Invoke-AnsiblePlaybook "$param | tee .tmp/$fileName`n"
    $env:ANSIBLE_NOCOLOR = $original
  }

  if (Test-Path .tmp/$fileName) {
    Move-Item -Path .tmp/$fileName -Destination $logfile
  }

  returnAnsibleRoot
}

function Invoke-AnsiblePlayRaspi {
  [CmdletBinding()]
  [Alias("ansible-raspi-play", "ansible-play-raspi")]
  param (
    [Parameter(Mandatory=$true)]
    [string] $Role,
    [string[]] $Tags = @("all")
  )

  Invoke-AnsiblePlayTest -Role $Role -Subset "debian11" -Tags $Tags
}

function Invoke-AnsiblePlayTest {
  [CmdletBinding()]
  [Alias("ansible-test-play", "ansible-play-test")]
  param (
      [Parameter(Mandatory=$true)]
      [string] $Role,
      [string] $Subset = "all",
      [string[]] $Tags = @("all")
  )

  ensureAnsibleRoot

  $play  = "---`n- hosts: $Subset`n"
  $play += "  any_errors_fatal: true`n  become: true`n"
  $play += "  roles:`n     - $Role`n"

  Set-Content -Path ".tmp/play.yml" -Value $play -Force -NoNewline

  if ($PSBoundParameters.ContainsKey('Verbose')) {
    $param = "-vvv"
  } else {
    $param = "-v"
  }

  $param += " --limit $Subset --tags " + $Tags -join ","
  $param += " -i ./inventories/vagrant.ini .tmp/play.yml"

  Invoke-AnsiblePlaybook $param

  returnAnsibleRoot
}

function New-AnsibleRole {
  [CmdletBinding()]
  [Alias("ansible-role-new", "ansible-new-role")]
  param (
    [Parameter(Mandatory=$true)]
    [string] $Role,
    [switch] $Force
  )

  ensureAnsibleRoot

  $Path = (Resolve-Path $PWD).Path + "/roles/$Role"

  Write-Verbose "Role Path: $Path"

  if (Test-Path $Path) {
    if ($Force) {
      Remove-Item -Path $Path -Recurse -Force
    } else {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "Role exists! Use -Force to replace." `
      -ExceptionType "System.IO.IOException" `
      -ErrorId "NewItemIOError" -ErrorCategory "ResourceExists"))
    }
  }

  Push-Location "roles/"

  Invoke-AnsibleGalaxy init $Role

  Pop-Location

  returnAnsibleRoot
}

function Ping-AnsibleHost {
  [CmdletBinding()]
  [Alias("ansible-host-ping")]
  param (
    [string] $Subset = "all",
    [string] $InventoryFile = "inventories\vagrant.ini"
  )

  ensureAnsibleRoot

  $play  = "---`n- hosts: $Subset`n"
  $play += "  gather_facts: no`n  warn: no`n"
  $play += "  tasks:`n     - ping:`n"

  Set-Content -Path ".tmp/play.yml" -Value $play -Force -NoNewline

  Invoke-AnsiblePlaybook $("-v --limit $Subset " `
    + "-i $(Get-FilePathForContainer $InventoryFile -MustBeChild) .tmp/play.yml")

  returnAnsibleRoot
}

function Remove-AnsibleVagrantHosts {
  ensureAnsibleRoot

  & vagrant destroy --force

  if (Test-Path -Path "ansible.log") {
    Remove-Item -Path "ansible.log" -Force
  }

  if (Test-Path -Path ".vagrant") {
    Remove-Item -Path ".vagrant" -Recurse -Force
  }

  if (Test-Path -Path ".tmp") {
    Remove-Item -Path ".tmp" -Recurse -Force
  }

  returnAnsibleRoot
}

function Reset-AnsibleEnvironmentDev {
  [CmdletBinding()]
  [Alias("ansible-dev-reset", "ansible-reset-dev")]
  param (
    [string] $Role
  )

  $ea = $ErrorActionPreference
  $ErrorActionPreference = "Stop"
  ensureAnsibleRoot

  try {
    Remove-AnsibleVagrantHosts

    checkReset 5,6

    Write-Verbose "Starting the Base playbook with the minimal tag..."

    $p = "-v --limit ansibledev --tags minimal --flush-cache " `
      + "-i ./inventories/vagrant.ini ./playbooks/base.yml"

    Invoke-AnsiblePlaybook $p

    if ($Role) {
      Write-Verbose "Playing the '$Role' play..."
      Invoke-AnsiblePlayDev -Role $Role -NoStep
    }
  } finally {
    $ErrorActionPreference = $ea

    returnAnsibleRoot
  }
}

function Reset-AnsibleEnvironmentRaspi {
  [CmdletBinding()]
  [Alias("ansible-raspi-reset", "ansible-reset-raspi")]
  param (
    [string] $Role
  )

  $ea = $ErrorActionPreference
  $ErrorActionPreference = "Stop"
  ensureAnsibleRoot

  try {
    Remove-AnsibleVagrantHosts

    checkReset 9

    $p = "-v --limit debian11 --tags minimal --flush-cache " `
      + "-i ./inventories/vagrant.ini ./playbooks/base.yml"

    Invoke-AnsiblePlaybook $p

    if ($Role) {
      Invoke-AnsiblePlayRaspi -Role $Role -NoStep
    }
  } finally {
    $ErrorActionPreference = $ea

    returnAnsibleRoot
  }
}

function Reset-AnsibleEnvironmentTest {
  [CmdletBinding()]
  [Alias("ansible-test-reset", "ansible-reset-test")]
  param (
    [string] $Role
  )

  $ea = $ErrorActionPreference
  $ErrorActionPreference = "Stop"

  ensureAnsibleRoot

  try {
    Remove-AnsibleVagrantHosts

    Write-Output " "

    checkReset 5,6,7,8,9,10

    $p = "-v --tags minimal --flush-cache " `
      + "-i ./inventories/vagrant.ini ./playbooks/base.yml"

    Invoke-AnsiblePlaybook $p

    if ($Role) {
      Invoke-AnsiblePlayTest -Role $Role -NoStep
    }
  } finally {
    $ErrorActionPreference = $ea

    returnAnsibleRoot
  }
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

function Test-AnsibleProvision {
  [CmdletBinding()]
  [Alias("ansible-provision-test")]
  param (
    [Parameter(Mandatory=$true)]
    [string] $ComputerName,
    [switch] $NoRecreate
  )

  ensureAnsibleRoot

  if (-not ($NoRecreate)) {
    Remove-AnsibleVagrantHosts

    checkReset 5
  }

  if (Test-Path $script:vaultPasswd) {
    $vault = "--vault-password-file $($script:vaultPasswd)"
  } else {
    $vault = "--ask-vault-password"
  }

  if ($PSBoundParameters.ContainsKey('Verbose')) {
    $v = "-vvv"
  } else {
    $v = "-v"
  }

  Invoke-AnsiblePlaybook $("$vault $v -e `"ansible_host=192.168.57.5`" " `
    + "-e `"ansible_ssh_private_key_file=~/.ssh/insecure_private_key`" " `
    + "-e `"ansible_user=vagrant`" " `
    + "-i ./inventories/hosts.ini ./playbooks/$ComputerName.yml")

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
    Invoke-AnsiblePlaybook "$param | tee .tmp/$fileName`n"
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

    Invoke-AnsiblePlaybook $param

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

function Update-AnsibleVagrantImages {
  & vagrant box update

  & vagrant box prune --force --keep-active-boxes
}
