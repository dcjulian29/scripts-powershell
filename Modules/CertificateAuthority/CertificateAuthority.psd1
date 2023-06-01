@{
  RootModule = 'CertificateAuthority.psm1'
  ModuleVersion = '2306.1.1'
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
    "Get-ImportedCertificateRequest"
    "Get-IssuedCertificate"
    "Get-IssuedCertificateValidity"
    "Get-SubordinateAuthority"
    "Revoke-Certificate"
  )
  CmdletsToExport = @()
  VariablesToExport = @()
  AliasesToExport = @(
    "Get-RevokedIssuedCertificate"
    "list-imported-requests"
    "list-issued-certificates"
    "list-revoked-certificates"
    "revoke-issued-certificate"
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
