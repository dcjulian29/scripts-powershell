$script:cnf_ca = "ca.cnf"
$script:cnf_crl_info = @"
[crl_info]
URI.0                   = `$crl_url
"@
$script:cnf_default = @"
aia_url                 = http://`$name.`$domain_suffix/`$name.crt
crl_url                 = http://`$name.`$domain_suffix/`$name.crl
ocsp_url                = http://ocsp-`$name.`$domain_suffix
default_ca              = ca_default
name_opt                = utf8,esc_ctrl,multiline,lname,align
"@
$script:cnf_default_ca = @"
[ca_default]
home                    = .
database                = `$home/db/index
serial                  = `$home/db/serial
crlnumber               = `$home/db/crlnumber
certificate             = `$home/`$name.crt
private_key             = `$home/private/`$name.key
RANDFILE                = `$home/private/random
new_certs_dir           = `$home/certs
unique_subject          = no
default_md              = sha256
"@
$script:cnf_issuer_info = @"
[issuer_info]
caIssuers;URI.0         = `$aia_url
OCSP;URI.0              = `$ocsp_url
"@
$script:cnf_name_constraints = @"
[name_constraints]
permitted;DNS.0=`$domain_suffix
excluded;IP.0=0.0.0.0/0.0.0.0
excluded;IP.1=0:0:0:0:0:0:0:0/0:0:0:0:0:0:0:0
"@
$script:cnf_ocsp = "ocsp.cnf"
$script:cnf_ocsp_info = @"
[ocsp_info]
caIssuers;URI.0         = $aia_url
OCSP;URI.0              = $ocsp_url
"@
$script:cnf_timestamp = "timestamp.cnf"

#--------------------------------------------------------------------------------------------------

function cnf_policy($policy="policy_c_o_match") {
  return @"
policy                  = $policy

[policy_c_o_match]
countryName             = match
stateOrProvinceName     = optional
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[policy_o_match]
countryName             = optional
stateOrProvinceName     = optional
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
"@
}

function ext_ca {
  return @"
[ca_ext]
basicConstraints        = critical,CA:true
keyUsage                = critical,keyCertSign,cRLSign
subjectKeyIdentifier    = hash
"@
}

function ext_client($Public) {
  return @"
[client_ext]
authorityInfoAccess     = @issuer_info
#authorityInfoAccess     = @ocsp_info
authorityKeyIdentifier  = keyid:always, issuer:always
basicConstraints        = critical,CA:false
crlDistributionPoints   = @crl_info
extendedKeyUsage        = clientAuth,codeSigning,emailProtection
keyUsage                = critical,digitalSignature
$(if (-not ($Public)) { "nameConstraints         = @name_constraints" })
subjectAltName          = email:move
subjectKeyIdentifier    = hash
"@
}

function ext_ocsp {
  return @"
[ocsp_ext]
authorityInfoAccess     = @issuer_info
authorityKeyIdentifier  = keyid:always
basicConstraints        = critical,CA:false
extendedKeyUsage        = critical,OCSPSigning
keyUsage                = critical,digitalSignature
subjectKeyIdentifier    = hash
"@
}

function ext_server($Public) {
  return @"
[server_ext]
authorityInfoAccess     = @issuer_info
#authorityInfoAccess     = @ocsp_info
authorityKeyIdentifier  = keyid:always, issuer:always
basicConstraints        = critical,CA:false
crlDistributionPoints   = @crl_info
extendedKeyUsage        = clientAuth,serverAuth
keyUsage                = critical,digitalSignature,keyEncipherment
$(if (-not ($Public)) { "nameConstraints         = @name_constraints" })
subjectKeyIdentifier    = hash
"@
}

function ext_subca($Public) {
 return @"
[sub_ca_ext]
authorityInfoAccess     = @issuer_info
authorityKeyIdentifier  = keyid:always
basicConstraints        = critical,CA:true,pathlen:0
crlDistributionPoints   = @crl_info
extendedKeyUsage        = clientAuth,serverAuth
keyUsage                = critical,keyCertSign,cRLSign
subjectKeyIdentifier    = hash
$(if (-not ($Public)) { "nameConstraints         = @name_constraints" })
"@
}

function ext_timestamp {
  return @"
authorityInfoAccess     = @issuer_info
authorityKeyIdentifier  = keyid:always
basicConstraints        = CA:false
crlDistributionPoints   = @crl_info
extendedKeyUsage        = critical,timeStamping
keyUsage                = critical,digitalSignature
subjectKeyIdentifier    = hash
"@
}

function generateRequestConfig($Path,$Country,$Organization,$CommonName) {
  Set-Content -Path $Path -Value @"
[req]
default_bits            = 2048
encrypt_key             = no
default_md              = sha256
utf8                    = yes
string_mask             = utf8only
prompt                  = no
distinguished_name      = req_subj

[req_subj]
countryName             = $Country
organizationName        = $Organization
commonName              = $CommonName
"@
}

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

Set-Alias -Name "sign-server-certificate" -Value Approve-ServerCertificate

function Approve-SubordinateAuthority {
  [CmdletBinding(DefaultParameterSetName = "path")]
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

Set-Alias -Name "sign-subordinate-authority" -Value Approve-SubordinateAuthority
Set-Alias -Name "sign-subca" -Value Approve-SubordinateAuthority

function Approve-UserCertificate {
  [CmdletBinding(DefaultParameterSetName = "path")]
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

Set-Alias -Name "sign-user-certificate" -Value Approve-ServerCertificate

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
  [Alias("Get-RevokedIssuedCertificate")]
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

Set-Alias -Name "list-issued-certificates" -Value Get-IssuedCertificate
Set-Alias -Name "list-revoked-certificates" -Value Get-RevokedIssuedCertificate

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

function Get-OpenSslCertificateAuthoritySetting {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0)]
    [string] $Name = "*",
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path)
  )

  if (-not (Test-OpenSslCertificateAuthority $Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  if ($Name -eq '*') {
    $content = Get-Content "$($Path)/.openssl_ca"
    $results = @()

    foreach ($line in $content) {
      $result = $line | Select-String "\.(.*)=(.*)$"

      if ($result.Matches.Count -eq 1) {
        $results += [PSCustomObject]@{
          Name = ($result.Matches[0].Groups[1].Value | Out-String).Trim()
          Value = ($result.Matches[0].Groups[2].Value | Out-String).Trim()
        }
      }
    }

    return $results
  }

  $result = (Get-Content "$($Path)/.openssl_ca" | Select-String "\.$Name=(.*)$" -AllMatches)
  $results = @()

  if ($result.Matches.Count -gt 0) {
    for ($i = 0; $i -lt $result.Matches.Count; $i++) {
      $results += ($result.Matches[$i].Groups[1].Value | Out-String).Trim()
    }

    return $results
  } else {
    return $null
  }
}

function Import-CertificateRequest {
  [CmdletBinding()]
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

Set-Alias -Name "import-csr" -Value Import-CertificateRequest

function New-OpenSslCertificateAuthority {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path),
    [string] $Name = "root",
    [string] $Domain = "pki.contoso.local",
    [Parameter(Mandatory = $true)]
    [securestring] $KeyPassword,
    [string] $Country = "US",
    [string] $Organization = "OpenSSL Root Certificate Authority",
    [string] $CommonName = "RootCA",
    [switch] $Public
  )

  if (Test-OpenSslCertificateAuthority $Path) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "'$Path' is already an OpenSSL Certificate Authority." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  $origialErrorActionPreference = $ErrorActionPreference
  $ErrorActionPreference = "Stop"

  Write-Output "`nCreating certificate authority directories..."

  if (-not (Test-Path $Path)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
  }

  Push-Location $Path

  @("certs", "csr", "db", "private") | ForEach-Object {
    New-Item -Path $_ -ItemType Directory | Out-Null
  }

  Write-Output "Initalizing certificate authority..."

  New-Item -Path "db/index" -ItemType File | Out-Null
  New-Item -Path "db/serial" -ItemType File `
    -Value $(Get-OpenSslRandom 15 -Hex)  | Out-Null
  New-Item -Path "db/crlnumber" -Value "1001" | Out-Null

  Set-Content -Path "$($script:cnf_ca)" -Value @"
[default]
name                    = $Name
domain_suffix           = $Domain
$($script:cnf_default)

[ca_dn]
countryName             = "$Country"
organizationName        = "$Organization"
commonName              = "$CommonName"

$($script:cnf_default_ca)
copy_extensions         = none
default_days            = 1825
default_crl_days        = 365
$(if (-not ($Public)) { cnf_policy })

$($script:cnf_crl_info)

$($script:cnf_issuer_info)

$(if (-not ($Public)) { $script:cnf_name_constraints })

[req]
encrypt_key             = yes
default_md              = sha256
utf8                    = yes
string_mask             = utf8only
prompt                  = no
distinguished_name      = ca_dn
req_extensions          = ca_ext

$(ext_ca)

$(ext_ocsp)

$(ext_subca($Public))
"@

  generateRequestConfig $script:cnf_ocsp, $Country, $Organization, "$CommonName OCSP Responder"
  generateRequestConfig $script:cnf_timestamp, $Country, $Organization, "$CommonName Timestamp"

  $cred = New-Object System.Management.Automation.PSCredential -ArgumentList "ni", $KeyPassword
  $passin = "-passin pass:$(($cred.GetNetworkCredential().Password).Trim())"

  Write-Output "`nGenerating the root certificate private key..."

  New-OpenSslEdwardsCurveKeypair -Path "./private/$Name.key" -Password $KeyPassword

  Remove-Item -Path "private/$Name.key.pub"

  Write-Output "Generating the root certificate request..."

  Invoke-OpenSsl "req -new -config $($script:cnf_ca) -out csr/$Name.csr -key private/$Name.key $passin"

  Write-Output "`n`nGenerating the root certificate for this authority..."

  Invoke-OpenSsl "ca -selfsign -config $($script:cnf_ca) -in csr/$Name.csr -out $Name.crt -extensions ca_ext $passin"

  Write-Output "`n`nGenerating the OCSP private key for this authority...`n"

  New-OpenSslRsaKeypair -Path "private/ocsp.key" -BitSize 2048

  Remove-Item -Path "private/ocsp.key.pub"

  Write-Output "`nGenerating the OCSP certificate request..."

  Invoke-OpenSsl "req -new -config ocsp.cnf -out csr/ocsp.csr -key private/ocsp.key"

  Write-Output "`nGenerating the OCSP Certificate for this authority..."

  Invoke-OpenSsl `
    "ca -batch -config $($script:cnf_ca) -out ocsp.crt -extensions ocsp_ext -days 30 $passin -infiles csr/ocsp.csr"

  Set-Content -Path ".openssl_ca" -Encoding UTF8 -Value @"
.type=root
.public=$Public
.name=$Name
.domain=$Domain
.c=$Country
.org=$Organization
.cn=$CommonName
"@

  Write-Output "`n`nCreation of a root certificate authority complete...`n"

  Get-Certificate -Path "$Name.crt"

  Pop-Location

  $ErrorActionPreference = $origialErrorActionPreference

  Write-Output "`n~~~~~~`n"
  Write-Output "A root certificate authority should only have subordinate authorities"
  Write-Output "so create at least one subordinate certificate authority to sign"
  Write-Output "certificates within this authority...`n"
}

function New-OpenSslSubordinateAuthority {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0)]
    [string] $Name = "intermediate",
    [string] $Domain,
    [Parameter(Mandatory = $true)]
    [securestring] $KeyPassword,
    [ValidateSet("Edwards", "Eliptic", "RSA")]
    [string] $KeyEncryption = "RSA",
    [string] $Country,
    [string] $Organization,
    [string] $CommonName = "SubCA",
    [switch] $Public,
    [switch] $Force
  )

  $Path = $PWD.Path

  if (-not (Test-OpenSslCertificateAuthority $Path -Root)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "'$Path' is not a root OpenSSL Certificate Authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  $origialErrorActionPreference = $ErrorActionPreference
  $ErrorActionPreference = "Stop"

  # if ((Get-OpenSslCertificateAuthoritySetting SubCA) -contains $Name) {
  #   if (-not $Force) {
  #   <# Settings say subca is issued and not revoke. must removed before it can be overwritten anf force wasn't provided. #>
  #   } else {
  #     Remove-OpenSslSubordinateAuthority $Name
  #   }
  # }

  if ((Test-Path "$Path/$Name")) {
    if ($Force) {
      Remove-Item -Path "$Path/$Name" -Recurse -Force
    } else {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "'$Name' folder exists and the Force parameter was not specified. Aborting creation." `
        -ExceptionType "System.InvalidOperationException" `
        -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
    }
  }

  Write-Output "`nCreating subordinate authority directories..."

  Push-Location $Path

  if ($Domain.Length -eq 0) {
    $Domain = Get-OpenSslCertificateAuthoritySetting Domain
  }

  if ($Country.Length -eq 0) {
    $Country = Get-OpenSslCertificateAuthoritySetting c
  }

  if ($Organization.Length -eq 0) {
    $Organization = Get-OpenSslCertificateAuthoritySetting org
  }

  if (-not (Test-Path "$Path/$Name")) {
    New-Item -Path "$Path/$Name" -ItemType Directory | Out-Null
  }

  Push-Location "$Path/$Name"

  @("certs", "csr", "db", "private") | ForEach-Object {
    New-Item -Path $_ -ItemType Directory | Out-Null
  }

  Write-Output "Initalizing subordinate authority..."

  New-Item -Path "db/index" -ItemType File | Out-Null
  New-Item -Path "db/serial" -ItemType File `
    -Value $(Get-OpenSslRandom 15 -Hex)  | Out-Null
  New-Item -Path "db/crlnumber" -Value "1001" | Out-Null

  Set-Content -Path "$($script:cnf_ca)" -Value @"
[default]
name                    = $Name
domain_suffix           = $Domain
$($script:cnf_default)

[ca_dn]
countryName             = "$Country"
organizationName        = "$Organization"
commonName              = "$CommonName"

$($script:cnf_default_ca)
copy_extensions         = copy
default_days            = 365
default_crl_days        = 30
$(if (-not ($Public)) { cnf_policy })

$($script:cnf_crl_info)

$($script:cnf_issuer_info)

$(if (-not ($Public)) { $script:cnf_name_constraints })

[req]
encrypt_key             = yes
default_md              = sha256
utf8                    = yes
string_mask             = utf8only
prompt                  = no
distinguished_name      = ca_dn
req_extensions          = ca_ext

$(ext_ca)

$(ext_ocsp)

$(ext_server $Public)

$(ext_client $Public)
"@

  generateRequestConfig $script:cnf_ocsp, $Country, $Organization, "$CommonName OCSP Responder"
  generateRequestConfig $script:cnf_timestamp, $Country, $Organization, "$CommonName Timestamp"

  $cred = New-Object System.Management.Automation.PSCredential -ArgumentList "ni", $KeyPassword
  $passin = "-passin pass:$(($cred.GetNetworkCredential().Password).Trim())"

  Write-Output "`nGenerating the subordinate certificate private key..."

  switch ($KeyEncryption) {
    "Edwards" {
      New-OpenSslEdwardsCurveKeypair -Path "./private/$Name.key" -Password $KeyPassword
    }
    "Eliptic" {
      New-OpenSslElipticCurveKeypair -Path "./private/$Name.key" -Password $KeyPassword
    }
    "RSA" {
      New-OpenSslRsaKeypair -Path "./private/$Name.key" -Password $KeyPassword
    }
  }

  Remove-Item -Path "private/$Name.key.pub"

  Write-Output "`nGenerating the subordinate certificate request..."

  Invoke-OpenSsl "req -new -config $($script:cnf_ca) -out csr/$Name.csr -key private/$Name.key $passin"

  Write-Output "Using Root CA to sign the certificate for this authority..."

  Pop-Location

  Invoke-OpenSsl "ca -config $($script:cnf_ca) -in csr/$Name.csr -out $Name/$Name.crt -extensions sub_ca_ext"

  Push-Location -Path $Name

  Write-Output "`n`nGenerating the OCSP private key for this authority...`n"

  New-OpenSslRsaKeypair -Path "private/ocsp.key" -BitSize 2048

  Remove-Item -Path "private/ocsp.key.pub"

  Write-Output "`nGenerating the OCSP certificate request..."

  Invoke-OpenSsl "req -new -config ocsp.cnf -out csr/ocsp.csr -key private/ocsp.key"

  Write-Output "`nGenerating the OCSP Certificate for this authority..."

  Invoke-OpenSsl `
    "ca -batch -config $($script:cnf_ca) -out ocsp.crt -extensions ocsp_ext -days 30 $passin -infiles csr/ocsp.csr"

  Set-Content -Path ".openssl_ca" -Encoding UTF8 -Value @"
.type=subordinate
.public=$Public
.name=$Name
.domain=$Domain
.c=$Country
.org=$Organization
.cn=$CommonName
"@

  Write-Output "`n`nCreation of a subordinate authority complete...`n"

  Get-Certificate -Path "$Name.crt"

  $sn = Get-CertificateSerialNumber -Path "$Name.crt"

  Pop-Location

  $subca = (Get-OpenSslCertificateAuthoritySetting subca | Where-Object { $_ -like $Name })

  if ($subca.Count -gt 0) {
    Set-OpenSslCertificateAuthoritySetting -Name "subca" -Value $Name -Remove
    Set-OpenSslCertificateAuthoritySetting -Name "subca_$Name" -Remove
  }

  Set-OpenSslCertificateAuthoritySetting -Name "subca" -Value "$Name"
  Set-OpenSslCertificateAuthoritySetting -Name "subca_$Name" -Value $sn

  Pop-Location

  $ErrorActionPreference = $origialErrorActionPreference

  Write-Output "`n~~~~~~`n"
  Write-Output "This subordinate certificate authority can only be used to sign"
  Write-Output "certificates within this authority...`n"
}

function Remove-OpenSslSubordinateAuthority {
  [CmdletBinding()]
  param (
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path),
    [string] $Name = $(Split-Path -Path $Path -Leaf)
  )

  if (-not (Test-OpenSslCertificateAuthority $Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  if (Test-OpenSslCertificateAuthority $Path -Subordinate) {
    Push-Location -Path "$((Get-Item -Path $Path).Parent.FullName)"
  } else {
    Push-Location $Path
  }

  if (-not (Test-OpenSslCertificateAuthority -Root)) {
    Pop-Location
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "'$Path' is not part of a certificate authority that includes the root authority." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  $subca = (Get-OpenSslCertificateAuthoritySetting subca | Where-Object { $_ -like $Name })

  if ($subca.Length -gt 0) {
    $sn = Get-OpenSslCertificateAuthoritySetting "subca_$Name"

    if ($sn -eq "~REVOKED~") {
      Set-OpenSslCertificateAuthoritySetting -Name "subca" -Value $Name -Remove
      Set-OpenSslCertificateAuthoritySetting -Name "subca_$Name" -Remove

      if (Test-Path "$Name/") {
        Remove-Item -Path $Name -Recurse -Force
      }
    } else {
      Pop-Location
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "'$Name' authority must be revoked before it can be removed." `
        -ExceptionType "System.InvalidOperationException" `
        -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
    }
  } else {
    Pop-Location
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "'$Name' authority is not currently managed by this root authority." `
      -ExceptionType "System.InvalidOperationException" `
      -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  Pop-Location
}

Set-Alias -Name "remove-subca" -Value Remove-OpenSslSubordinateAuthority

function Revoke-Certificate {
  [CmdletBinding()]
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

Set-Alias -Name "revoke-certificate" -Value Revoke-Certificate
Set-Alias -Name "revoke-issued-certificate" -Value Revoke-Certificate

function Revoke-OpenSslSubordinateAuthority {
  [CmdletBinding()]
  param (
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path),
    [string] $Name = $(Split-Path -Path $Path -Leaf),
    [ValidateSet("unspecified", "keyCompromise", "CACompromise", "affiliationChanged", "superseded", "cessationOfOperation", "certificateHold", "removeFromCRL")]
    [string] $Reason = "unspecified"
  )

  if (-not (Test-OpenSslCertificateAuthority $Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  if (Test-OpenSslCertificateAuthority $Path -Subordinate) {
    Push-Location -Path "$((Get-Item -Path $Path).Parent.FullName)"
  } else {
    Push-Location $Path
  }

  if (-not (Test-OpenSslCertificateAuthority -Root)) {
    Pop-Location
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "'$Path' is not part of a certificate authority that includes the root authority." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  $subca = (Get-OpenSslCertificateAuthoritySetting subca | Where-Object { $_ -like $Name })

  if ($subca.Length -gt 0) {
    $sn = Get-OpenSslCertificateAuthoritySetting "subca_$Name"

    if ($sn -eq "~REVOKED~") {
      Pop-Location
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "'$Name' authority has already been revoked." `
        -ExceptionType "System.InvalidOperationException" `
        -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
    }

    if ($sn.Length -gt 0) {
      Invoke-OpenSsl "ca -config $($script:cnf_ca) -revoke certs/$sn.pem -crl_reason $Reason"

      Move-Item -Path "certs/$sn.pem" "certs/$sn.pem.revoked"

      Set-OpenSslCertificateAuthoritySetting -Name "subca_$Name" -Value "~REVOKED~"

      if (Test-Path "$Name/") {
        ###TODO: If subordinate authority is mounted (directly below root), cycle through each issued certificate and revoke them as well
      }
    }
  } else {
    Pop-Location
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "'$Name' authority is not currently managed by this root authority." `
      -ExceptionType "System.InvalidOperationException" `
      -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  Pop-Location
}

Set-Alias -Name "revoke-subca" -Value Revoke-OpenSslSubordinateAuthority

function Start-OpenSslOcspServer {
  param (
    [Parameter(Position = 0)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path),
    [String] $Port = 8080
  )

  if (-not (Test-OpenSslCertificateAuthority $Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  Push-Location $Path

  $Name = Get-OpenSslCertificateAuthoritySetting Name

  $params = @{
    Command = "ocsp -port $Port -index db/index -rsigner ocsp.crt -rkey private/ocsp.key -CA $Name.crt -text"
    Interactive = $false
    Name = "ocsp_$Name"
    Port = @(
      "${Port}:$Port/tcp"
    )
  }

  if (-not (Get-DockerContainerNames -Running | Where-Object { $_.Name -eq $params.Name })) {
    Invoke-OpenSslContainer @params
    Pop-Location
  } else {
    Pop-Location
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "An OCSP server is already running for this certificate authority." `
      -ExceptionType "System.InvalidOperationException" `
      -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }
}

function Stop-OpenSslOcspServer {
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
  $name = "ocsp_$(Get-OpenSslCertificateAuthoritySetting Name)"
  Pop-Location

  if (Get-DockerContainerNames -Running | Where-Object { $_.Name -eq $name }) {
    Get-DockerContainer -Running | Where-Object { $_.Name -eq $name } | Remove-DockerContainer
  } else {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "An OCSP server is not running for this certificate authority." `
      -ExceptionType "System.InvalidOperationException" `
      -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }
}

function Set-OpenSslCertificateAuthoritySetting {
  [CmdletBinding(DefaultParameterSetName = "add")]
  param (
    [Parameter(ParameterSetName = "add", Mandatory = $true, Position = 0)]
    [Parameter(ParameterSetName = "remove", Mandatory = $true, Position = 0)]
    [string] $Name,
    [Parameter(ParameterSetName = "add", Mandatory = $true, Position = 1)]
    [Parameter(ParameterSetName = "remove", Position = 1)]
    [string] $Value,
    [Parameter(ParameterSetName = "add")]
    [Parameter(ParameterSetName = "remove")]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path),
    [Parameter(ParameterSetName = "add")]
    [switch] $Append,
    [Parameter(ParameterSetName = "remove", Mandatory = $true)]
    [switch] $Remove
  )

  if (-not (Test-OpenSslCertificateAuthority $Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  $config = "$($Path)/.openssl_ca"

  if ($null -ne (Get-OpenSslCertificateAuthoritySetting $Name)) {
    if (-not $Append) {
      if ($Value.Length -gt 0) {
        $content = Get-Content $config | Where-Object { $_ -notlike ".$Name=$Value" }
      } else {
        $content = Get-Content $config | Where-Object { $_ -notlike "*$Name*" }
      }

      Set-Content -Path $config -Value  $content -Force
    }
  }

  if ($PsCmdlet.ParameterSetName -eq "add") {
    Add-Content -Path $config -Value ".$Name=$Value".Trim()
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

function Test-OpenSslCertificateAuthority {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path),
    [switch] $Root,
    [switch] $Subordinate
  )

  $result = Test-Path "$Path/.openssl_ca"

  if ($result) {
    if ($root) {
      return (Get-Content .openssl_ca | Select-String ".type=root").Matches.Count -gt 0
    }

    if ($Subordinate) {
      return (Get-Content .openssl_ca | Select-String ".type=subordinate").Matches.Count -gt 0
    }
  }

  return $result
}

function Update-CerticateAuthorityDatabase {
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

Set-Alias -Name update-ca -Value Update-CerticateAuthorityDatabase

function Update-CerticateAuthorityRevocationList {
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

Set-Alias -Name update-crl -Value Update-CerticateAuthorityRevocationList

function Update-OcspCerticate {
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

Set-Alias -Name update-ocsp -Value Update-OcspCerticate
