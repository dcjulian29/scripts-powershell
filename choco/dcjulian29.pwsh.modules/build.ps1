trap [System.Exception] {
  "Exception: {0}" -f $_.Exception.Message
  [Environment]::Exit(1)
}

$ErrorActionPreference = "Stop"
$baseDir = (Resolve-Path $(Split-Path -Parent (Split-Path -Parent $PSScriptRoot))).Path
$toolDir = Join-Path -Path $baseDir -ChildPath ".tools"

if (Get-Command -Name "nuget" -ErrorAction SilentlyContinue) {
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

$nuspec = Join-Path -Path $PSScriptRoot -ChildPath chocolateyPackage.nuspec

#------------------------------------------------------------------------------

$project = "dcjulian29.pwsh.modules"
$major = Get-Date -Format "yyMM"
$minor = (Get-Date).Day
$patch = "1"
$baseUrl = "https://www.myget.org/F/dcjulian29-chocolatey/api/v2/package"
$version = ""

while ($version.Length -eq 0) {
  try {
  Invoke-RestMethod `
    -Uri "$baseUrl/$project/$major.$minor.$patch" `
    -Method Head

    $version = "$major.$minor.$patch"
  } catch {
    $patch++
  }
}

#------------------------------------------------------------------------------

$al = @(
  "pack"
  "$nuspec"
  "-OutputDirectory $packDir"
  "-Verbosity detailed"
  "-NoPackageAnalysis"
  "-NonInteractive"
  "-NoDefaultExcludes"
  "-Version $version"
)

Start-Process -FilePath $nuget -ArgumentList $al -NoNewWindow -Wait
