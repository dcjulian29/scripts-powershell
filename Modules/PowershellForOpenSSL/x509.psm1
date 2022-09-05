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

function New-OpenSslRsaPublicPrivateKeypair {
  [CmdletBinding()]
  param (
    [string] $Path,
    [int32] $BitSize = 2048
  )

  Invoke-OpenSSL "genrsa -out $Path -verbose $BitSize"
}
