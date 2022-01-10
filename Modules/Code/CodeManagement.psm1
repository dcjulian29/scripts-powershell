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

function Invoke-SortConfigurationFile {
    param (
        [string[]] $Files
    )

    if (-not $Files) {
        $Files += (Get-ChildItem -Path $pwd -Filter web*.config -Recurse).FullName
        $Files += (Get-ChildItem -Path $pwd -Filter app*.config -Recurse).FullName
    }

    foreach ($file in $Files) {
        if (-not (Test-Path $file)) {
            continue
        }

        $original = [xml] (Get-Content $file)
        $workingCopy = $original.Clone()

        if ($null -ne $workingCopy.configuration.appSettings) {
            $sorted = $workingCopy.configuration.appSettings.add `
                | Sort-Object { [string]$_.key }
            $lastChild = $sorted[-1]
            $sorted[0..($sorted.Length-2)] | `
                ForEach-Object {
                    $workingCopy.configuration.appSettings.InsertBefore($_, $lastChild)
                } | Out-Null
        }

        if ($null -ne $workingCopy.configuration.runtime.assemblyBinding) {
            $sorted = $workingCopy.configuration.runtime.assemblyBinding.dependentAssembly `
                | Sort-Object { [string]$_.assemblyIdentity.name }
            $lastChild = $sorted[-1]
            $sorted[0..($sorted.Length-2)] `
                | ForEach-Object {
                    $workingCopy.configuration.runtime.assemblyBinding.InsertBefore($_,$lastChild)
                } | Out-Null
        }

        $differencesCount = (Compare-Object -ReferenceObject (Select-Xml -Xml $original -XPath "//*") `
            -DifferenceObject (Select-Xml -Xml $workingCopy -XPath "//*")).Length

        if ($differencesCount -ne 0) {
            $workingCopy.Save($file) | Out-Null
        }
    }
}

Set-Alias -Name Sort-ConfigurationFile -Value Invoke-SortConfigurationFile
Set-Alias -Name sort-config -Value Invoke-SortConfigurationFile

function Invoke-SortProjectFile {
    param (
        [string[]] $Files
    )

    if (-not $Files) {
        $Files += (Get-ChildItem -Path $pwd -Filter *.csproj -Recurse).FullName
        $Files += (Get-ChildItem -Path $pwd -Filter *.fsproj -Recurse).FullName
    }

    foreach ($file in $Files) {
        if (-not (Test-Path $file)) {
            continue
        }

        $original = [xml] (Get-Content $file)
        $workingCopy = $original.Clone()

        foreach($itemGroup in $workingCopy.Project.ItemGroup){
            if ($null -ne $itemGroup.Reference) {
                $sorted = $itemGroup.Reference | Sort-Object { [string]$_.Include }
                $itemGroup.RemoveAll() | Out-Null
                foreach ($item in $sorted) {
                    $itemGroup.AppendChild($item) | Out-Null
                }
            }

            if ($null -ne $itemGroup.Compile) {
                $sorted = $itemGroup.Compile | Sort-Object { [string]$_.Include }
                $itemGroup.RemoveAll() | Out-Null
                foreach ($item in $sorted) {
                    $itemGroup.AppendChild($item) | Out-Null
                }
            }

            if ($null -ne $itemGroup.ProjectReference) {
                $sorted = $itemGroup.ProjectReference | Sort-Object { [string]$_.Include }
                $itemGroup.RemoveAll() | Out-Null
                foreach ($item in $sorted) {
                    $itemGroup.AppendChild($item) | Out-Null
                }
            }
        }

        $differencesCount = (Compare-Object -ReferenceObject (Select-Xml -Xml $original -XPath "//*") `
            -DifferenceObject (Select-Xml -Xml $workingCopy -XPath "//*")).Length

        if ($differencesCount -ne 0) {
            $workingCopy.Save($file) | Out-Null
        }
    }
}

Set-Alias -Name Sort-ProjectFile -Value Invoke-SortProjectFile
Set-Alias -Name sort-project -Value Invoke-SortProjectFile
