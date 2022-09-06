function Get-AvailableOpenSslCiphers {
  Invoke-OpenSsl "enc -list"
}

function Get-AvailableOpenSslEllipticCurves {
  Invoke-OpenSsl "ecparam -list_curves"
}

function Get-OpenSslRsaPrivateKey {
  [CmdletBinding()]
  param (
    [string] $Path
  )

  Invoke-OpenSsl "rsa -text -in $Path -noout"
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
    $param += " -pass pass:$($cred.GetNetworkCredential().Password)"
  }


  Invoke-OpenSsl "$param $BitSize"

  Invoke-OpenSsl "rsa -in $Path -pubout -out $Path.pub"
}
