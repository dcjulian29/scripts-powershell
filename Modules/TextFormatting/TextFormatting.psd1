@{
  RootModule = 'TextFormatting.psm1'
  ModuleVersion = '2301.10.1'
  Description = "A collection of commands to interact with text formats."
  GUID = '1827839b-9a40-473b-bf01-2f4141ecadc1'
  Author = 'Julian Easterling'
  Copyright = '(c) Julian Easterling. Some rights reserved.'
  PowerShellVersion = '5.1'
  RequiredModules = @(
    @{
      ModuleName = "Filesystem"
      ModuleVersion = "2301.10.1"
      GUID = "aaad40aa-30a0-495c-8377-53e89ea1ec11"
     }
  )
  RequiredAssemblies = @()
  ScriptsToProcess = @()
  TypesToProcess = @()
  FormatsToProcess = @()
  NestedModules = @()
  FunctionsToExport = @(
    "ConvertTo-UnixLineEnding"
    "ConvertTo-WindowsLineEnding"
    "Format-Xml"
    "Format-Json"
    "Convert"
  )
  CmdletsToExport = @()
  VariablesToExport = @()
  AliasesToExport = @(
    "ct-unix"
    "ct-win"
    "dos2unix"
    "unix2dos"
  )
  PrivateData = @{
    PSData = @{
      Tags = @(
        "dcjulian29"
        "text"
        "format"
        "conversion"
      )
      LicenseUri = 'https://github.com/dcjulian29/scripts-powershell/LICENSE.md'
      ProjectUri = 'https://github.com/dcjulian29/scripts-powershell'
      RequireLicenseAcceptance = $false
      ExternalModuleDependencies = @()
    }
  }
  HelpInfoURI = 'https://github.com/dcjulian29/scripts-powershell/tree/main/Modules/TextFormatting'
}
