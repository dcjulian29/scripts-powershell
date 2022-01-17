@{
  RootModule = 'WebCredential.psm1'
  ModuleVersion = '2201.17.1'
  GUID = 'e2f61e99-799f-4f18-9a1e-d217dceea068'
  Author = 'Julian Easterling'
  Copyright = '(c) Julian Easterling. Some rights reserved.'
  PowerShellVersion = '5.1'
  RequiredModules = @()
  RequiredAssemblies = @()
  ScriptsToProcess = @()
  TypesToProcess = @()
  FormatsToProcess = @()
  NestedModules = @()
  FunctionsToExport = @()
  CmdletsToExport = @(
    "Get-WebCredential"
    "Remove-WebCredential"
    "Set-WebCredential"
  )
  VariablesToExport = @()
  AliasesToExport = @()
  PrivateData = @{
    PSData = @{
      Tags = @(
        "dcjulian29"
        "Credentials"
        "Web"
      )
      LicenseUri = 'https://github.com/dcjulian29/scripts-powershell/LICENSE.md'
      ProjectUri = 'https://github.com/dcjulian29/scripts-powershell'
      RequireLicenseAcceptance = $false
      ExternalModuleDependencies = @()
    }
  }
  HelpInfoURI = 'https://github.com/dcjulian29/scripts-powershell/tree/main/Modules/WebCredential'
}
