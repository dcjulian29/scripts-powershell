$script:rootDir = $false
$script:nested = 0

function checkReset([string[]]$pingHosts) {
  foreach ($ping in $pingHosts) {

    Write-Host -NoNewline "Searching for 10.10.10.$ping..."
    $found = $false

    while (-not $found) {
      $found = Test-Connection -ComputerName "10.0.0.$ping" -Quiet -Count 1

      if ($found) {
        Write-Host -ForegroundColor Green " [Found]"
      } else {
        Write-Host -NoNewline "."
      }
    }

    ssh-keygen -R 10.0.0.$ping
  }
}

function ensureAnsibleRoot {
  if ($script:rootDir) {
    $script:nested++

    return
  }

  # is Environment_Var set?
  # check current directory
  # walk up filesystem and check each directory until root dir.

  # if file still not found, pscmdlet.throwterminatingerror

  Push-Location $PWD

  $script:rootDir = $true
}

function returnAnsibleRoot {
  if ($script:rootDir) {
    if ($script:nested -gt 0) {
      $script:nested--

      return
    }

    Pop-Location

    Get-DockerContainer | Where-Object { $_.Name -eq "ansible_shell" } `
      | Remove-DockerContainer | Out-Null

    $script:rootDir = $false
  }
}

#-----------------------------------------------------------------------------------------------------

function Assert-AnsibleProvision {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [string] $ComputerName
  )

  ensureAnsibleRoot

  $param  = "--ask-vault-password --check --diff"
  $param += " -i ./inventories/hosts.ini ./playbooks/$ComputerName.yml"

  Invoke-AnsibleContainer -EntryPoint "ansible-playbook" `
    -Command "$param" -EnvironmentVariables @{
      "ANSIBLE_HOST_KEY_CHECKING" = "true"
      "ANSIBLE_DISPLAY_OK_HOSTS" = "no"
      "ANSIBLE_DISPLAY_SKIPPED_HOSTS" = "no"
    }

  returnAnsibleRoot
}

Set-Alias -Name ansible-provision-check -Value Assert-AnsibleProvision

function Get-AnsibleFacts {
  param (
    [string] $ComputerName = "all",
    [string] $InventoryFile = "./inventories/vagrant.ini",
    [switch] $OnlyAnsible
  )

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
}

Set-Alias -Name ansible-show-facts -Value Get-AnsibleFacts

function Get-AnsibleHostVariables {
  param (
    [Parameter(Mandatory=$true)]
    [string] $ComputerName,
    [string] $InventoryFile = "./inventories/vagrant.ini"
  )

  $p = "-i $(Get-FilePathForContainer $InventoryFile -MustBeChild) " `
    + "--yaml --vars -vvv --host $ComputerName"

  Invoke-AnsibleInventory $p
}

Set-Alias -Name ansible-show-hostvars -Value Get-AnsibleHostVariables

function Get-AnsibleVariables {
  param (
    [string] $InventoryFile = "./inventories/vagrant.ini"
  )

  $p = "-i $(Get-FilePathForContainer $InventoryFile -MustBeChild) --graph --vars -vvv"

  Invoke-AnsibleInventory $p
}

Set-Alias -Name ansible-show-vars -Value Get-AnsibleVariables

function Invoke-AnsibleHostCommand {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [string] $Command,
      [string] $Subset = "all",
      [string] $InventoryFile = "inventories\vagrant.ini"
  )

  ensureAnsibleRoot

  $param  = "-i $(Get-FilePathForContainer $InventoryFile -MustBeChild) "
  $param += "-m command -a `"$Command`" $Subset"

  Invoke-Ansible "$param"

  returnAnsibleRoot
}

Set-Alias -Name ansible-hosts-exec -Value Invoke-AnsibleHostCommand

function Invoke-AnsiblePlayBase {
  [CmdletBinding()]
  param (
      [string] $Subset,
      [string[]] $Tags,
      [Alias("Dev", "Development")]
      [switch] $OnlyDevelopment,
      [switch] $Minimal
  )

  ensureAnsibleRoot

  $param = "-v"

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

  Invoke-AnsiblePlaybook $param

  returnAnsibleRoot
}

Set-Alias -Name ansible-play-base -Value Invoke-AnsiblePlayBase

function Invoke-AnsiblePlayDev {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory=$true)]
      [string] $Role,
      [string] $Subset = "ansibledev",
      [string[]] $Tags = @("all"),
      [switch] $NoStep
  )

  ensureAnsibleRoot

  $play  = "---`n- hosts: $Subset`n"
  $play += "  any_errors_fatal: true`n  become: true`n"
  $play += "  roles:`n     - $Role`n"

  Set-Content -Path ".tmp/play.yml" -Value $play -Force -NoNewline

  $param = "-v "

  if (-not ($PSBoundParameters.ContainsKey('NoStep'))) {
    $param += "--step "
  }

  $param += "--limit $Subset --tags " + $Tags -join ","
  $param += " -i ./inventories/vagrant.ini .tmp/play.yml"

  Invoke-AnsiblePlaybook $param

  returnAnsibleRoot
}

Set-Alias -Name ansible-dev-play -Value Invoke-AnsiblePlayDev
Set-Alias -Name ansible-play-dev -Value Invoke-AnsiblePlayDev

function Invoke-AnsibleProvision {
  [CmdletBinding()]
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

  Invoke-AnsibleContainer -EntryScript ".tmp/entrypoint.sh" `
    -EnvironmentVariables @{
      "ANSIBLE_NOCOLOR" = "1"
    }

  if (Test-Path .tmp/$fileName) {
    Move-Item -Path .tmp/$fileName -Destination $logfile
  }

  returnAnsibleRoot
}

Set-Alias -Name ansible-provision-server -Value Invoke-AnsibleProvision

function Invoke-AnsiblePlayTest {
  [CmdletBinding()]
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

  $param = "-v --limit $Subset --tags " + $Tags -join ","
  $param += " -i ./inventories/vagrant.ini .tmp/play.yml"

  Invoke-AnsiblePlaybook $param

  returnAnsibleRoot
}

Set-Alias -Name ansible-test-play -Value Invoke-AnsiblePlayTest
Set-Alias -Name ansible-play-test -Value Invoke-AnsiblePlayTest

function Ping-AnsibleHost {
  [CmdletBinding()]
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

Set-Alias -Name ansible-hosts-ping -Value Ping-AnsibleHost

function Remove-AnsibleVagrantHosts {
  ensureAnsibleRoot

  if (Test-Path "ansible.log") {
    Remove-Item -Path "ansible.log" -Force
  }

  & vagrant destroy --force

  if (Test-Path ".vagrant") {
    Remove-Item -Path ".vagrant" -Recurse -Force
  }

  returnAnsibleRoot
}

function Reset-AnsibleEnvironmentDev {
  [CmdletBinding()]
  param (
    [string] $Role
  )

  $ea = $ErrorActionPreference
  $ErrorActionPreference = "Stop"
  ensureAnsibleRoot

  try {
    Remove-AnsibleVagrantHosts

    & vagrant up ubuntu2004 centos8

    checkReset 5,6

    Invoke-AnsiblePlaybook -v --limit ansibledev --tags minimal --flush-cache `
      -i ./inventories/vagrant.ini ./playbooks/base.yml

    if ($Role) {
      Invoke-AnsibleDevPlay $Role
    }
  } finally {
    $ErrorActionPreference = $ea

    returnAnsibleRoot
  }
}

Set-Alias "ansible-dev-reset" -Value Reset-AnsibleEnvironmentDev
Set-Alias "ansible-reset-dev" -Value Reset-AnsibleEnvironmentDev

function Reset-AnsibleEnvironmentTest {
  [CmdletBinding()]
  param (
    [string] $Role
  )

  $ea = $ErrorActionPreference
  $ErrorActionPreference = "Stop"

  ensureAnsibleRoot

  try {
    Remove-AnsibleVagrantHosts

    & vagrant box update

    & vagrant box prune --force --keep-active-boxes

    & vagrant up

    checkReset 5,6,7,8,9,10

    Invoke-AnsiblePlaybook -v --limit ansibledev --tags minimal --flush-cache `
      -i ./inventories/vagrant.ini ./playbooks/base.yml

    if ($Role) {
      Invoke-AnsibleDevPlay $Role
    }
  } finally {
    $ErrorActionPreference = $ea

    returnAnsibleRoot
  }
}

Set-Alias "ansible-test-reset" -Value Reset-AnsibleEnvironmentTest
Set-Alias "ansible-reset-test" -Value Reset-AnsibleEnvironmentTest

function Test-AnsibleProvision {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [string] $ComputerName,
    [switch] $NoRecreate
  )

  ensureAnsibleRoot

  if (-not ($NoRecreate)) {
    Remove-AnsibleVagrantHosts

    & vagrant up ubuntu2004
  }

  checkReset 5

  Invoke-AnsiblePlaybook $("--ask-vault-password -v " `
    + "-e `"ansible_host=10.0.0.5`" " `
    + "-e `"ansible_ssh_private_key_file=~/.ssh/insecure_private_key`" " `
    + "-e `"ansible_user=vagrant`" " `
    + "-i ./inventories/hosts.ini ./playbooks/$ComputerName.yml")

  returnAnsibleRoot
}

Set-Alias -Name ansible-provision-test -Value Test-AnsibleProvision

function Update-AnsibleHost {
  [CmdletBinding()]
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

  $param = "-v --limit $Subset"

  if ($AskBecomePassword) {
    $param += " --ask-become-pass"
  }

  $param += " -i $(Get-FilePathForContainer $InventoryFile -MustBeChild) .tmp/play.yml"

  $ep  = "#!/bin/bash`n`nansible-playbook $param | tee .tmp/$fileName`n"

  Set-Content -Path ".tmp/entrypoint.sh" -Value $ep -Force -NoNewline

  Invoke-AnsibleContainer -EntryScript ".tmp/entrypoint.sh" `
    -EnvironmentVariables @{
      "ANSIBLE_NOCOLOR" = "1"
    }

  if (Test-Path .tmp/$fileName) {
    Move-Item -Path .tmp/$fileName -Destination $logfile
  }

  returnAnsibleRoot
}

Set-Alias -Name ansible-hosts-update -Value Update-AnsibleHost

function Update-AnsibleProvision {
  [CmdletBinding()]
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

  Invoke-AnsibleContainer -EntryScript ".tmp/entrypoint.sh" `
    -EnvironmentVariables @{
      "ANSIBLE_NOCOLOR" = "1"
      "ANSIBLE_HOST_KEY_CHECKING" = "true"
      "ANSIBLE_DISPLAY_OK_HOSTS" = "no"
      "ANSIBLE_DISPLAY_SKIPPED_HOSTS" = "no"
    }

  if (Test-Path .tmp/$fileName) {
    Move-Item -Path .tmp/$fileName -Destination $logfile
  }

  returnAnsibleRoot
}

Set-Alias -Name ansible-provision-update -Value Update-AnsibleProvision

#------------------------------------------------------------------------------
# Temporary as I move from my WSL enviornment to PS/Docker
Set-Alias -Name "destroy.sh" -Value Remove-AnsibleVagrantHosts
Set-Alias -Name "exec-hosts.sh" -Value Invoke-AnsibleHostCommand
Set-Alias -Name "ping-hosts.sh" -Value Ping-AnsibleHost
Set-Alias -Name "play-base.sh" -Value Invoke-AnsiblePlayBase
Set-Alias -Name "play-dev.sh" -Value Invoke-AnsiblePlayDev
Set-Alias -Name "play-test.sh" -Value Invoke-AnsiblePlayTest
Set-Alias -Name "provision-check.sh" -Value Assert-AnsibleProvision
Set-Alias -Name "provision-server.sh" -Value Invoke-AnsibleProvision
Set-Alias -Name "provision-test.sh" -Value Test-AnsibleProvision
Set-Alias -Name "provision-update.sh" -Value Update-AnsibleProvision
Set-Alias -Name "reset-dev.sh" -Value Reset-AnsibleEnvironmentDev
Set-Alias -Name "reset-test.sh" -Value Reset-AnsibleEnvironmentTest
Set-Alias -Name "show-facts.sh" -Value Get-AnsibleFacts
Set-Alias -Name "show-hostvars.sh" -Value Get-AnsibleHostVariables
Set-Alias -Name "show-vars.sh" -Value Get-AnsibleVariables
Set-Alias -Name "update-servers.sh" -Value Update-AnsibleHost
