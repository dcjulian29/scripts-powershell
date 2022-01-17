[Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime] | Out-Null
$script:vault = New-Object -TypeName 'Windows.Security.Credentials.PasswordVault'

function Get-WebCredential {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position = 0)]
    [string] $Name,
    [switch] $SecurePassword,
    [switch] $Password,
    [switch] $Username
  )

  try {
    $vaultCredential = $script:vault.FindAllByResource($Name)
  } catch {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "Element not found. Cannot find credential in Vault!" `
      -ExceptionType "System.ArgumentException" `
      -ErrorId "ArgumentException" `
      -ErrorCategory NotSpecified `
      -TargetObject $Name))
  }

  if ($vaultCredential) {
    if ($vaultCredential.AdditionalTypeData) {
      $vaultCredential = $vaultCredential.AdditionalTypeData.GetEnumerator() `
        | Select-Object -First 1 -ExpandProperty Value | Select-Object -First 1
    } else {
      $vaultCredential = $vaultCredential | Select-Object -First 1
    }

    $null = $vaultCredential.RetrievePassword()

    if ($SecurePassword) {
      return $($vaultCredential.Password | ConvertTo-SecureString -AsPlainText -Force)
    }

    if ($Password) {
      return $vaultCredential.Password
    }

    if ($Username) {
      return $vaultCredential.UserName
    }

    return [PSCredential]::New( `
      $vaultCredential.UserName, `
      ($vaultCredential.Password | ConvertTo-SecureString -AsPlainText -Force))
  }
}

function Remove-WebCredential {
  [CmdletBinding(DefaultParameterSetName='UserPass')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword','')]
  param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position = 0)]
    [string] $Name
  )

  try {
    $vaultCredential = $script:vault.FindAllByResource($Name)
  } catch {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "Element not found. Cannot find credential in Vault!" `
      -ExceptionType "System.ArgumentException" `
      -ErrorId "ArgumentException" `
      -ErrorCategory NotSpecified `
      -TargetObject $Name))
  }


  if ($vaultCredential) {
    if ($vaultCredential.AdditionalTypeData) {
      $vaultCredential = $vaultCredential.AdditionalTypeData.GetEnumerator() `
        | Select-Object -First 1 -ExpandProperty Value | Select-Object -First 1
    } else {
      $vaultCredential = $vaultCredential | Select-Object -First 1
    }

    $script:vault.Remove($vaultCredential)
  }
}

function Set-WebCredential {
  [CmdletBinding(DefaultParameterSetName='UserPass')]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword','')]
  param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position = 0)]
    [string] $Name,
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position = 1, ParameterSetName='Credential')]
    [PSCredential] $Credential,
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position = 1, ParameterSetName='UserPass')]
    [string] $Username,
    [Parameter(Mandatory=$true,  ValueFromPipelineByPropertyName=$true, Position = 2, ParameterSetName='UserPass')]
    [Object] $Password
  )

  if ($Password -is [SecureString]) {
    $credential = [PSCredential]::new($Username, $Password)
  } else {
    $Password = [string]$Password
  }

  if ($credential) {
    $Username = $credential.UserName
    $Password = $credential.GetNetworkCredential().Password
  }

  $script:vault.Add(
    [Windows.Security.Credentials.PasswordCredential]::New($Name, $Username, $Password))
}
