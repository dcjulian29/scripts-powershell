$script:msbuildExe = First-Path `
    (Find-ProgramFiles '\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\amd64\MSBuild.exe') `
    (Find-ProgramFiles 'Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe') `
    (Find-ProgramFiles 'Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\amd64\MSBuild.exe') `
    (Find-ProgramFiles 'Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe') `
    (Find-ProgramFiles 'Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\amd64\MSBuild.exe') `
    (Find-ProgramFiles 'Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe') `
    (Find-ProgramFiles 'Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\amd64\MSBuild.exe') `
    (Find-ProgramFiles 'Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\MSBuild.exe') `
    (Find-ProgramFiles 'Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\amd64\MSBuild.exe') `
    (Find-ProgramFiles 'Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe') `
    (Find-ProgramFiles 'Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\amd64\MSBuild.exe') `
    (Find-ProgramFiles 'Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe') `
    (Find-ProgramFiles 'MSBuild\15.0\bin\MSBuild.exe') `
    (Find-ProgramFiles 'MSBuild\14.0\bin\MSBuild.exe')

$script:vsvarPath = First-Path `
    (Find-ProgramFiles 'Microsoft Visual Studio\2019\Enterprise\Common7\Tools\VsDevCmd.bat') `
    (Find-ProgramFiles 'Microsoft Visual Studio\2019\Professional\Common7\Tools\VsDevCmd.bat') `
    (Find-ProgramFiles 'Microsoft Visual Studio\2019\Community\Common7\Tools\VsDevCmd.bat') `
    (Find-ProgramFiles 'Microsoft Visual Studio\2017\Enterprise\Common7\Tools\VsDevCmd.bat') `
    (Find-ProgramFiles 'Microsoft Visual Studio\2017\Professional\Common7\Tools\VsDevCmd.bat') `
    (Find-ProgramFiles 'Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat') `
    (Find-ProgramFiles 'Microsoft Visual Studio 15.0\Common7\Tools\vsvars32.bat') `
    (Find-ProgramFiles 'Microsoft Visual Studio 14.0\Common7\Tools\vsvars32.bat') `
    (Find-ProgramFiles 'Microsoft Visual Studio 12.0\Common7\Tools\vsvars32.bat') `
    (Find-ProgramFiles 'Microsoft Visual Studio 11.0\Common7\Tools\vsvars32.bat') `
    (Find-ProgramFiles 'Microsoft Visual Studio 10.0\Common7\Tools\vsvars32.bat')

Function Invoke-BuildProject {
    $param = "$args"
    if (Test-Path build.cake) {
        if ($args.Count -eq 1) {
            # Assume a target was passed in
            Invoke-Expression ".\build.ps1 -target $param"
        } else {
            Invoke-Expression ".\build.ps1 $param"
        }
    } elseif (Test-Path build.ps1) {
        Invoke-Psake .\build.ps1 $param
    } elseif (Test-Path build.bat) {
        .\build.bat $param
    } elseif (Test-Path build.cmd) {
        .\build.cmd $param
    } elseif (Test-Path build.xml) {
        C:\tools\apps\nant\bin\nant.exe -buildfile:build.xml $param
    } else {
        Write-Host "This directory does not include build script to build the project"
    }
}

Function Invoke-MSBuild {
    Register-VisualStudioVariables
    if (Test-Path $script:msbuildExe) {
        & $script:msbuildExe $args
    } else {
        Write-Error "Unable to locate MSBuild executable..."
    }
}

Function Register-VisualStudioVariables {
    if (Test-Path $script:vsvarPath) {
        cmd /c "`"$script:vsvarPath`" & set" | Foreach-Object {
            $p, $v = $_.split('=')
            Set-Item -path env:$p -value $v
        }
    }
}

Function Find-VisualStudioVariables {
    $script:vsvarPath
}

Function Find-MSBuild {
    $script:msbuildExe
}

Function Invoke-ArchiveProject {
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

Function Invoke-CleanProject {
    param (
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Project = $(Read-Host "Please provide the solution/csproj file to clean."),
        [string]$Configuration = "Debug"
    )

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

Function Invoke-CleanAllProjects {
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

function Get-CakeBuildBootstrapper {
    if (Test-Path build.ps1) {
        Remove-Item -Confirm -Path build.ps1
    }

    if (Test-Path build.ps1) {
        throw "Cake.Build Bootstraper File Still Exists! Can't Continue..."
    }

    Invoke-WebRequest https://cakebuild.net/download/bootstrapper/windows -OutFile build.ps1
}

##################################################################################################

Export-ModuleMember Find-VisualStudioVariables
Export-ModuleMember Find-MSBuild
Export-ModuleMember Invoke-ArchiveProject
Export-ModuleMember Invoke-BuildProject
Export-ModuleMember Invoke-CleanProject
Export-ModuleMember Invoke-CleanAllProjects
Export-ModuleMember Invoke-MSBuild
Export-ModuleMember Register-VisualStudioVariables

Export-ModuleMember Get-CakeBuildBootstrapper

Set-Alias bp Invoke-BuildProject
Export-ModuleMember -Alias bp

Set-Alias msbuild Invoke-MSBuild
Export-ModuleMember -Alias msbuild

Set-Alias vsvars32 Register-VisualStudioVariables
Export-ModuleMember -Alias vsvars32

Set-Alias VSVariables Register-VisualStudioVariables
Export-ModuleMember -Alias VSVariables

Set-Alias Register-VSVariables Register-VisualStudioVariables
Export-ModuleMember -Alias Register-VSVariables

Set-Alias project-archive Invoke-ArchiveProject
Export-ModuleMember -Alias project-archive

Set-Alias project-clean Invoke-CleanProject
Export-ModuleMember -Alias project-clean

Set-Alias project-clean-all Invoke-CleanAllProject
Export-ModuleMember -Alias project-clean-all
