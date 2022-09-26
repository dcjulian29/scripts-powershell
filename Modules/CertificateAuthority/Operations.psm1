$script:cnf_ca = "ca.cnf"

#--------------------------------------------------------------------------------------------------

function cnf_san($id, $cn, $names) {
  $URI = @()
  $DNS = @()
  $IP = @()
  $EMail = @()

  if ($names -notcontains $cn) {
    $DNS += $cn
  }

  foreach ($name in $names) {
    if ($name -like "*://*") {
      $URI += $name
      continue
    }

    if ($name -like "*@*") {
      $EMail += $name
      continue
    }

    if (Test-IPAddress $name) {
      $IP += $name
      continue
    }

    $DNS += $name
  }

  $cnf = ".san.$id.cnf"
  $text = ".include $($script:cnf_ca)`n`n[san_list]`n`n"
  $items = @()

  for ($i = 0; $i -lt $URI.Count; $i++)   { $items += "URI.$i = $($URI[$i])" }
  for ($i = 0; $i -lt $DNS.Count; $i++)   { $items += "DNS.$i = $($DNS[$i])" }
  for ($i = 0; $i -lt $IP.Count; $i++)    { $items += "IP.$i = $($IP[$i])" }
  for ($i = 0; $i -lt $EMail.Count; $i++) { $items += "email.$i = $($EMail[$i])" }

  foreach ($item in $Items) { $text += "$item`n" }

  Set-Content -Path $cnf -Value "$text"

  return $cnf
}

#--------------------------------------------------------------------------------------------------

function signCertificate($path, $name, $pword, $extention, $days) {
  if (-not (Test-OpenSslCertificateAuthority $path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  if ($PsCmdlet.ParameterSetName -eq "path") {
    $name = Import-CertificateRequest $path
  }

  $cred = New-Object System.Management.Automation.PSCredential -ArgumentList "ni", $pword
  $passin = "-passin pass:$(($cred.GetNetworkCredential().Password).Trim())"

  $cmd = "ca -batch -config $($script:cnf_ca) -noout -notext" `
    + " -extensions $extension -days $days $passin -infiles csr/$name.csr"

  Invoke-OpenSsl $cmd

  return $Name
}

#--------------------------------------------------------------------------------------------------

function Approve-ServerCertificate {
  [CmdletBinding(DefaultParameterSetName = "path")]
  [Alias("sign-server-certificate")]
  param (
    [Parameter(ParameterSetName = "path", Mandatory = $true)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path,
    [Parameter(ParameterSetName = "name", Mandatory = $true)]
    [string] $Name,
    [Parameter(ParameterSetName = "path", Mandatory = $true)]
    [Parameter(ParameterSetName = "name", Mandatory = $true)]
    [securestring] $KeyPassword
  )

  if (-not (Test-OpenSslCertificateAuthority $Path -Subordinate)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "Certificates can only be signed by a subordinate authority that this module can manage." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  return signCertificate $Path $Name $KeyPassword "server_ext" 375
}

function Approve-SubordinateAuthority {
  [CmdletBinding(DefaultParameterSetName = "path")]
  [Alias("sign-subordinate-authority", "sign-subca")]
  param (
    [Parameter(ParameterSetName = "path", Mandatory = $true)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path,
    [Parameter(ParameterSetName = "name", Mandatory = $true)]
    [string] $Name,
    [Parameter(ParameterSetName = "path", Mandatory = $true)]
    [Parameter(ParameterSetName = "name", Mandatory = $true)]
    [securestring] $KeyPassword
  )

  if (-not (Test-OpenSslCertificateAuthority $Path -Root)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "Subordinate authorities can only be approved by a root authority." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  return signCertificate $Path $Name $KeyPassword "subca_ext" 1825
}

function Approve-UserCertificate {
  [CmdletBinding(DefaultParameterSetName = "path")]
  [Alias("sign-user-certificate")]
  param (
    [Parameter(ParameterSetName = "path", Mandatory = $true)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path,
    [Parameter(ParameterSetName = "name", Mandatory = $true)]
    [string] $Name,
    [Parameter(ParameterSetName = "path", Mandatory = $true)]
    [Parameter(ParameterSetName = "name", Mandatory = $true)]
    [securestring] $KeyPassword
  )

  if (-not (Test-OpenSslCertificateAuthority $Path -Subordinate)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "Certificates can only be signed by a subordinate authority that this module can manage." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  return signCertificate $Path $Name $KeyPassword "client_ext" 375
}

function Get-ImportedCertificateRequest {
  [CmdletBinding()]
  [Alias("list-imported-requests")]
  param (
    [Parameter(ValueFromPipeline = $true, Position = 0)]
    [string] $Name
  )

  if (-not (Test-OpenSslCertificateAuthority)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  if ($Name.Length -gt 0) {
    if (Test-Path "csr/$Name.csr") {
      return Get-CertificateRequest -Path "csr/$Name.csr"
    } else {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "A certificate request with named '$Name' does not exists in this authority." `
        -ExceptionType "System.Management.Automation.ItemNotFoundException" `
        -ErrorId "ItemNotFoundException" -ErrorCategory ObjectNotFound))
    }
  }

  $requests = @()
  $regex_version = "Version:\s(\d+)\s"
  $regex_subject = "Subject:\s(.+)"
  $regex_pub = "Public Key Algorithm:\s(\w+)"
  $regex_sig = "Signature Algorithm:\s(\w+)"
  $regex_valid = "self-signature verify OK"
  $files = (Get-ChildItem "csr/").Name

  foreach ($file in $files) {
    $content = Get-CertificateRequest -Path "csr/$file"

    $version = Select-String -InputObject $content -Pattern $regex_version
    $subject = Select-String -InputObject $content -Pattern $regex_subject
    $pub = Select-String -InputObject $content -Pattern $regex_pub
    $sig = Select-String -InputObject $content -Pattern $regex_sig
    $valid = Select-String -InputObject $content -Pattern $regex_valid

    if ($subject.Matches) {
      $subject = (($subject.Matches[0].Groups[1].Value) -split "\s\s+")[0]
      $subject = $subject -replace ' = ', '=' -replace ', ', ','
    } else {
      $subject = "**Unknown**"
    }

    $request = [PSCustomObject]@{
      Name = (Get-Item "csr/$file").BaseName
      Subject = $subject
      Version = $(if ($version.Matches) { $version.Matches[0].Groups[1].Value } else { 0 })
      PublicKey = $(if ($pub.Matches) { $pub.Matches[0].Groups[1].Value } else { "" })
      Signature = $(if ($sig.Matches) { $sig.Matches[0].Groups[1].Value } else { "" })
      Valid = $(if ($valid.Matches) { $true } else { $false })
    }

    $requests += $request
    $request = $null
  }

  return $requests
}

function Get-IssuedCertificate {
  [CmdletBinding(DefaultParameterSetName = "name")]
  [Alias("Get-RevokedIssuedCertificate", "list-issued-certificates", "list-revoked-certificates")]
  param (
    [Parameter(ParameterSetName = "name", ValueFromPipeline = $true, Position = 0)]
    [string] $Name,
    [Parameter(ParameterSetName = "revoked")]
    [switch] $Revoked
  )

  if (-not (Test-OpenSslCertificateAuthority)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  if ($Name.Length -gt 0) {
    if ($MyInvocation.InvocationName -like "*revoked*") {
      if (Test-Path "certs/$Name.pem.revoked") {
        return Get-Certificate -Path "certs/$Name.pem.revoked"
      } else {
        $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
          -Message "A revoked certificate with the name '$Name' does not exists in this authority." `
          -ExceptionType "System.Management.Automation.ItemNotFoundException" `
          -ErrorId "ItemNotFoundException" -ErrorCategory ObjectNotFound))
      }
    } else {
      if (Test-Path "certs/$Name.pem") {
        return Get-Certificate -Path "certs/$Name.pem"
      } else {
        $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
          -Message "A certificate with the name '$Name' does not exists in this authority." `
          -ExceptionType "System.Management.Automation.ItemNotFoundException" `
          -ErrorId "ItemNotFoundException" -ErrorCategory ObjectNotFound))
      }
    }
  }

  $certs = @()

  $content = Get-Content "db/index"
  $regex = "(\w)\s+(\w+)(\s+\w+,\w+\s+|\s+)(\w+)\s+(\w+)\s(.+)"

  foreach ($line in $content) {
    $result = Select-String -InputObject $line -Pattern $regex

    $cert = [PSCustomObject]@{
      SerialNumber      = ($result.Matches[0].Groups[4].Value | Out-String).Trim()
      DistinguishedName = ($result.Matches[0].Groups[6].Value | Out-String).Trim()
      Filename          = ($result.Matches[0].Groups[5].Value | Out-String).Trim()
      Status            = switch (($result.Matches[0].Groups[1].Value | Out-String).Trim()) {
        "V" { "Valid" }
        "E" { "Expired" }
        "R" { "Revoked" }
        Default { "Unknown" }
      }
      ExpirationDate    = `
        [datetime]::ParseExact(($result.Matches[0].Groups[2].Value `
          | Out-String).Trim(), "yyMMddHHmmssZ", $null)
      RevocationDate    = ($result.Matches[0].Groups[3].Value | Out-String).Trim()
      RevocationReason  = $null
    }

    if ($cert.RevocationDate.Length -gt 0) {
      $cert.RevocationReason = ($cert.RevocationDate -split ',')[1]
      $cert.RevocationDate = `
        [datetime]::ParseExact(($cert.RevocationDate -split ',')[0], "yyMMddHHmmssZ", $null)
    }

    $certs += $cert
    $result = $null
  }

  if (($PsCmdlet.ParameterSetName -eq "revoked") -or ($MyInvocation.InvocationName -like "*revoked*")) {
    $certs =  $certs | Where-Object { $_.Status -eq "Revoked" }
  }

  return $certs
}

function Get-IssuedCertificateValidity {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [Alias("Certificate", "Cert")]
    [string] $Name,
    [Parameter(Position = 1)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [Alias("CA", "CAFile", "CABundle")]
    [string] $CAPath
  )

  if (-not (Test-OpenSslCertificateAuthority)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  if (Test-Path "certs/$Name.pem") {
    $param = "verify"
    $ca = "./.openssl.$((New-Guid).Guid).cacert.pem"

    if ($CAPath) {
      Copy-Item -Path $CAPath -Destination $ca
    } else {
      $authority = Get-OpenSslCertificateAuthoritySetting Name

      if (Test-Path "./$authority.crt") {
        $ca = "$authority.crt"
      } else {
        Invoke-WebRequest "https://curl.se/ca/cacert.pem" -OutFile $ca
      }
    }

    if (Test-Path $ca) {
      $param += " -CAfile $ca"
    }

    $param += " certs/$Name.pem"

    Write-Verbose "param: $param"

    Invoke-OpenSsl $param
  } else {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "A certificate with the name '$Name' does not exists in this authority." `
      -ExceptionType "System.Management.Automation.ItemNotFoundException" `
      -ErrorId "ItemNotFoundException" -ErrorCategory ObjectNotFound ))
  }
}

function Import-CertificateRequest {
  [CmdletBinding()]
  [Alias("import-csr")]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path
  )

  if (-not (Test-OpenSslCertificateAuthority $Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  if (-not (Test-Path csr)) {
    New-Item -Path csr -ItemType Directory | Out-Null
  }

  $id = Get-OpenSslRandom 16 -Hex

  Copy-Item -Path $Path -Destination "csr/$id.csr"

  return $id
}

function Revoke-Certificate {
  [CmdletBinding()]
  [Alias("revoke-certificate","revoke-issued-certificate")]
  param (
    [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [Alias("Certificate", "Cert")]
    [string] $Name,
    [ValidateSet("unspecified", "keyCompromise", "CACompromise", "affiliationChanged", "superseded", "cessationOfOperation", "certificateHold", "removeFromCRL")]
    [string] $Reason = "unspecified"
  )

  if (-not (Test-OpenSslCertificateAuthority)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  if (Test-Path "certs/$Name.pem") {
    $param = "revoke -config $($script:cnf_ca) -revoke certs/$Name.pem -crl_reason $Reason"

    Write-Verbose "param: $param"

    Invoke-OpenSsl $param
    Move-Item -Path "certs/$Name.pem" "certs/$Name.pem.revoked"
  } else {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "A certificate with the name '$Name' does not exists in this authority." `
      -ExceptionType "System.Management.Automation.ItemNotFoundException" `
      -ErrorId "ItemNotFoundException" -ErrorCategory ObjectNotFound ))
  }
}

function Test-IssuedCertificateValidity {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [Alias("Certificate", "Cert")]
    [string] $Name,
    [Parameter(Position = 1)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [Alias("CA", "CAFile", "CABundle")]
    [string] $CAPath
  )

  $result = Get-IssuedCertificateValidity @PsBoundParameters

  return $result.Contains("Verification: OK")
}

function Update-CerticateAuthorityDatabase {
  [Alias("update-ca", "ca-update")]
  param (
    [Parameter(Position = 0)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path)
  )

  if (-not (Test-OpenSslCertificateAuthority $Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  Push-Location $Path

  Invoke-OpenSsl "ca -config $($script:cnf_ca) -gencrl -out $Name.crl"

  Pop-Location
}

function Update-CerticateAuthorityRevocationList {
  [Alias("update-crl", "crl-update")]
  param (
    [Parameter(Position = 0)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path)
  )

  if (-not (Test-OpenSslCertificateAuthority $Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  Push-Location $Path

  $Name = Get-OpenSslCertificateAuthoritySetting Name
  Invoke-OpenSsl "ca -config $($script:cnf_ca) -gencrl -out $Name.crl"

  if (Test-Path "$Name.crl") {
    Invoke-OpenSsl "crl -in $Name.crl -noout -text"
  }

  Pop-Location
}

function Update-OcspCerticate {
  [Alias("update-ocsp", "ocsp-update")]
  param (
    [Parameter(Position = 0)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path)
  )

  if (-not (Test-OpenSslCertificateAuthority $Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  Push-Location $Path

  Invoke-OpenSsl `
    "ca -batch -config $($script:cnf_ca) -out ocsp.crt -extensions ocsp_ext -days 30 -infiles csr/ocsp.csr"

  Pop-Location
}
