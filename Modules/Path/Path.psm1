function Add-CygwinPath {
  $path = Find-CygwinPath

  if ($path.Length -gt 0) {
    $env:Path = "$path;$($env:PATH)"
  } else {
    Write-Error "Cygwin Not Found!"
  }
}

function Add-JavaPath {
  $path = Find-JavaPath

  if ($path.Length -gt 0) {
    $env:JAVA_HOME = $path
    $env:Path = "$path\bin;$($env:PATH)"
  } else {
    Write-Error "Java Runtime Not Found!"
  }
}

function Add-MongoDbPath {
  $path = Find-MongoDbPath

  if ($path.Length -gt 0) {
    $env:Path = "$path;$($env:PATH)"
  } else {
    Write-Error "MongoDb Not Found!"
  }
}

function Add-NodeJsPath {
  $path = Find-NodeJsPath

  if ($path.Length -gt 0) {
    $env:Path = "$path;$($env:PATH)"
  } else {
    Write-Error "NodeJS Not Found!"
  }
}

function Find-CygwinPath {
  $cygwin = ""

  if (Test-Path "C:\cygwin\bin") {
    $cygwin = "C:\cygwin\bin"
  }

  return $cygwin
}

Set-Alias path-cygwin Add-CygwinPath

function Find-InPath {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [Alias("Path")]
    [string]$FileName
  )

  $existingPaths = $Env:Path -Split ';' `
  | Where-Object { (![string]::IsNullOrEmpty($_)) -and (Test-Path $_ -PathType Container) }

  return Get-ChildItem -Path $existingPaths -Filter $FileName | Select-Object -First 1
}

Set-Alias -Name path-find -Value Find-InPath

function Find-JavaPath {
  if ([System.IntPtr]::Size -ne 4) {
    $path = Join-Path ${env:ProgramFiles(x86)} "Java"
    $path64 = Join-Path $env:ProgramFiles "Java"
  } else {
    $path = Join-Path $env:ProgramFiles "Java"
    $path64 = Join-Path $env:ProgramFiles "Java"
  }

  $java = ""

  if (Test-Path $path) {
    $path  = (Get-ChildItem -Path $path -Recurse -Include "bin").FullName `
      | Sort-Object | Select-Object -Last 1
    if (Test-Path $path) {
      $java = $path
    }
  }

  if (Test-Path $path64) {
    $path64  = (Get-ChildItem -Path $path64 -Recurse -Include "bin").FullName `
      | Sort-Object | Select-Object -Last 1
    if (Test-Path $path64) {
      $java = $path64
    }
  }

  return $java
}

Set-Alias path-java Add-JavaPath

function Find-MongoDbPath {
  First-Path `
      (Find-ProgramFiles 'MongoDB\Server\3.4\bin') `
      (Find-ProgramFiles 'MongoDB\Server\3.2\bin')
}

Set-Alias path-mongodb Add-MongoDbPath

function Find-NodeJsPath {
  $nodejs = ""

  if (Test-Path "C:\Program Files\nodejs") {
    $nodejs = "C:\Program Files\nodejs;$($env:USERPROFILE)\AppData\Roaming\npm"
  }

  if (Test-Path "C:\Program Files (x86)\nodejs") {
      $nodejs = "C:\Program Files (x86)\nodejs;$($env:USERPROFILE)\AppData\Roaming\npm"
  }

  return $nodejs
}

Set-Alias path-nodejs Add-NodeJsPath
