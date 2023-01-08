function ConvertTo-UnixPath {
  param(
      [Parameter(Mandatory = $true)]
      [string]$Path
  )
  if (Test-WindowsPath $Path) {
      return "/" + (($Path -replace "\\","/") -replace ":","").ToLower().Trim("/")
  } else {
      Write-Error "'$Path' is not a valid Windows Path."
  }
}

function Find-FirstPath {
  foreach ($arg in $args) {
      if ($arg -is [ScriptBlock]) {
          $path = & $arg
      } else {
          $path = $arg
      }

      if ($path) {
          if (Test-Path "$path") {
              return $path
          }
      }
  }
}

Set-Alias -Name First-Path -Value Find-FirstPath

function Find-InPath {
[CmdletBinding()]
[Alias("path-find")]
param (
  [Parameter(Mandatory = $true)]
  [string]$FileName
)

$existingPaths = $Env:Path -Split ';' `
| Where-Object { (-not [string]::IsNullOrEmpty($_)) -and (Test-Path $_ -PathType Container) }

return Get-ChildItem -Path $existingPaths -Filter $FileName | Select-Object -First 1
}

function Find-ProgramFiles {
  param (
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$Path
  )

  if  (Test-Path "$env:ProgramFiles\$Path") {
      return "$env:ProgramFiles\$Path"
  }

  if  (Test-Path "${env:ProgramFiles(x86)}\$Path") {
      return "${env:ProgramFiles(x86)}\$Path"
  }
}

function Get-FullDirectoryPath {
  param (
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$Path
  )

  if ($Path.Substring($Path.Length) -ne [IO.Path]::DirectorySeparatorChar) {
      $Path = "$Path\"
  }

  $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}

function Get-FullFilePath {
  param (
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string] $Path
  )

  $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}

function Get-Path {
  param (
      [switch]$Positions
  )

  if (($env:Path).Length -eq 0) {
      return @()
  }

  $pathList = ($env:Path).Split(';')

  if ($Positions) {
      $p = @()
      for ($i = 0; $i -lt $pathList.Count; $i++) {
         $p += "{0,3} $($pathList[$i])" -f $i
      }

      $pathList = $p
  }

  return $pathList
}

function Optimize-Path {
  Get-Path | ForEach-Object {
      if (Test-Path $_) {
          $list += "$_;"
      }
  }

  $list = $list.Substring(0,$list.Length -1)

  if (($env:Path).Length -ne ($list.Length)) {
      Set-EnvironmentVariable "Path" $list
  }
}

Set-Alias -Name Clean-Path -Value Optimize-Path

function Remove-Path {
  param (
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$Path
  )

  if (Test-InPath $Path) {
      $pathList = {[System.Collections.ArrayList](Get-Path)}.Invoke()
      $pathList.Remove($Path) | Out-Null
      $pathString = $pathList -join ';'

      Set-EnvironmentVariable "Path" $pathString
  }
}
function Set-Path {
  param (
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$Path,
      [ValidateScript({
          if ($_ -lt 0) {
              throw [System.Management.Automation.ValidationMetadataException] "Positions start at 0!"
          }

          if (($_ -gt (Get-Path).Length)) {
              throw [System.Management.Automation.ValidationMetadataException] "'${_}' exceeds the number of paths."
          }

          return $true
      })]
      [int]$Position = 0
  )

  if (($Position -ne (Get-Path).Length) -and (Test-InPathAtPosition -Path $Path -Position $Position)) {
      return
  }

  $pathList = New-Object -TypeName System.Collections.ArrayList

  Get-Path | ForEach-Object {
      $pathList.Add($_) | Out-Null
  }

  if (Test-InPath $Path) {
      $pathList.Remove($Path) | Out-Null
  }

  $pathList.Insert($Position, $Path)
  $pathString = $pathList -join ';'

  Set-EnvironmentVariable "Path" $pathString
}

function Test-InPath {
  param (
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$Path
  )

  return ((-not ($null -eq (Get-Path))) -and ((Get-Path).Contains($Path)))
}

function Test-InPathAtPosition {
  param (
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$Path,
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({
          if ($_ -lt 0) {
              throw [System.Management.Automation.ValidationMetadataException] "Positions start at 0!"
          }

          return $true
      })]
      [int]$Position
  )

  return ((-not ($null -eq (Get-Path))) `
      -and (-not ($Position -ge (Get-Path).Length)) `
      -and ((Get-Path)[$Position] -eq $Path))
}

function Test-UnixPath {
  param(
      [Parameter(Mandatory = $true)]
      [string]$Path
  )

  return $Path -match "^(\/([\w_%!$@:.,~-]+|\\.)*|[^\\])+$"
}

function Test-WindowsPath {
  param(
      [Parameter(Mandatory = $true)]
      [string]$Path
  )

  return $Path -match "([A-Za-z]+:|\.{1,2}|\\)*((\w+\\)+|\w+)+"
}
