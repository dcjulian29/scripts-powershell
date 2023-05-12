@{
    ModuleVersion = '2305.11.1'
    GUID = '2cd0c771-ed8b-48bc-b6bc-be8540c915e4'
    Author = 'Julian Easterling'
    PowerShellVersion = '3.0'
    RootModule = 'Editors.psm1'
    NestedModules = @()
    TypesToProcess = @()
    FormatsToProcess = @()
    FunctionsToExport = @(
        "Invoke-NanoEditor"
        "Invoke-NotePadEditor"
        "Invoke-VimEditor"
    )
    AliasesToExport = @(
        "nano"
        "notepad"
        "np"
        "vi"
        "vim"
    )
}
