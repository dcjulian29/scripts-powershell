function Get-AvailableOpenSSLCiphers {
  Invoke-OpenSSL "enc -list"
}

function Get-AvailableOpenSSLEllipticCurves {
  Invoke-OpenSSL "ecparam -list_curves"
}

function Get-OpenSSLRsaPrivateKey {
  [CmdletBinding()]
  param (
    [string] $Path
  )

  Invoke-OpenSSL "rsa -text -in $Path -noout"
}

function New-OpenSSLRsaPrivateKey {
  [CmdletBinding()]
  param (
    [string] $Path,
    [int32] $BitSize = 2048
  )

  Invoke-OpenSSL "genrsa -out $Path -verbose $BitSize"
}
