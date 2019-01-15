$script:msbuildExe = First-Path `
    ("$($env:SYSTEMDRIVE)\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\amd64\MSBuild.exe") `
    ("$($env:SYSTEMDRIVE)\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\MSBuild.exe") `
    ("$($env:SYSTEMDRIVE)\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\amd64\MSBuild.exe") `
    ("$($env:SYSTEMDRIVE)\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe") `
    ("$($env:SYSTEMDRIVE)\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\amd64\MSBuild.exe") `
    ("$($env:SYSTEMDRIVE)\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe") `
    ("$($env:SYSTEMDRIVE)\Program Files\MSBuild\15.0\bin\MSBuild.exe") `
    ("$($env:SYSTEMDRIVE)\Program Files (x86)\MSBuild\15.0\bin\MSBuild.exe") `
    ("$($env:SYSTEMDRIVE)\Program Files\MSBuild\14.0\bin\MSBuild.exe") `
    ("$($env:SYSTEMDRIVE)\Program Files (x86)\MSBuild\14.0\bin\MSBuild.exe") `
    ("$($env:SYSTEMDRIVE)\Program Files\MSBuild\12.0\bin\MSBuild.exe") `
    ("$($env:SYSTEMDRIVE)\Program Files (x86)\MSBuild\12.0\bin\MSBuild.exe") `
    ("$($env:WINDIR)\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe") `
    ("$($env:WINDIR)\Microsoft.NET\Framework64\v3.5\MSBuild.exe") `
    ("$($env:WINDIR)\Microsoft.NET\Framework64\v3.0\MSBuild.exe") `
    ("$($env:WINDIR)\Microsoft.NET\Framework64\v2.0.50727\MSBuild.exe") `
    ("$($env:WINDIR)\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe") `
    ("$($env:WINDIR)\Microsoft.NET\Framework\v3.5\MSBuild.exe") `
    ("$($env:WINDIR)\Microsoft.NET\Framework\v3.0\MSBuild.exe") `
    ("$($env:WINDIR)\Microsoft.NET\Framework\v2.0.50727\MSBuild.exe")

$script:vsvarPath = First-Path `
  (Find-ProgramFiles 'Microsoft Visual Studio\2017\Enterprise\Common7\Tools\VsDevCmd.bat') `
  (Find-ProgramFiles 'Microsoft Visual Studio\2017\Professional\Common7\Tools\VsDevCmd.bat') `
  (Find-ProgramFiles 'Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat') `
  (Find-ProgramFiles 'Microsoft Visual Studio 15.0\Common7\Tools\vsvars32.bat') `
  (Find-ProgramFiles 'Microsoft Visual Studio 14.0\Common7\Tools\vsvars32.bat') `
  (Find-ProgramFiles 'Microsoft Visual Studio 12.0\Common7\Tools\vsvars32.bat') `
  (Find-ProgramFiles 'Microsoft Visual Studio 11.0\Common7\Tools\vsvars32.bat') `
  (Find-ProgramFiles 'Microsoft Visual Studio 10.0\Common7\Tools\vsvars32.bat')

Function Build-Project {
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
    Load-VisualStudioVariables
    if (Test-Path $script:msbuildExe) {
        & $script:msbuildExe $args
    } else {
        Write-Error "Unable to locate MSBuild executable..."
    }
}

Function Load-VisualStudioVariables {
    if (Test-Path $script:vsvarPath) {
        cmd /c "`"$script:vsvarPath`" & set" | Foreach-Object {
            $p, $v = $_.split('=')
            Set-Item -path env:$p -value $v
        }
    }
}

Function Where-VisualStudioVariables {
    $script:vsvarPath
}

Function Where-MSBuild {
    $script:msbuildExe
}

Function Invoke-ArchiveProject {
    param (
        [ValidateScript({ Test-Path $(Resolve-Path $_) })]
        [string]$Path = $pwd
    )

    Push-Location $Path

    Get-ChildItem -Filter "*.sln" -Recurse | % { 
        Invoke-CleanProject "$($_.FullName)" -Configuration "Debug"
    }

    Get-ChildItem -Filter "*.sln" -Recurse | % { 
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
    
    Get-ChildItem -Directory | % { 
        Push-Location $_.FullName

        Get-ChildItem -Filter "*.sln" -Recurse | % { 
            Invoke-CleanProject -Project "$($_.FullName)" -Configuration "$Configuration"
        }

        Pop-Location
    }

    Pop-Location
}

##################################################################################################

Export-ModuleMember Build-Project
Export-ModuleMember Invoke-MSBuild
Export-ModuleMember Load-VisualStudioVariables
Export-ModuleMember Where-VisualStudioVariables
Export-ModuleMember Where-MSBuild
Export-ModuleMember Invoke-ArchiveProject
Export-ModuleMember Invoke-CleanProject
Export-ModuleMember Invoke-CleanAllProjects


Set-Alias bp build-project
Export-ModuleMember -Alias bp

Set-Alias msbuild Invoke-MSBuild
Export-ModuleMember -Alias msbuild

Set-Alias vsvars32 Load-VisualStudioVariables
Export-ModuleMember -Alias vsvars32

Set-Alias Load-VSVariables Load-VisualStudioVariables
Export-ModuleMember -Alias Load-VSVariables

Set-Alias project-archive Invoke-ArchiveProject
Export-ModuleMember -Alias project-archive

Set-Alias project-clean Invoke-CleanProject
Export-ModuleMember -Alias project-clean

Set-Alias project-clean-all Invoke-CleanAllProject
Export-ModuleMember -Alias project-clean-all
