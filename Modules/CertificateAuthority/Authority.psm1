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

#--------------------------------------------------------------------------------------------------

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

  generateRequestConfig $script:cnf_ocsp $Country $Organization "$CommonName OCSP Responder"
  generateRequestConfig $script:cnf_timestamp $Country $Organization "$CommonName Timestamp"

  $cred = New-Object System.Management.Automation.PSCredential -ArgumentList "ni", $KeyPassword
  $passin = "-passin pass:$(($cred.GetNetworkCredential().Password).Trim())"

  Write-Output "`nGenerating the root certificate private key..."

  New-OpenSslEdwardsCurveKeypair -Path "./private/$Name.key" -Password $KeyPassword

  Remove-Item -Path "private/$Name.key.pub"

  Write-Output "Generating the root certificate request..."

  Invoke-OpenSsl "req -new -config $($script:cnf_ca) -out csr/ca.csr -key private/$Name.key $passin"

  Write-Output "`n`nGenerating the root certificate for this authority..."

  Invoke-OpenSsl "ca -selfsign -config $($script:cnf_ca) -in csr/ca.csr -out $Name.crt -extensions ca_ext $passin"

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

  if (-not (Test-OpenSslCertificateAuthority -Root)) {
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

  if (Test-Path $Name) {
    if ($Force) {
      Remove-Item -Path $Name -Recurse -Force
    } else {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "'$Name' folder exists and the Force parameter was not specified. Aborting creation." `
        -ExceptionType "System.InvalidOperationException" `
        -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
    }
  }

  Write-Output "`nCreating subordinate authority directories..."

  if ($Domain.Length -eq 0) {
    $Domain = Get-OpenSslCertificateAuthoritySetting Domain
  }

  if ($Country.Length -eq 0) {
    $Country = Get-OpenSslCertificateAuthoritySetting c
  }

  if ($Organization.Length -eq 0) {
    $Organization = Get-OpenSslCertificateAuthoritySetting org
  }

  if (-not (Test-Path $Name)) {
    New-Item -Path $Name -ItemType Directory | Out-Null
  }

  Push-Location $Name

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

  generateRequestConfig $script:cnf_ocsp $Country $Organization "$CommonName OCSP Responder"
  generateRequestConfig $script:cnf_timestamp $Country $Organization "$CommonName Timestamp"

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

  Invoke-OpenSsl "req -new -config $($script:cnf_ca) -out csr/ca.csr -key private/$Name.key $passin"

  Write-Output "Using Root CA to sign the certificate for this authority..."

  Pop-Location

  Invoke-OpenSsl "ca -config $($script:cnf_ca) -in $Name/csr/ca.csr -out $Name/$Name.crt -extensions sub_ca_ext"

  Push-Location $Name

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
  [Alias("remove-subca")]
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

function Revoke-OpenSslSubordinateAuthority {
  [CmdletBinding()]
  [Alias("revoke-subca")]
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