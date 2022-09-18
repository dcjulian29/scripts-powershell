@{
  RootModule = 'OpenSSL.psm1'
  ModuleVersion = '2209.17.1'
  Description = "A collection of commands to interact with OpenSSL."
  GUID = 'ed6e65e3-8813-426c-aa4c-b0373081f509'
  Author = 'Julian Easterling'
  Copyright = '(c) Julian Easterling. Some rights reserved.'
  PowerShellVersion = '5.1'
  RequiredModules = @()
  RequiredAssemblies = @()
  ScriptsToProcess = @()
  TypesToProcess = @()
  FormatsToProcess = @()
  NestedModules = @(
    "CertAuth.psm1"
    "Hashes.psm1"
    "x509.psm1"
  )
  FunctionsToExport = @(
    "ConvertFrom-Base64"
    "ConvertFrom-PemCertificate"
    "ConvertTo-Base64"
    "ConvertTo-PemCertificate"
    "Get-AvailableOpenSslCiphers"
    "Get-AvailableOpenSslDigestAlgorithms"
    "Get-AvailableOpenSslEllipticCurves"
    "Get-Certificate"
    "Get-CertificateExpiration"
    "Get-CertificateHash"
    "Get-CertificateOcsp"
    "Get-CertificateRequest"
    "Get-CertificateRevocation"
    "Get-CertificateRevocationHash"
    "Get-CertificateSerialNumber"
    "Get-DeployedCertificate"
    "Get-DeployedCertificateExpiration"
    "Get-DeployedCertificateValidity"
    "Get-IssuedCertificate"
    "Get-IssuedCertificateValidity"
    "Get-OpenSslCertificateAuthoritySetting"
    "Get-OpenSslEdwardsCurveKeypair"
    "Get-OpenSslElipticCurveKeypair"
    "Get-OpenSslRsaPrivateKey"
    "Get-OpenSslRandom"
    "Get-OpenSslVersion"
    "Find-OpenSsl"
    "Invoke-OpenSsl"
    "Invoke-OpenSslContainer"
    "New-OpenSsl"
    "New-OpenSslCertificateAuthority"
    "New-OpenSslDhParameters"
    "New-OpenSslDsaParameters"
    "New-OpenSslEdwardsCurveKeypair"
    "New-OpenSslElipticCurveKeypair"
    "New-OpenSslRsaKeypair"
    "New-OpenSslSubordinateAuthority"
    "Remove-OpenSslSubordinateAuthority"
    "Revoke-OpenSslSubordinateAuthority"
    "Set-OpenSslCertificateAuthoritySetting"
    "Start-OpenSslOcspServer"
    "Stop-OpenSslOcspServer"
    "Test-CertificateOcsp"
    "Test-CertificateRevocation"
    "Test-CertificateRevocationList"
    "Test-DeployedCertificateExpired"
    "Test-DeployedCertificateRevocation"
    "Test-DeployedCertificateValidity"
    "Test-OpenSslCertificateAuthority"
    "Update-CerticateAuthorityRevocationList"
    "Update-OcspCerticate"
  )
  CmdletsToExport = @()
  VariablesToExport = @()
  AliasesToExport = @(
    "Get-OpenSslCiphers"
    "Get-OpenSslDigestAlgorithms"
    "Get-OpenSslEllipticCurves"
    "Get-RevokedIssuedCertificate"
    "openssl"
    "opensslc"
    "openssl-container"
    "list-issued-certificates"
    "list-revoked-certificates"
    "remove-subca"
    "revoke-subca"
    "show-certificate"
    "show-certificate-expiration"
    "show-certificate-hash"
    "show-crl"
    "show-crl-hash"
    "show-csr"
    "update-crl"
    "update-ocsp"
  )
  PrivateData = @{
    PSData = @{
      Tags = @(
        "dcjulian29"
        "openssl"
        "certauth"
        "x509"
      )
      LicenseUri = 'https://github.com/dcjulian29/scripts-powershell/LICENSE.md'
      ProjectUri = 'https://github.com/dcjulian29/scripts-powershell'
      RequireLicenseAcceptance = $false
      ExternalModuleDependencies = @()
    }
  }
  HelpInfoURI = 'https://github.com/dcjulian29/scripts-powershell/tree/main/Modules/PowershellForOpenSsl'
}
