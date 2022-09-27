@{
  RootModule = 'CertificateAuthority.psm1'
  ModuleVersion = '2209.25.1'
  Description = "A collection of commands to manage and operate a certificte authority using OpenSSL."
  GUID = '8c0c42a2-05e2-4e17-b9d4-77e77bf91b30'
  Author = 'Julian Easterling'
  Copyright = '(c) Julian Easterling. Some rights reserved.'
  PowerShellVersion = '5.1'
  RequiredModules = @(
    @{
      ModuleName = "Filesystem"
      ModuleVersion = "2209.19.1"
      GUID = "aaad40aa-30a0-495c-8377-53e89ea1ec11"
     }
     @{
      ModuleName = "PowershellForOpenSSL"
      ModuleVersion = "2209.24.1"
      GUID = "ed6e65e3-8813-426c-aa4c-b0373081f509"
     }
  )
  RequiredAssemblies = @()
  ScriptsToProcess = @()
  TypesToProcess = @()
  FormatsToProcess = @()
  NestedModules = @(
    "Authority.psm1"
    "Operations.psm1"
  )
  FunctionsToExport = @(
    "Approve-ServerCertificate"
    "Approve-SubordinateAuthority"
    "Approve-UserCertificate"
    "Get-ImportedCertificateRequest"
    "Get-IssuedCertificate"
    "Get-IssuedCertificateValidity"
    "Get-OpenSslCertificateAuthoritySetting"
    "Import-CertificateRequest"
    "New-OpenSslCertificateAuthority"
    "New-OpenSslSubordinateAuthority"
    "New-ServerCertificate"
    "New-ServerCertificateRequest"
    "New-UserCertificate"
    "New-UserCertificateRequest"
    "Revoke-Certificate"
    "Remove-OpenSslSubordinateAuthority"
    "Revoke-OpenSslSubordinateAuthority"
    "Set-OpenSslCertificateAuthoritySetting"
    "Start-OpenSslOcspServer"
    "Stop-OpenSslOcspServer"
    "Test-OpenSslCertificateAuthority"
    "Test-OpenSslSubordinateAuthorityMounted"
    "Update-CerticateAuthorityDatabase"
    "Update-CerticateAuthorityRevocationList"
    "Update-OcspCerticate"
  )
  CmdletsToExport = @()
  VariablesToExport = @()
  AliasesToExport = @(
    "ca-get"
    "ca-set"
    "ca-test"
    "ca-update"
    "crl-update"
    "Get-RevokedIssuedCertificate"
    "import-csr"
    "list-imported-requests"
    "list-issued-certificates"
    "list-revoked-certificates"
    "new-server-certificate"
    "new-user-certificate"
    "ocsp-start"
    "ocsp-stop"
    "ocsp-update"
    "remove-subca"
    "revoke-certificate"
    "revoke-issued-certificate"
    "revoke-subca"
    "sign-server-certificate"
    "sign-subordinate-authority"
    "sign-subca"
    "sign-user-certificate"
    "update-ca"
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
  HelpInfoURI = 'https://github.com/dcjulian29/scripts-powershell/tree/main/Modules/CertificateAuthority'
}
