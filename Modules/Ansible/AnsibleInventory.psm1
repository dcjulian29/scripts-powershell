function executeInventory([string]$Action, [string]$InventoryFile) {
  $Action = $action.Trim()

  if ("" -ne $InventoryFile) {
    $InventoryFile = Get-FileNameForContainer $InventoryFile

    Invoke-AnsibleInventory "--inventory $InventoryFile $Action"
  } else {
    Invoke-AnsibleInventory "$Action"
  }
}

#------------------------------------------------------------------------------

function Get-AnsibleInventoryGraph {
  [CmdletBinding()]
  param (
      [string] $InventoryFile
  )

  executeInventory '--graph' $InventoryFile
}

function Get-AnsibleInventoryAsJson {
  [CmdletBinding()]
  param (
      [string] $InventoryFile
  )

  executeInventory '--list' $InventoryFile
}

function Get-AnsibleInventoryAsToml {
  [CmdletBinding()]
  param (
      [string] $InventoryFile
  )

  executeInventory '--list --toml' $InventoryFile
}

function Get-AnsibleInventoryAsYaml {
  [CmdletBinding()]
  param (
      [string] $InventoryFile
  )

  executeInventory '--list --yaml' $InventoryFile
}
