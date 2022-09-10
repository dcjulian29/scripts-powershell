function ConvertFrom-PemCertificate {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [Alias("Path", "Cert", "Certificate")]
    [string] $CertPath,
    [Parameter(Position = 1, Mandatory = $true)]
    [string] $Destination,
    [ValidateSet("DER", "P12", "PFX")]
    [Parameter(Position = 3, Mandatory = $true)]
    [string] $To,
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [Alias("Key")]
    [string] $KeyPath
  )

  switch ($To) {
    "DER" {
      $cmd = "x509 -outform der -in $CertPath -out $Destination"
    }

    "P12" {
      $cmd = "pkcs12 -export -out $Destination -in $CertPath"

      if ($KeyPath) {
        $cmd += " -inkey $KeyPath"
      }
    }

    "PFX" {
      $cmd = "pkcs12 -export -out $Destination -in $CertPath"

      if ($KeyPath) {
        $cmd += " -inkey $KeyPath"
      }
    }
  }

  Invoke-OpenSsl $cmd
}

function ConvertTo-PemCertificate {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [Alias("Path", "Cert", "Certificate")]
    [string] $CertPath,
    [Parameter(Position = 1, Mandatory = $true)]
    [string] $Destination,
    [ValidateSet("DER", "P12", "PFX")]
    [Parameter(Position = 2, Mandatory = $true)]
    [string] $From
  )

  switch ($From) {
    "DER" {
      $cmd = "x509 -inform der -in $CertPath -out $Destination"
    }

    "P12" {
      $cmd = "pkcs12 -in $CertPath -out $Destination -nodes"
    }

    "PFX" {
      $cmd = "pkcs12 -in $CertPath -out $Destination -nodes"
    }
  }

  Invoke-OpenSsl $cmd
}

function Get-AvailableOpenSslCiphers {
  Invoke-OpenSsl "enc -list"
}

Set-Alias -Name "Get-OpenSslCiphers" -Value Get-AvailableOpenSslCiphers

function Get-AvailableOpenSslEllipticCurves {
  Invoke-OpenSsl "ecparam -list_curves"
}

Set-Alias -Name "Get-OpenSslEllipticCurves" -Value Get-AvailableOpenSslEllipticCurves

function Get-Certificate {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path
  )

  Invoke-OpenSsl "x509 -noout -in $Path -text"
}

Set-Alias "show-certificate" -Value Get-Certificate

function Get-CertificateExpiration {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path
  )

  $response = Invoke-OpenSsl "x509 -enddate -noout -in $Path"

  Write-Verbose "response: $response"

  if ($response -like "*Unable to load certificate") {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "Unable to load certificate." `
      -ExceptionType "System.InvalidOperationException" `
      -ErrorId "System.InvalidOperation" `
      -ErrorCategory "InvalidOperation"))
  }

  if ($response -match 'notAfter\s*=\s*(.+)$') {
    Write-Verbose "notAfter Regex matched. (notAfter) is:  $($Matches[1].Trim())"

    $origialErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    try {
      $NotAfter = [DateTime]::ParseExact(
        [regex]::Replace(
            ($Matches[1] -replace '\s*GMT\s*$' -replace '(.+)\s+([\d:]+)\s+(\d{4})', '$1 $3 $2'), '(\w+)\s+(\d?\d)\s+(.+)', {
                $args[0].Groups[1].Value + " " + ("{0:D2}" -f [int] $args[0].Groups[2].Value) + " " + $args[0].Groups[3].Value
            }
        ), 'MMM dd yyyy HH:mm:ss', [CultureInfo]::InvariantCulture)
    }
    catch {
        $NotAfter = "Parse error"
    }

    $ErrorActionPreference = $origialErrorActionPreference
  }

  return $NotAfter
}

Set-Alias -Name "show-certificate-expiration" -Value Get-CertificateExpiration

function Get-CertificateHash {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path
  )

  Invoke-OpenSsl "x509 -noout -in $Path -hash"
}

Set-Alias -Name "show-certificate-hash" -Value Get-CertificateHash

function Get-CertificateRequest {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path
  )

  Invoke-OpenSsl "req -text -noout -verify -in $Path"
}

Set-Alias -Name "show-csr" -Value Get-CertificateRequest

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

function Get-DeployedCertificateExpiration {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [Alias("FQDN", "FullyQualifiedDomainName", "DomainName")]
    [string] $Domain,
    [Parameter(Position = 1)]
    [Int32] $Port = 443,
    [switch] $DaysUntilExpiration
  )

  $cmd = Find-OpenSsl
  $param = "x509 -enddate -noout -in <(openssl s_client -servername $Domain -connect ${Domain}:$Port -prexit 2>/dev/null)"

  Write-Verbose "param: $param"

  $response = ""

  if ($cmd -notlike "*docker*") {
    $response = cmd.exe /c "echo | $cmd $param"
  } else {
    $cmd = "echo | openssl $param"

    Write-Verbose "cmd: $cmd"

    $response = Invoke-OpenSslContainer -EntryPoint "/bin/bash" -Command "-c '$cmd'" -Direct
  }

  Write-Verbose "response: $response"

  if ($response -like "*Unable to load certificate") {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "Unable to load certificate." `
      -ExceptionType "System.InvalidOperationException" `
      -ErrorId "System.InvalidOperation" `
      -ErrorCategory "InvalidOperation"))
  }

  if ($response -match 'notAfter\s*=\s*(.+)$') {
    Write-Verbose "notAfter Regex matched. (notAfter) is:  $($Matches[1].Trim())"

    $origialErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Stop"

    try {
      $NotAfter = [DateTime]::ParseExact(
        [regex]::Replace(
            ($Matches[1] -replace '\s*GMT\s*$' -replace '(.+)\s+([\d:]+)\s+(\d{4})', '$1 $3 $2'), '(\w+)\s+(\d?\d)\s+(.+)', {
                $args[0].Groups[1].Value + " " + ("{0:D2}" -f [int] $args[0].Groups[2].Value) + " " + $args[0].Groups[3].Value
            }
        ), 'MMM dd yyyy HH:mm:ss', [CultureInfo]::InvariantCulture)
    }
    catch {
        $NotAfter = "Parse error"
    }

    $ErrorActionPreference = $origialErrorActionPreference
  }

  if ($DaysUntilExpiration) {
    return (New-TimeSpan -Start $(Get-Date) -End $NotAfter)
  } else {
    return $NotAfter
  }
}

function Get-DeployedCertificateValidity {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [Alias("FQDN", "FullyQualifiedDomainName", "DomainName")]
    [string] $Domain,
    [Parameter(Position = 1)]
    [Int32] $Port = 443,
    [Parameter(Position = 2)]
    [ValidateSet("SSL2", "SSL3", "TLS1", "TLS1.1", "TLS1.2", "TLS1.3")]
    [string] $Protocol,
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [Alias("CA", "CAFile", "CABundle")]
    [string] $CAPath,
    [switch] $Strict,
    [switch] $IncludeCrlChecks
  )

  $cmd = Find-OpenSsl
  $param = "s_client -servername $Domain -connect ${Domain}:$Port -brief"

  if ($Strict) {
    $param += " -strict -x509_strict"
  }

  if ($IncludeCrlChecks) {
    $param += " -extended_crl -crl_check_all"
  }

  switch ($Protocol) {
    "SSL2"   { $param += " -no_ssl3 -no_tls1 -no_tls1_1 -no_tls1_2 -no_tls1_3" }
    "SSL3"   { $param += " -no_tls1 -no_tls1_1 -no_tls1_2 -no_tls1_3" }
    "TLS1"   { $param += " -tls1" }
    "TLS1.1" { $param += " -tls1_1" }
    "TLS1.2" { $param += " -tls1_2" }
    "TLS1.3" { $param += " -tls1_3" }
    Default {}
  }

  $ca = "./.openssl.$((New-Guid).Guid).cacert.pem"

  if ($CAPath) {
    Copy-Item -Path $CAPath -Destination $ca
  } else {
    Invoke-WebRequest "https://curl.se/ca/cacert.pem" -OutFile $ca
  }

  if (Test-Path $ca) {
    $param += " -CAfile $ca"
  }

  Write-Verbose "param: $param"

  if ($cmd -notlike "*docker*") {
    cmd.exe /c "echo | $cmd $param"
  } else {
    $cmd = "echo | openssl $param"

    Write-Verbose "cmd: $cmd"

    Invoke-OpenSslContainer -EntryPoint "/bin/bash" -Command "-c '$cmd'" -Direct
  }

  if (Test-Path $ca) {
    Remove-Item $ca -Force
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

function Test-DeployedCertificateExpired {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [Alias("FQDN", "FullyQualifiedDomainName", "DomainName")]
    [string] $Domain,
    [Parameter(Position = 1)]
    [Int32] $Port = 443
  )

  $NotAfter = Get-DeployedCertificateExpiration -Domain $Domain -Port $port

  return ([Math]::Round(($NotAfter - (Get-Date)).TotalDays, 0) -le 0)
}

function Test-DeployedCertificateValidity {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [Alias("FQDN", "FullyQualifiedDomainName", "DomainName")]
    [string] $Domain,
    [Parameter(Position = 1)]
    [Int32] $Port = 443,
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [Alias("CA", "CAFile", "CABundle")]
    [string] $CAPath
  )

  $result = Get-DeployedCertificateValidity @PsBoundParameters

  return $result.Contains("Verification: OK")
}
