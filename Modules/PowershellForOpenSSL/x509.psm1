function Get-AvailableOpenSslCiphers {
  Invoke-OpenSsl "enc -list"
}

Set-Alias -Name "Get-OpenSslCiphers" -Value Get-AvailableOpenSslCiphers

function Get-AvailableOpenSslEllipticCurves {
  Invoke-OpenSsl "ecparam -list_curves"
}

Set-Alias -Name "Get-OpenSslEllipticCurves" -Value Get-AvailableOpenSslEllipticCurves

function Get-DeployedCertificate {
  [CmdletBinding(DefaultParameterSetName = 'Text')]
  param (
    [Parameter(ParameterSetName = "Text", Position = 0, Mandatory = $true)]
    [Parameter(ParameterSetName = "Save", Position = 0, Mandatory = $true)]
    [Alias("FQDN", "FullyQualifiedDomainName", "DomainName")]
    [string] $Domain,
    [Parameter(ParameterSetName = "Text", Position = 1)]
    [Parameter(ParameterSetName = "Save", Position = 1)]
    [Int32] $Port = 443,
    [Parameter(ParameterSetName = "Save", Position = 2)]
    [string] $Save
  )

  $cmd = Find-OpenSsl

  if ($Save) {
    $param = "x509 -in <(openssl s_client -servername $Domain -connect ${Domain}:$Port -prexit 2>/dev/null)"
  } else {
    $param = "x509 -text -noout -in <(openssl s_client -servername $Domain -connect ${Domain}:$Port -prexit 2>/dev/null)"
  }

  Write-Verbose "param: $param"

  if ($cmd -notlike "*docker*") {
    if ($Save) {
      cmd.exe /c "echo | $cmd $param > $Save"
    } else {
      cmd.exe /c "echo | $cmd $param"
    }
  } else {
    $cmd = "echo | openssl $param"

    Write-Verbose "cmd: $cmd"

    $cert = Invoke-OpenSslContainer -EntryPoint "/bin/bash" -Command "-c '$cmd'" -Direct

    if ($Save) {
      Set-Content -Path $Save -Value $cert
    } else {
      return $cert
    }
  }
}
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

function Test-DeployedCertificate {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [Alias("FQDN", "FullyQualifiedDomainName", "DomainName")]
    [string] $Domain,
    [Parameter(Position = 1)]
    [Int32] $Port = 443,
    [switch] $Strict,
    [switch] $IncludeCrlChecks
  )

  $param = "s_client -connect ${Domain}:$Port"

  if ($Strict) {
    $param += " -strict -x509_strict"
  }

  if ($IncludeCrlChecks) {
    $param += " -extended_crl -crl_check_all"
  }

  Invoke-OpenSsl $param
}
