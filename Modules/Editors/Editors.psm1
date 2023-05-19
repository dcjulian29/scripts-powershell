function Invoke-NotePadEditor {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path
    )

    $Path = (Resolve-Path $Path).Path
    $notePad = Find-ProgramFiles 'Notepad++\notepad++.exe'
    $param = "-nosession $Path"

    Start-Process -FilePath $notePad -ArgumentList $param
}

Set-Alias notepad Invoke-NotePadEditor
Set-Alias np Invoke-NotePadEditor
