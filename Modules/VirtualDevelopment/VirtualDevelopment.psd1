@{
  RootModule = 'VirtualDevelopment.psm1'
  ModuleVersion = '2204.29.1'
  Description = "A collection of commands to create and manage my development virtual machine."
  GUID = '3d789869-88e4-46e8-a9f8-8cd1f8652e10'
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
    "Install-DevVmPackage"
    "New-DevVM"
    "New-LinuxDevVM"
    "Update-DevVmPackages"
  )
  CmdletsToExport = @()
  VariablesToExport = @()
  AliasesToExport = @()
  PrivateData = @{
    PSData = @{
      Tags = @(
        "dcjulian29"
        "Hyper-V"
        "hyperv"
        "choco"
        "devvm"
        "developer"
      )
      LicenseUri = 'https://github.com/dcjulian29/scripts-powershell/LICENSE.md'
      ProjectUri = 'https://github.com/dcjulian29/scripts-powershell'
      RequireLicenseAcceptance = $false
      ExternalModuleDependencies = @()
    }
  }
  HelpInfoURI = 'https://github.com/dcjulian29/scripts-powershell/tree/main/Modules/VirtualDevelopment'
}
