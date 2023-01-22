function Edit-AnsibleVault {
  [CmdletBinding()]
  [Alias("ansible-vault-edit")]
  param (
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Vault
  )

  if ($Vault.Length -eq 0) {
    $Vault = "./secrets.yml"
  }

  Invoke-AnsibleVault edit $Vault
}

function Protect-AnsibleVariable {
  [Alias("ansible-encrypt")]
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

function Show-AnsibleVault {
  [CmdletBinding()]
  [Alias("ansible-vault-view")]
  param (
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Vault
  )

  if ($Vault.Length -eq 0) {
    $Vault = "./secrets.yml"
  }

  Invoke-AnsibleVault view $Vault
}
