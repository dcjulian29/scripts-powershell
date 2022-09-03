@{
  RootModule = 'OpenSSL.psm1'
  ModuleVersion = '2209.2.1'
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
  NestedModules = @()
  FunctionsToExport = @(
    "Find-OpenSSL"
    "Invoke-OpenSSL"
    "Invoke-OpenSSLContainer"
  )
  CmdletsToExport = @()
  VariablesToExport = @()
  AliasesToExport = @(
    "openssl"
    "opensslc"
    "openssl-container"
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
  HelpInfoURI = 'https://github.com/dcjulian29/scripts-powershell/tree/main/Modules/PowershellForOpenSSL'
}
