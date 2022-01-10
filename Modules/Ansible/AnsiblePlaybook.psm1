function executePlaybook {
  param(
    [string] $Playbook,
    [string] $Action,
    [string] $InventoryFile,
    [bool] $AskVaultPassword
  )

  $Action = $action.Trim()

  if (Test-Path "playbooks/$Playbook.yml") {
    $Action += " $(Get-FilePathForContainer -Path "Playbooks/$Playbook.yml" -MustBeChild)"
  } else {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "Playbook does not exists!" `
      -ExceptionType "System.Management.Automation.ItemNotFoundException" `
      -ErrorId "ResourceUnavailable" -ErrorCategory "ResourceUnavailable"))
  }

  if ("" -ne $InventoryFile) {
    if ($InventoryFile.Contains('/') -or $InventoryFile.Contains('\')) {
      $InventoryFile = "inventories/$InventoryFile"
    }

    if (Test-Path "$InventoryFile") {
      $Action += Get-FileNameForContainer -Path "$InventoryFile" -MustBeChild
    } else {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "Inventory file does not exists!" `
        -ExceptionType "System.Management.Automation.ItemNotFoundException" `
        -ErrorId "ResourceUnavailable" -ErrorCategory "ResourceUnavailable"))
    }

    $Action = "--inventory $InventoryFile $Action"
  }

  if ($AskVaultPassword) {
    $Action = "--ask-vault-password $Action"
  }

  Write-Verbose $Action
  Invoke-AnsiblePlaybook "$Action"
}

#------------------------------------------------------------------------------

function Confirm-AnsiblePlaybookSyntax {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias("Path", "Playbook")]
    [string] $PlaybookPath
  )

  executePlaybook $PlaybookPath "--syntax-check"
}

Set-Alias -Name Check-AnsiblePlaybookSyntax -Value Confirm-AnsiblePlaybookSyntax
Set-Alias -Name Validate-AnsiblePlaybookSyntax -Value Confirm-AnsiblePlaybookSyntax
Set-Alias -Name ansible-playbook-syntaxcheck -Value Confirm-AnsiblePlaybookSyntax

function Get-AnsiblePlaybookHosts {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias("Path", "Playbook")]
    [string] $PlaybookPath,
    [string] $InventoryFile,
    [switch] $AskVaultPassword
  )

  executePlaybook $PlaybookPath "--list-host" $InventoryFile $AskVaultPassword.IsPresent
}

Set-Alias -Name ansible-playbook-hosts -Value Get-AnsiblePlaybookHosts

function Get-AnsiblePlaybookTags {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias("Path", "Playbook")]
    [string] $PlaybookPath
  )

  executePlaybook $PlaybookPath "--list-tags"
}

Set-Alias -Name ansible-playbook-tags -Value Get-AnsiblePlaybookTags

function Get-AnsiblePlaybookTasks {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias("Path", "Playbook")]
    [string] $PlaybookPath
  )

  executePlaybook $PlaybookPath "--list-tasks"
}

Set-Alias -Name ansible-playbook-tasks -Value Get-AnsiblePlaybookTasks

function Test-AnsiblePlaybookSyntax {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias("Path", "Playbook")]
    [string] $PlaybookPath
  )

  $output = Confirm-AnsiblePlaybookSyntax $PlaybookPath

  if ($output -match "ERROR!") {
    return $false
  } else {
    return $true
  }
}

Set-Alias -Name ansible-playbook-test -Value Test-AnsiblePlaybook
