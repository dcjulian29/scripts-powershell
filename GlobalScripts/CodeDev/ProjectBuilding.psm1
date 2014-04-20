$script:msbuildExe = First-Path `
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

if (Test-Path "$($env:SYSTEMDRIVE)\Tools\development")
{
    $env:Path = "$env:SYSTEMDRIVE\Tools\development;$env:PATH"
}

function msbuild() {
    & $script:msbuildExe $args
}

function build-project {
  if (test-path build.bat) {
    .\build.bat $args
  } else {
    if (test-path build.xml) {
      C:\bin\development-tools\nant\bin\NAnt.exe -buildfile:build.xml $args
    } else {
      Write-Host "This directory does not include build script to build the project"
    }
  }
}

Set-Alias bp build-project

##################################################################################################

Export-ModuleMember build-project
Export-ModuleMember -Alias bp
