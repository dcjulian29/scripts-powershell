@{
    RootModule = 'Chocolatey.psm1'
    ModuleVersion = '2019.12.21.1'
    GUID = '36e1692e-e76a-421e-a04e-e4c0460e12fe'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Find-InstalledChocolateyPackages"
        "Find-UpgradableChocolateyPackages"
        "Install-ChocolateyPackage"
        "New-ChocolateyPackage"
        "Update-AllChocolateyPackages"
        "Update-ChocolateyPackage"
        "Uninstall-ChocolateyPackage"
    )
    AliasesToExport = @(
        "chocoupdate"
        "choco-make-package"
        "Make-ChocolateyPackage"
        "Upgrade-AllChocolateyPackage"
        "Upgrade-ChocolateyPackage"
    )
}
