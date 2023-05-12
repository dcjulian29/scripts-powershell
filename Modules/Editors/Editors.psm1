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
