function Get-DefaultCodeFolder {
    $folder = "$($env:SystemDrive)\code"

    if ($null -ne $env:CodeFolder) {
        $folder = $env:CodeFolder
    }

    return $folder
}

function New-CodeFolder {
    param (
        [ValidateScript({ -not (Test-Path $(Resolve-Path $_)) })]
        [Alias("CodeFolder", "Folder")]
        [string]$Path = $(Get-DefaultCodeFolder)
    )

    if (-not (Test-Path $Path)) {
        New-Item -Type Directory -Path $Path | Out-Null
    }

    Set-CodeFolder -Path $Path
}

function Set-CodeFolder {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [Alias("CodeFolder", "Folder")]
        [string]$Path
    )

    $icon = "https://www.iconfinder.com/icons/37070/download/ico"

    Download-File $icon $Path\code.ico

    Set-Content $Path\desktop.ini @"
[.ShellClassInfo]
IconResource=$Path\code.ico,0
[ViewState]
Mode=
Vid=
FolderType=Generic
"@

    attrib.exe +S +H $Path\desktop.ini
    attrib.exe +S $Path
}

function Set-DefaultCodeFolder {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path
    )

    Set-EnvironmentVariable -Name "CodeFolder" -Value $Path
}

function Test-DefaultCodeFolder {
    return Test-Path $(Get-DefaultCodeFolder)
}
