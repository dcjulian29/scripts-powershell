@{
    ModuleVersion = '2020.5.28.3'
    GUID = 'da9c1ff2-0ed8-4d45-85d5-0261bc079894'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'DotNet.psm1'
    NestedModules = @()
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Get-AllAssemblyInfo"
        "Get-AssemblyInfo"
        "Get-NetFramework"
        "Test-NetFramework"
        "Test-NetFramework2"
        "Test-NetFramework3"
        "Test-NetFramework35"
        "Test-NetFramework40"
        "Test-NetFramework45"
        "Test-NetFramework451"
        "Test-NetFramework452"
        "Test-NetFramework46"
        "Test-NetFramework461"
        "Test-NetFramework462"
        "Test-NetFramework47"
        "Test-NetFramework471"
        "Test-NetFramework472"
        "Test-NetFramework48"
    )
    AliasesToExport = @(
        "aia"
    )
}
