@{
  RootModule = 'Powershell.psm1'
  ModuleVersion = '2201.25.1'
  Description = "A collection of utilities, commands, and functions specific to Powershell."
  GUID = 'f7824b54-f08e-415c-b661-c4605dda0603'
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
    "Reset-Module"
    "Restart-Module"
    "Search-Command"
    "Test-IsNonInteractive"
    "Test-PowershellVerb"
    "Update-AllModules"
    "Update-InstalledModules"
    "Update-MyModules"
    "Update-MyProfile"
    "Update-MyPublishedModules"
    "Update-MyThirdPartyModules"
    "Update-PreCompiledAssemblies"
    "Update-Profile"
  )
  CmdletsToExport = @()
  VariablesToExport = @()
  AliasesToExport = @(
    "Load-Assembly"
    "Find-PSCommand"
    "Reload-Module"
    "Reload-Profile"
    "Unload-Module"
  )
  PrivateData = @{
    PSData = @{
      Tags = @(
        "dcjulian29"
        "Powershell"
      )
      LicenseUri = 'https://github.com/dcjulian29/scripts-powershell/LICENSE.md'
      ProjectUri = 'https://github.com/dcjulian29/scripts-powershell'
      RequireLicenseAcceptance = $false
      ExternalModuleDependencies = @()
    }
  }
  HelpInfoURI = 'https://github.com/dcjulian29/scripts-powershell/tree/main/Modules/Powershell'
}
