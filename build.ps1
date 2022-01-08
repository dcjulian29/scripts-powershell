if ($null -eq ${env:NuGetApi}) {
  $profileFile = Join-Path -Path "$($env:SystemDrive)/etc/nuget" -ChildPath "powershell.json"

  $json = Get-Content -Raw -Path $profileFile | ConvertFrom-Json

  $env:NuGetUrl = $json.Url
  $env:NuGetApi = $json.Api
}

$baseDir = (Resolve-Path $("$PSScriptRoot")).Path

Push-Location $baseDir\MyModules

Get-ChildItem -Directory | ForEach-Object {
    Push-Location $_.Name

    Remove-Item *.nupkg -Force -ErrorAction SilentlyContinue
    Remove-Item "package.nuspec" -Force -ErrorAction SilentlyContinue

    $id = $_.Name
    $version = "0.0.0"

    if (Test-Path ".\$id.psd1") {
      $version = (Import-PowerShellDataFile .\$id.psd1).ModuleVersion
    }

    Write-Output "`n`n------------> $id (v$version)"

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
  Add-Content -Path "package.nuspec" -Value "    <file src=`"$_`" />"
}

(Get-ChildItem -Filter "*.psm1").Name | ForEach-Object {
  Add-Content -Path "package.nuspec" -Value "    <file src=`"$_`" />"
}

(Get-ChildItem -Filter "*.ps1").Name | ForEach-Object {
  Add-Content -Path "package.nuspec" -Value "    <file src=`"$_`" />"
}

Add-Content -Path "package.nuspec" -Value @"
  </files>
</package>
"@

  & nuget pack package.nuspec -Verbosity detailed -NoPackageAnalysis -NonInteractive -NoDefaultExcludes

  Write-Output "`nPublishing '$id' v$version to $env:NuGetUrl"
  & nuget push *.nupkg $env:NuGetApi -Source $env:NuGetUrl

  Pop-Location
}

Remove-Item *.nupkg -Force -ErrorAction SilentlyContinue
Remove-Item "package.nuspec" -Force -ErrorAction SilentlyContinue

Pop-Location
