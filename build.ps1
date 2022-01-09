trap [System.Exception] {
  "Exception: {0}" -f $_.Exception.Message
  [Environment]::Exit(1)
}

if ($null -eq ${env:NuGetApi}) {
  $profileFile = Join-Path -Path "$($env:SystemDrive)/etc/nuget" -ChildPath "powershell.json"

  $json = Get-Content -Raw -Path $profileFile | ConvertFrom-Json

  $env:NuGetUrl = $json.Url
  $env:NuGetApi = $json.Api
}

$baseDir = (Resolve-Path $("$PSScriptRoot")).Path

Push-Location $baseDir

$TOOLS_DIR = Join-Path $baseDir "tools"
$NUGET_EXE = Join-Path $TOOLS_DIR "nuget.exe"
$NUGET_URL = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"

if (-not (Test-Path $NUGET_EXE)) {
  Write-Output "Trying to find nuget.exe in PATH..."
  $existingPaths = $Env:Path -Split ';' `
    | Where-Object { (![string]::IsNullOrEmpty($_)) -and (Test-Path $_ -PathType Container) }
  $NUGET_EXE_IN_PATH = Get-ChildItem -Path $existingPaths -Filter "nuget.exe" | Select-Object -First 1

  if (($null -ne $NUGET_EXE_IN_PATH) -and (Test-Path $NUGET_EXE_IN_PATH.FullName)) {
    Write-Output "Found in PATH at $($NUGET_EXE_IN_PATH.FullName)."
    $NUGET_EXE = $NUGET_EXE_IN_PATH.FullName
  } else {
    if (-not (Test-Path $TOOLS_DIR)) {
      Write-Output "Creating tools directory..."
      New-Item -Path $TOOLS_DIR -Type Directory | Out-Null
    }

    Write-Output "Downloading NuGet.exe..."
    Invoke-WebRequest -Uri $NUGET_URL -OutFile $NUGET_EXE
  }
}

Pop-Location

Push-Location $baseDir\MyModules

Get-ChildItem -Directory | ForEach-Object {
  $id = $_.Name
  $version = "0.0.0"

  Write-Output "##teamcity[blockOpened name='$id (v$version)']"
  Push-Location $_.Name

  Remove-Item *.nupkg -Force -ErrorAction SilentlyContinue
  Remove-Item "package.nuspec" -Force -ErrorAction SilentlyContinue

  if (Test-Path ".\$id.psd1") {
    $version = (Import-PowerShellDataFile .\$id.psd1).ModuleVersion
  }

  Set-Content -Path "package.nuspec" -Value @"
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd">
  <metadata>
    <id>$id</id>
    <version>$version</version>
    <authors>Julian Easterling</authors>
    <projectUrl>https://github.com/dcjulian29/scripts-powershell/tree/main/MyModules/$id</projectUrl>
    <description>A Julian Easterling Custom Powershell Module</description>
  </metadata>
  <files>
"@

(Get-ChildItem -Filter "*.psd1").Name | ForEach-Object {
  if ($_) {
    Add-Content -Path "package.nuspec" -Value "    <file src=`"$_`" />"
  }
}

(Get-ChildItem -Filter "*.psm1").Name | ForEach-Object {
  if ($_) {
    Add-Content -Path "package.nuspec" -Value "    <file src=`"$_`" />"
  }
}

(Get-ChildItem -Filter "*.ps1").Name | ForEach-Object {
  if ($_) {
    Add-Content -Path "package.nuspec" -Value "    <file src=`"$_`" />"
  }
}

Add-Content -Path "package.nuspec" -Value @"
  </files>
</package>
"@

  & "$NUGET_EXE" pack package.nuspec -Verbosity detailed -NoPackageAnalysis -NonInteractive -NoDefaultExcludes

  Write-Output "`nPublishing '$id' v$version to $env:NuGetUrl"
  & "$NUGET_EXE" push *.nupkg $env:NuGetApi -Source $env:NuGetUrl

  Remove-Item *.nupkg -Force -ErrorAction SilentlyContinue
  Remove-Item "package.nuspec" -Force -ErrorAction SilentlyContinue

  Pop-Location

  Write-Output "##teamcity[blockClosed name='$id (v$version)']"
  Write-Output "`n`n"
}

Pop-Location
