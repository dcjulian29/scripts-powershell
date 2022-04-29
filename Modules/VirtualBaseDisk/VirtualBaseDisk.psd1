@{
  RootModule = 'VirtualBaseDisk.psm1'
  ModuleVersion = '2204.29.1'
  Description = "A collection of commands to create Windows VHDX file that can be used with differencing disks."
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
    "Get-WindowsImagesInISO"
    "Get-WindowsImagesInWIM"
    "New-BaseVhdxDisk"
    "New-BaseServerVhdxDisks"
    "New-DevBaseVhdxDisk"
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
        "vhdx"
        "iso"
        "wim"
      )
      LicenseUri = 'https://github.com/dcjulian29/scripts-powershell/LICENSE.md'
      ProjectUri = 'https://github.com/dcjulian29/scripts-powershell'
      RequireLicenseAcceptance = $false
      ExternalModuleDependencies = @()
    }
  }
  HelpInfoURI = 'https://github.com/dcjulian29/scripts-powershell/tree/main/Modules/VirtualBaseDisk'
}
