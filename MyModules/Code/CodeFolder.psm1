function Get-DefaultCodeFolder {
    $folder = "$($env:SystemDrive)\code"

    if ($null -ne $env:CodeFolder) {
        $folder = $env:CodeFolder
    }

    return $folder
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
