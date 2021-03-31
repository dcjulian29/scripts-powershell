@{
    ModuleVersion = '2103.20.1'
    GUID = '6aa69e5b-f92d-41ba-947b-7840504d31da'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Logging.psm1'
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Get-LogFolder"
        "Get-LogFileName"
        "Optimize-LogFolder"
        "Start-ApplicationTranscript"
        "Write-Log"
    )
    AliasesToExport = @(
        "Stop-ApplicationTranscript"
    )
}
