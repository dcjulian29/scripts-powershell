function Get-ImportedCertificateRequest {
  [CmdletBinding()]
  [Alias("list-imported-requests")]
  param (
    [Parameter(ValueFromPipeline = $true, Position = 0)]
    [string] $Name
  )

  if (-not (Test-CertificateAuthority)) {
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

  if (-not (Test-CertificateAuthority)) {
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

  if (-not (Test-CertificateAuthority)) {
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
      $authority = Get-CertificateAuthoritySetting Name

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

function New-ServerCertificate {
  [CmdletBinding()]
  [Alias("new-server-certificate")]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string] $Name,
    [ValidateSet("Edwards", "Eliptic", "RSA")]
    [string] $KeyEncryption = "RSA",
    [securestring] $KeyPassword,
    [string] $Country,
    [Alias("Province", "Region")]
    [string] $State,
    [Alias("City")]
    [string] $Locality,
    [Alias("Company")]
    [string] $Organization,
    [Alias("Section")]
    [string] $OrganizationUnit,
    [string[]] $AdditionalNames,
    [Parameter(Mandatory = $true)]
    [securestring] $AuthorityPassword
  )

  if (-not (Test-CertificateAuthority -Subordinate)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "Certificates can only be requested in a subordinate authority that this module can manage." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  $id = New-ServerCertificateRequest ($PSBoundParameters | Where-Object { $_.Key -ne "AuthorityPassword" })

  Approve-ServerCertificate -Name $id -KeyPassword $AuthorityPassword
}

function New-UserCertificate {
  [CmdletBinding()]
  [Alias("new-user-certificate")]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string] $Name,
    [string] $Domain,
    [ValidateSet("Edwards", "Eliptic", "RSA")]
    [string] $KeyEncryption = "RSA",
    [securestring] $KeyPassword,
    [string] $Country,
    [Alias("Province", "Region")]
    [string] $State,
    [Alias("City")]
    [string] $Locality,
    [Alias("Company")]
    [string] $Organization,
    [Alias("Section")]
    [string] $OrganizationUnit,
    [Parameter(Mandatory = $true)]
    [securestring] $AuthorityPassword
  )

  if (-not (Test-CertificateAuthority -Subordinate)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "Certificates can only be requested in a subordinate authority that this module can manage." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  $param = @{}
  $PSBoundParameters.GetEnumerator() | ForEach-Object {
    if ($_.Key -ne "AuthorityPassword") {
      $param.Add($_.Key, $_.Value)
    }
  }

  $id = New-UserCertificateRequest @param

  Approve-UserCertificate -Name $id -KeyPassword $AuthorityPassword
}

function Revoke-Certificate {
  [CmdletBinding()]
  [Alias("revoke-issued-certificate")]
  param (
    [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [Alias("Certificate", "Cert")]
    [string] $Name,
    [securestring] $AuthorityPassword,
    [ValidateSet("unspecified", "keyCompromise", "CACompromise", "affiliationChanged", "superseded", "cessationOfOperation", "certificateHold", "removeFromCRL")]
    [string] $Reason = "unspecified"
  )

  if (-not (Test-CertificateAuthority)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  if (Test-Path "certs/$Name.pem") {
    if ($AuthorityPassword) {
      $cred = New-Object System.Management.Automation.PSCredential -ArgumentList "ni", $AuthorityPassword
      $passin = "-passin pass:$(($cred.GetNetworkCredential().Password).Trim())"
    } else {
      $passin = ""
    }

    $param = "ca -config $($script:cnf_ca) -revoke certs/$Name.pem -crl_reason $Reason $passin"

    Write-Verbose "param: $param"

    Invoke-OpenSsl $param

    if ((Get-IssuedCertificate | Where-Object { $_.SerialNumber -eq $name }).Status -eq 'Revoked') {
      Move-Item -Path "certs/$Name.pem" "certs/$Name.pem.revoked"
    }
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
