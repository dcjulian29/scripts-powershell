trap [System.Exception] {
  "Exception: {0}" -f $_.Exception.Message
  [Environment]::Exit(1)
}

$ErrorActionPreference = "Stop"
$baseDir = (Resolve-Path $("$PSScriptRoot")).Path
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

#------------------------------------------------------------------------------

$lastTag = git describe --tags --abbrev=0 --match "[0-9]*.[0-9]*.[0-9]*" | ForEach-Object { $_.Trim() }
$lastVersion = [version]$lastTag

$major = Get-Date -Format "yyMM"
$minor = Get-Date -Format "d"
$patch = "1"

if ($major == $lastVersion.Major) {
  if ($minor == $lastVersion.Minor) {
    $patch == $lastVersion.Build + 1
  }
}

$version = "$major.$minor.$patch"

#------------------------------------------------------------------------------

$al = @(
  "pack"
  "chocolateyPackage.nuspec"
  "-OutputDirectory $packDir"
  "-Verbosity detailed"
  "-NoPackageAnalysis"
  "-NonInteractive"
  "-NoDefaultExcludes"
  "-Version $version"
)

Start-Process -FilePath $nuget -ArgumentList $al -NoNewWindow -Wait
