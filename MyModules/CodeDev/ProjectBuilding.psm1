$script:msbuildExe = First-Path `
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
  (Find-ProgramFiles 'Microsoft Visual Studio 15.0\Common7\Tools\vsvars32.bat') `
  (Find-ProgramFiles 'Microsoft Visual Studio 14.0\Common7\Tools\vsvars32.bat') `
  (Find-ProgramFiles 'Microsoft Visual Studio 12.0\Common7\Tools\vsvars32.bat') `
  (Find-ProgramFiles 'Microsoft Visual Studio 11.0\Common7\Tools\vsvars32.bat') `
  (Find-ProgramFiles 'Microsoft Visual Studio 10.0\Common7\Tools\vsvars32.bat')

if (Test-Path "$($env:SYSTEMDRIVE)\Tools\development")
{
    $env:Path = "$env:SYSTEMDRIVE\Tools\development;$env:PATH"
}

Function Build-Project {
    if (Test-Path build.ps1) {
        Invoke-Psake .\build.ps1 $args
    } elseif (Test-Path build.bat) {
        .\build.bat $args
    } elseif (Test-Path build.cmd) {
        .\build.cmd $args
    } elseif (Test-Path build.xml) {
        C:\tools\apps\nant\bin\nant.exe -buildfile:build.xml $args
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

##################################################################################################

Export-ModuleMember Build-Project
Export-ModuleMember Invoke-MSBuild
Export-ModuleMember Load-VisualStudioVariables
Export-ModuleMember Where-VisualStudioVariables
Export-ModuleMember Where-MSBuild

Set-Alias bp build-project
Export-ModuleMember -Alias bp

Set-Alias msbuild Invoke-MSBuild
Export-ModuleMember -Alias msbuild

Set-Alias vsvars32 Load-VisualStudioVariables
Export-ModuleMember -Alias vsvars32

Set-Alias Load-VSVariables Load-VisualStudioVariables
Export-ModuleMember -Alias Load-VSVariables
