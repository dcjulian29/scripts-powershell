@{
    ModuleVersion = '2201.9.2'
    GUID = 'c3dae059-3060-43cf-8492-45eb86b78cf6'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Versioning.psm1'
    NestedModules = @(
        "VersioningSemantic.psm1"
    )
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "ConvertFrom-DatedVersion"
        "ConvertTo-AssemblyVersion"
        "Get-SemanticVersion"
        "Get-Version"
        "New-SemanticVersion"
        "New-Version"
        "Set-SemanticVersion"
        "Set-Version"
        "Step-BuildVersion"
        "Step-MajorVersion"
        "Step-MinorVersion"
        "Step-RevisionVersion"
        "Step-SemanticMajorVersion"
        "Step-SemanticMinorVersion"
        "Step-SemanticPatchVersion"
        "Test-SemanticVersion"
        "Test-Version"
    )
    AliasesToExport = @(
        "Get-SemVer"
        "New-SemVer"
        "Test-SemVer"
    )
}
