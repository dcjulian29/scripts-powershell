$env:Path = "$env:SYSTEMDRIVE\Tools\development;$env:PATH"

function build-project
{
  if (test-path build.bat)
  {
    .\build.bat $args
  }
  else
  {
    if (test-path build.xml)
    {
      C:\bin\development-tools\nant\bin\NAnt.exe -buildfile:build.xml $args
    }
    else
    {
      Write-Host "This directory does not include build script to build the project"
    }
  }
}

Set-Alias bp build-project
