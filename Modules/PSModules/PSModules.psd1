@{
  RootModule = 'PSModules.psm1'
  ModuleVersion = '2301.10.1'
  Description = "A collection of utilities, commands, and functions specific to Powershell modules."
  GUID = 'c4d33743-f3f8-4dde-a8ff-78c7934497af'
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
    "Get-InstalledModuleReport"
    "Optimize-InstalledModules"
    "Reset-Module"
    "Restart-Module"
    "Update-InstalledModules"
    "Update-PreCompiledAssemblies"
  )
  CmdletsToExport = @()
  VariablesToExport = @()
  AliasesToExport = @(
    "Reload-Module"
    "Remove-OutdatedModules"
    "Unload-Module"
  )
  PrivateData = @{
    PSData = @{
      Tags = @(
        "dcjulian29"
        "PSModules"
      )
      LicenseUri = 'https://github.com/dcjulian29/scripts-powershell/LICENSE.md'
      ProjectUri = 'https://github.com/dcjulian29/scripts-powershell'
      RequireLicenseAcceptance = $false
      ExternalModuleDependencies = @()
    }
  }
  HelpInfoURI = 'https://github.com/dcjulian29/scripts-powershell/tree/main/Modules/PSModules'
}
