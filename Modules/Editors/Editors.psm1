function Invoke-NanoEditor {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path
    )

    $Path = (Resolve-Path $Path).Path

    $folder = ConvertTo-UnixPath $(Split-Path $Path)
    $file = $(Split-Path -Leaf $Path)

    $entrypoint = "${env:TEMP}\entrypoint.sh"

    if (Test-Path $entrypoint) {
      Remove-Item -Path $entrypoint -Force
    }

    Set-Content -Path $entrypoint -NoNewline `
      -Value "#!/bin/sh`n`n/sbin/apk add nano > /dev/null`n/usr/bin/nano /data/$file`n"

    New-DockerContainer -Image "alpine" -Tag "latest" -Interactive -Name "nano_editor" `
        -Volume "${folder}:/data", "$(ConvertTo-UnixPath $env:TEMP)/entrypoint.sh:/sbin/entrypoint.sh" `
        -EntryPoint "/sbin/entrypoint.sh"
}

Set-Alias -Name nano -Value Invoke-NanoEditor

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

function Invoke-VimEditor {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path
    )

    $Path = (Resolve-Path $Path).Path
    $folder = ConvertTo-UnixPath $(Split-Path $Path)
    $file = $(Split-Path -Leaf $Path)

    $entrypoint = "${env:TEMP}\entrypoint.sh"

    if (Test-Path $entrypoint) {
      Remove-Item -Path $entrypoint -Force
    }

    Set-Content -Path $entrypoint -NoNewline `
      -Value "#!/bin/sh`n`n/usr/bin/vi /data/$file`n"

    New-DockerContainer -Image "alpine" -Tag "latest" -Interactive -Name "vim_editor" `
        -Volume "${folder}:/data", "$(ConvertTo-UnixPath $env:TEMP)/entrypoint.sh:/sbin/entrypoint.sh" `
        -EntryPoint "/sbin/entrypoint.sh"

}

Set-Alias -Name vi -Value Invoke-VimEditor
Set-Alias -Name vim -Value Invoke-VimEditor

function Invoke-VisualStudioCode {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path
    )

    $Path = (Resolve-Path $Path).Path
    $code = Find-ProgramFiles 'Microsoft VS Code\Code.exe'
    $param = "--new-window  '$Path'"

    Start-Process -FilePath $code -ArgumentList $param
}

Set-Alias -Name code -Value Invoke-VisualStudioCode
Set-Alias -Name vscode -Value Invoke-VisualStudioCode

function Invoke-VisualStudioDiff {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path1,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path2
    )

    $Path1 = (Resolve-Path $Path1).Path
    $Path2 = (Resolve-Path $Path2).Path

    $code = Find-ProgramFiles 'Microsoft VS Code\Code.exe'
    $param = "--new-window --diff `"$Path1`" `"$Path2`""

    Start-Process -FilePath $code -ArgumentList $param
}

Set-Alias -Name vsdiff -Value Invoke-VisualStudioDiff
