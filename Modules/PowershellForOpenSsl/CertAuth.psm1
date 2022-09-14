function Get-OpenSslCertificateAuthoritySetting {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $Name
  )

  if (-not (Test-OpenSslCertificateAuthority $PWD.Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  if ($Name -eq '*') {
    $content = Get-Content "$($PWD.Path)/.openssl_ca"
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

  $result = (Get-Content "$($PWD.Path)/.openssl_ca" | Select-String "\.$Name=(.*)$")

  if ($result.Matches.Count -gt 0) {
    return ($result.Matches[0].Groups[1].Value | Out-String).Trim()
  }

  return $null
}

function New-OpenSslCertificateAuthority {
  [CmdletBinding()]
  param (
    [Parameter(Position = 0)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path),
    [string] $Name = "rootca",
    [string] $Domain = "contoso.local",
    [Parameter(Mandatory = $true)]
    [securestring] $RootKeyPassword,
    [string] $Country = "US",
    [string] $Organization = "OpenSSL Root Certificate Authority",
    [string] $CommonName = "Root CA",
    [string] $SubordinateName = "intermediate",
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

  @("certs", "db", "private") | ForEach-Object {
    New-Item -Path $_ -ItemType Directory | Out-Null
  }

  Write-Output "Initalizing certificate authority..."

  New-Item -Path "db/index" -ItemType File | Out-Null
  New-Item -Path "db/serial" -ItemType File `
    -Value $(Get-OpenSslRandom 15 -Hex)  | Out-Null
  New-Item -Path "db/crlnumber" -Value "1001" | Out-Null

  $policy = @"
policy                  = policy_c_o_match

[policy_c_o_match]
countryName             = match
stateOrProvinceName     = optional
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
"@

  Set-Content -Path "openssl.cnf" -Value @"
[default]
name                    = $Name
domain_suffix           = $Domain
aia_url                 = http://`$name.`$domain_suffix/`$name.crt
crl_url                 = http://`$name.`$domain_suffix/`$name.crl
ocsp_url                = http://ocsp.`$name.`$domain_suffix:9080
default_ca              = ca_default
name_opt                = utf8,esc_ctrl,multiline,lname,align

[ca_dn]
countryName             = "$Country"
organizationName        = "$Organization"
commonName              = "$CommonName"

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
copy_extensions         = none
default_days            = 3650
default_crl_days        = 365
default_md              = sha256
$(if (-not ($Public)) { $policy})

[req]
default_bits            = 4096
encrypt_key             = yes
default_md              = sha256
utf8                    = yes
string_mask             = utf8only
prompt                  = no
distinguished_name      = ca_dn
req_extensions          = ca_ext

[ca_ext]
basicConstraints        = critical,CA:true
keyUsage                = critical,keyCertSign,cRLSign
subjectKeyIdentifier    = hash

[sub_ca_ext]
authorityInfoAccess     = @issuer_info
authorityKeyIdentifier  = keyid:always
basicConstraints        = critical,CA:true,pathlen:0
crlDistributionPoints   = @crl_info
extendedKeyUsage        = clientAuth,serverAuth
keyUsage                = critical,keyCertSign,cRLSign
nameConstraints         = @name_constraints
subjectKeyIdentifier    = hash

[crl_info]
URI.0                   = `$crl_url

[issuer_info]
caIssuers;URI.0         = `$aia_url
OCSP;URI.0              = `$ocsp_url

[name_constraints]
permitted;DNS.0=`$domain_suffix
excluded;IP.0=0.0.0.0/0.0.0.0
excluded;IP.1=0:0:0:0:0:0:0:0/0:0:0:0:0:0:0:0

[ocsp_ext]
authorityKeyIdentifier  = keyid:always
basicConstraints        = critical,CA:false
extendedKeyUsage        = OCSPSigning
keyUsage                = critical,digitalSignature
subjectKeyIdentifier    = hash
"@

  Set-Content -Path "ocsp.cnf" -Value @"
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
commonName              = $CommonName OCSP Responder
"@

  $cred = New-Object System.Management.Automation.PSCredential `
    -ArgumentList "NotImportant", $RootKeyPassword
  $passin = "-passin pass:$(($cred.GetNetworkCredential().Password).Trim())"

  Write-Output "`nGenerating the root certificate private key..."

  New-OpenSslEdwardsCurveKeypair -Path "./private/$Name.key" -Password $RootKeyPassword

  Remove-Item -Path "private/$Name.key.pub"

  Write-Output "Generating the root certificate request..."

  Invoke-OpenSsl "req -new -config openssl.cnf -out $Name.csr -key private/$Name.key $passin"

  Write-Output "`n`nGenerating the root certificate for this authority..."

  Invoke-OpenSsl "ca -selfsign -config openssl.cnf -in $Name.csr -out $Name.crt -extensions ca_ext $passin"

  Write-Output "`n`nGenerating the OCSP private key for this authority...`n"

  New-OpenSslRsaKeypair -Path "private/ocsp.key" -BitSize 2048

  Remove-Item -Path "private/ocsp.key.pub"

  Write-Output "`nGenerating the OCSP certificate request..."

  Invoke-OpenSsl "req -new -config ocsp.cnf -out ocsp.csr -key private/ocsp.key"

  Write-Output "`nGenerating the OCSP Certificate for this authority..."

  Invoke-OpenSsl `
    "ca -batch -config openssl.cnf -out ocsp.crt -extensions ocsp_ext -days 30 $passin -infiles ocsp.csr"

  Set-Content -Path ".openssl_ca" -Value @"
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

function Set-OpenSslCertificateAuthoritySetting {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $Name,
    [Parameter(Mandatory = $true, Position = 1)]
    [string] $Value
  )

  if (-not (Test-OpenSslCertificateAuthority $PWD.Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  $config = "$($PWD.Path)/.openssl_ca"

  if ($null -ne (Get-OpenSslCertificateAuthoritySetting $Name)) {
    $old = (Get-Content $config | Select-String "\.$Name=(.*)$" | Out-String).Trim()
  }

  $new = ".$Name=$Value".Trim()

  if ($old) {
    $content = Get-Content $config | Where-Object { $_ -notlike $old }
    Set-Content -Path $config -Value $content -Force
  }

  Add-Content -Path $config -Value $new
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
  Invoke-OpenSsl "ca -config openssl.cnf -gencrl -out $Name.crl"

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
    "ca -batch -config openssl.cnf -out ocsp.crt -extensions ocsp_ext -days 30 -infiles ocsp.csr"

  Pop-Location
}

Set-Alias -Name update-ocsp -Value Update-OcspCerticate
