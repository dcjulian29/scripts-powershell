$source = $PSScriptRoot
$destination = "$($env:UserProfile)\Documents\WindowsPowerShell"

Get-ChildItem -Path $source -Recurse -Force |
    Where-Object { $_.psIsContainer } |
    Where-Object { $_.FullName -notlike "*.git*" } |
    ForEach-Object { $_.FullName -replace [regex]::Escape($source), $destination } |
    ForEach-Object {
        if (-not (Test-Path $_)) {
            New-Item -ItemType Container -Path $_ | Out-Null
        }
    }

Get-ChildItem -Path $source -Recurse -Force |
    Where-Object { -not $_.psIsContainer } |
    Where-Object { $_.FullName -notlike "*.git*" } |
    Where-Object { $_.Name -notlike ".gitignore" } |
    Where-Object { $_.Name -notlike "README.md" } |
    Where-Object { $_.Name -notlike "Test-Scripts.ps1" } |
    Where-Object { $_.Name -notlike "t.ps1" } |
    Copy-Item -Force -Destination { $_.FullName -replace [regex]::Escape($source), $destination }
