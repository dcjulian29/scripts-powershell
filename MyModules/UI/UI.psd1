@{
    RootModule = 'UI.psm1'
    ModuleVersion = '2019.8.18.1'
    GUID = '64252dac-92cf-41fb-9ef7-94e1a42c56ac'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Get-BingWallpaper"
        "Select-Item"
        "Set-WindowTitle"
        "Set-BingDesktopWallpaper"
        "Set-BingWallpaperScheduledTask"
        "Set-DesktopWallpaper"
    )
    AliasesToExport = @(
        "title"
    )
}
