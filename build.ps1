trap [System.Exception] {
  "Exception: {0}" -f $_.Exception.Message
  [Environment]::Exit(1)
}

$ErrorActionPreference = "Stop"
$baseDir = (Resolve-Path $("$PSScriptRoot")).Path
$toolDir = Join-Path -Path $baseDir -ChildPath ".tools"

if (Get-Command -Name "nuget") {
  $nuget = (Get-Command -Name "nuget").Source
} else {
  $nuget = Join-Path -Path $toolDir -ChildPath "nuget.exe"

  if (-not (Test-Path -Path $nuget)) {
    if (-not (Test-Path $toolDir)) {
      New-Item -Path $toolDir -Type Directory | Out-Null
    }

    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" `
      -OutFile $nuget
  }
}

$packDir = Join-Path -Path $baseDir -ChildPath ".packages"

if (-not (Test-Path $packDir)) {
  New-Item -Path $packDir -ItemType Directory | Out-Null
}

$modulesDir = Join-Path -Path $baseDir -ChildPath Modules

#------------------------------------------------------------------------------

Get-ChildItem -Path $modulesDir -Directory | ForEach-Object {
  $id = $_.Name
  $version = "0.0.0"

  Push-Location $(Join-Path -Path $modulesDir -ChildPath $id)

  if (Test-Path "./$id.psd1") {
    $data = Import-PowerShellDataFile .\$id.psd1
    $version = $data.ModuleVersion
    $author = $data.Author
    $description = $data.Description
    $depends = $data.RequiredModules
  }

  if ($description.Length -lt 1) {
    $description = "A Julian Easterling Custom Powershell Module"
  }

  Remove-Item -Path "./package.nuspec" -Force -ErrorAction SilentlyContinue

  Set-Content -Path "./package.nuspec" -Value @"
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd">
  <metadata>
    <id>$id</id>
    <version>$version</version>
    <authors>$author</authors>$readme
    <projectUrl>https://github.com/dcjulian29/scripts-powershell/tree/main/Modules/$id</projectUrl>
    <description>$description</description>
    <license type="expression">Apache-2.0</license>
    <copyright>(c) 2022 By Julian Easterling. Some rights reserved.</copyright>
"@

  if (Test-Path -Path "./README.md") {
    Add-Content -Path "./package.nuspec" -Value "<readme>README.md</readme>"
  }

  if ($depends) {
    Add-Content -Path "./package.nuspec" -Value "<dependencies><group>"

    foreach ($depend in $depends) {
      Add-Content -Path "./package.nuspec" `
        -Value "<dependency id=`"$($depend.ModuleName)`" version=`"$($depend.ModuleVersion)`" />"
    }

    Add-Content -Path "./package.nuspec" -Value "</group></dependencies>"
  }

  Add-Content -Path "./package.nuspec" -Value @"
  </metadata>
  <files>
"@

  (Get-ChildItem -Filter "*.md").Name | ForEach-Object {
    if ($_) {
      Add-Content -Path "./package.nuspec" -Value "    <file src=`"$_`" />"
    }
  }

  (Get-ChildItem -Filter "*.psd1").Name | ForEach-Object {
    if ($_) {
      Add-Content -Path "./package.nuspec" -Value "    <file src=`"$_`" />"
    }
  }

  (Get-ChildItem -Filter "*.psm1").Name | ForEach-Object {
    if ($_) {
      Add-Content -Path "./package.nuspec" -Value "    <file src=`"$_`" />"
    }
  }

  (Get-ChildItem -Filter "*.ps1").Name | ForEach-Object {
    if ($_) {
      Add-Content -Path "./package.nuspec" -Value "    <file src=`"$_`" />"
    }
  }

  Add-Content -Path "./package.nuspec" -Value @"
  </files>
</package>
"@

  if (Test-Path "Package.nuspec") {
    $al = @(
      "pack"
      "Package.nuspec"
      "-OutputDirectory $packDir"
      "-Verbosity detailed"
      "-NoPackageAnalysis"
      "-NonInteractive"
      "-NoDefaultExcludes"
    )

    Start-Process -FilePath $nuget -ArgumentList $al -NoNewWindow -Wait
  }

  Remove-Item "package.nuspec" -Force -ErrorAction SilentlyContinue

  Pop-Location
}
