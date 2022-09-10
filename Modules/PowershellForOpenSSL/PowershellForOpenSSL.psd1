@{
  RootModule = 'OpenSSL.psm1'
  ModuleVersion = '2209.10.1'
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
    "Get-OpenSslEdwardsCurveKeypair"
    "Get-OpenSslElipticCurveKeypair"
    "Get-OpenSslRsaPrivateKey"
    "Get-OpenSslRandom"
    "Get-OpenSslVersion"
    "Find-OpenSsl"
    "Invoke-OpenSsl"
    "Invoke-OpenSslContainer"
    "New-OpenSsl"
    "New-OpenSslDhParameters"
    "New-OpenSslDsaParameters"
    "New-OpenSslEdwardsCurveKeypair"
    "New-OpenSslElipticCurveKeypair"
    "New-OpenSslRsaKeypair"
    "Test-CertificateOcsp"
    "Test-CertificateRevocation"
    "Test-CertificateRevocationList"
    "Test-DeployedCertificateExpired"
    "Test-DeployedCertificateRevocation"
    "Test-DeployedCertificateValidity"
  )
  CmdletsToExport = @()
  VariablesToExport = @()
  AliasesToExport = @(
    "Get-OpenSslCiphers"
    "Get-OpenSslDigestAlgorithms"
    "Get-OpenSslEllipticCurves"
    "openssl"
    "opensslc"
    "openssl-container"
    "show-certificate"
    "show-certificate-expiration"
    "show-certificate-hash"
    "show-crl"
    "show-crl-hash"
    "show-csr"
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
