@{
    ModuleVersion = '2112.20.1'
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
        "Invoke-VisualStudioCode"
        "Invoke-VisualStudioDiff"
    )
    AliasesToExport = @(
        "code"
        "nano"
        "notepad"
        "np"
        "vi"
        "vim"
        "vscode"
        "vsdiff"
    )
}
