function Get-AvailableOpenSslCiphers {
  Invoke-OpenSsl "enc -list"
}

Set-Alias -Name "Get-OpenSslCiphers" -Value Get-AvailableOpenSslCiphers

function Get-AvailableOpenSslEllipticCurves {
  Invoke-OpenSsl "ecparam -list_curves"
}

Set-Alias -Name "Get-OpenSslEllipticCurves" -Value Get-AvailableOpenSslEllipticCurves

function Get-OpenSslEdwardsCurveKeypair  {
  [CmdletBinding()]
  param (
    [string] $Path
  )

  Invoke-OpenSsl "pkey -in $Path -text -noout"
}

function Get-OpenSslElipticCurveKeypair {
  [CmdletBinding()]
  param (
    [string] $Path
  )

  Invoke-OpenSsl "ec -in $Path -pubout -text -param_enc explicit -noout"
}

function Get-OpenSslRsaPrivateKey {
  [CmdletBinding()]
  param (
    [string] $Path
  )

  Invoke-OpenSsl "rsa -text -in $Path -noout"
}

function New-OpenSslEdwardsCurveKeypair {
  [CmdletBinding()]
  param (
    [string] $Path = "id_ed25519",
    [securestring] $Password
  )

  $param = "genpkey -algorithm ed25519 -out $Path"

  if ($Password) {
    $cred = New-Object System.Management.Automation.PSCredential `
      -ArgumentList "NotImportant", $Password
    $param += " -aes-256-cfb -pass pass:$(($cred.GetNetworkCredential().Password).Trim())"
  }

  Invoke-OpenSsl $param

  if ($Password) {
    Invoke-OpenSsl `
      "pkey -in $Path -passin pass:$(($cred.GetNetworkCredential().Password).Trim()) -pubout -out $Path.pub"
  } else {
    Invoke-OpenSsl "pkey -in $Path -pubout -out $Path.pub"
  }
}

function New-OpenSslElipticCurveKeypair {
  [CmdletBinding()]
  param (
    [string] $Path = "id_ecdsa",
    [securestring] $Password,
    [string] $Algorithm = "secp521r1"
  )

  Invoke-OpenSsl "ecparam -name $Algorithm -genkey -noout -out $Path"
  Invoke-OpenSsl "ec -in $Path -pubout -out $Path.pub"

  if ($Password) {
    $cred = New-Object System.Management.Automation.PSCredential `
      -ArgumentList "NotImportant", $Password

    Write-Output "Encrypting private key..."
    $param  = "ec -aes-256-cfb -in $Path -out $Path.tmp"
    $param += " -passout pass:$(($cred.GetNetworkCredential().Password).Trim())"

    Invoke-OpenSsl $param

    Move-Item -Path "$Path.tmp" -Destination $Path -Force
  }
}

function New-OpenSslRsaKeypair {
  [CmdletBinding()]
  param (
    [string] $Path = "id_rsa",
    [securestring] $Password,
    [int32] $BitSize = 2048
  )

  $param = "genrsa -out $Path -verbose"

  if ($Password) {
    $cred = New-Object System.Management.Automation.PSCredential `
      -ArgumentList "NotImportant", $Password
    $param += " -aes-256-cfb -passout pass:$(($cred.GetNetworkCredential().Password).Trim())"
  }

  Invoke-OpenSsl "$param $BitSize"

  if ($Password) {
    Invoke-OpenSsl `
      "rsa -in $Path -passin pass:$(($cred.GetNetworkCredential().Password).Trim()) -pubout -out $Path.pub"
  } else {
    Invoke-OpenSsl "rsa -in $Path -pubout -out $Path.pub"
  }
}
