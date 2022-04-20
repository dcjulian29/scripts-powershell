@{
  RootModule = 'PSExtensions.psm1'
  ModuleVersion = '2204.20.1'
  Description = "A collection of utilities, commands, and functions specific to extending Powershell."
  GUID = '72b96fb6-bfd3-47cc-88ca-39558e0d3fa1'
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
    "Edit-Profile"
    "Get-AvailableExceptionsList"
    "Get-LastExecutionTime"
    "Get-PowershellVerbs"
    "Get-Profile"
    "Import-Assembly"
    "New-ErrorRecord"
    "Remove-AliasesFromScript"
    "Search-Command"
    "Test-IsNonInteractive"
    "Test-PowershellVerb"
    "Update-MyProfile"
    "Update-Profile"
  )
  CmdletsToExport = @()
  VariablesToExport = @()
  AliasesToExport = @(
    "Load-Assembly"
    "Find-PSCommand"
    "Reload-Profile"
  )
  PrivateData = @{
    PSData = @{
      Tags = @(
        "dcjulian29"
        "PSExtensions"
      )
      LicenseUri = 'https://github.com/dcjulian29/scripts-powershell/LICENSE.md'
      ProjectUri = 'https://github.com/dcjulian29/scripts-powershell'
      RequireLicenseAcceptance = $false
      ExternalModuleDependencies = @()
    }
  }
  HelpInfoURI = 'https://github.com/dcjulian29/scripts-powershell/tree/main/Modules/PSExtensions'
}
