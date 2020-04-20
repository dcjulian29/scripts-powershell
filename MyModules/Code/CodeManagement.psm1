function Invoke-ArchiveProject {
    param (
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path = $pwd
    )

    Push-Location $Path

    Get-ChildItem -Filter "*.sln" -Recurse | ForEach-Object {
        Invoke-CleanProject "$($_.FullName)" -Configuration "Debug"
    }

    Get-ChildItem -Filter "*.sln" -Recurse | ForEach-Object {
        Invoke-CleanProject "$($_.FullName)" -Configuration "Release"
    }

    $destination = $(Join-Path (Split-Path -Path $Path -Parent) `
        -ChildPath "$(Split-Path -Path $Path -Leaf).7z")

    Write-Output "Archiving $(Split-Path -Path $Path -Leaf)..."

    $zip = Join-Path $(Find-ProgramFiles "7-Zip") -ChildPath "7z.exe"

    & $zip a -t7z -mx9 -y -r $destination .

    Pop-Location
}

Set-Alias project-archive Invoke-ArchiveProject

function Invoke-CleanAllProjects {
    param (
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path = $pwd,
        [string]$Configuration = "Debug"
    )

    Push-Location $Path

    Get-ChildItem -Directory | ForEach-Object {
        Push-Location $_.FullName

        Get-ChildItem -Filter "*.sln" -Recurse | ForEach-Object {
            Invoke-CleanProject -Project "$($_.FullName)" -Configuration "$Configuration"
        }

        Pop-Location
    }

    Pop-Location
}

Set-Alias project-clean-all Invoke-CleanAllProject

function Invoke-CleanProject {
    param (
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Project = $(Read-Host "Please provide the solution/csproj file to clean."),
        [string]$Configuration = "Debug"
    )

    if (Test-Path ".build") {
        Remove-Item -Path ".build" -Recurse -Force
    }

    if (Test-Path "build") {
        Remove-Item -Path "build" -Recurse -Force
    }

    if (Test-Path "tools") {
        Remove-Item -Path "tools" -Recurse -Force
    }

    if (Test-Path "packages") {
        Remove-Item -Path "packages" -Recurse -Force
    }

    Invoke-MSBuild "$Project" /m /t:clean /p:configuration="$Configuration"
}

Set-Alias project-clean Invoke-CleanProject
