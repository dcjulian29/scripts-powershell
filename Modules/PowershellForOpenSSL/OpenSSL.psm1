function ConvertFrom-Base64 {
  param (
    [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [psobject] $InputObject
  )

  begin {
    $inputValue = ""
    $output = ""
    $fileName = "$(Get-OpenSslRandom 25 -Hex).dat"
  }

  process {

    foreach ($object in $InputObject) {
      $inputValue = $inputValue + ($object | Out-String)
    }
  }

  end {
    Push-Location $env:TEMP
    $inputValue | Set-Content -Path $fileName
    $output = (Invoke-OpenSsl base64 -d -in $fileName)
    Remove-Item -Path $fileName -Force
    Pop-Location

    return $output
  }
}

function ConvertTo-Base64 {
  param (
    [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [psobject] $InputObject
  )

  begin {
    $inputValue = ""
    $output = ""
    $fileName = "$(Get-OpenSslRandom 25 -Hex).dat"
    $outputFileName = "$(Get-OpenSslRandom 25 -Hex).dat"
  }

  process {

    foreach ($object in $InputObject) {
      $inputValue = $inputValue + ($object | Out-String)
    }
  }

  end {
    Push-Location $env:TEMP

    $inputValue | Set-Content -Path $fileName
    Invoke-OpenSsl base64 -in $fileName -out $outputFileName
    $output = Get-Content $outputFileName
    Remove-Item -Path $fileName -Force
    Remove-Item -Path $outputFileName -Force

    Pop-Location

    return $output
  }
}

function Get-OpenSslRandom {
  [CmdletBinding(DefaultParameterSetName = 'Bytes')]
  param (
    [Parameter(ParameterSetName = "Base64", Position = 0, Mandatory = $true)]
    [Parameter(ParameterSetName = "Bytes", Position = 0, Mandatory = $true)]
    [Parameter(ParameterSetName = "Hex", Position = 0, Mandatory = $true)]
    [Int32] $NumberOfBytes,
    [Parameter(ParameterSetName = "Hex")]
    [switch] $Hex,
    [Parameter(ParameterSetName = "Base64")]
    [switch] $Base64
  )

  switch ($PSCmdlet.ParameterSetName) {
    "Base64" { return $(Invoke-OpenSsl "rand -base64 $NumberOfBytes") }
    "Bytes" { return $(Invoke-OpenSsl "rand $NumberOfBytes") }
    "Hex" { return $(Invoke-OpenSsl "rand -hex $NumberOfBytes") }
  }
}

function Get-OpenSslVersion {
  param (
    [switch] $All
  )

  $param = "version"

  if ($All) {
    $param += " -a"
  }

  Invoke-OpenSsl $param
}

function Find-OpenSsl {
  $InPath = Get-Command "openssl.exe" -ErrorAction SilentlyContinue

  if ($InPath) {
    if ($InPath.CommandType -eq "Application") {
      return "$($InPath.Name)"
    }
  }

  $local = (First-Path `
      (Find-ProgramFiles 'OpenSSL\openssl.exe')
    )

  if ($null -eq $local) {
    if (Get-Command "docker.exe" -ErrorAction SilentlyContinue) {
      return "docker.exe run --rm -it dcjulian29/openssl:latest"
    }
  }

  return $local
}

function Invoke-OpenSsl {
  $cmd = Find-OpenSsl

  if ($null -eq $cmd) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "OpenSSL (or Docker) is not installed on this system." `
      -ExceptionType "System.InvalidOperationException" `
      -ErrorId "System.InvalidOperation" `
      -ErrorCategory "InvalidOperation"))
  }

  $param = "$args"

  if ($cmd -notlike "*docker*") {
    cmd.exe /c "$cmd $param"
  } else {
    Invoke-OpenSslContainer -Command $param
  }

}

Set-Alias -Name openssl -Value Invoke-OpenSsl

function Invoke-OpenSslContainer {
  [CmdletBinding()]
  param (
    [string]$EntryPoint,
    [string]$Command,
    [Alias("env")]
    [hashtable]$EnvironmentVariables,
    [string]$EntryScript,
    [switch]$Direct
  )

  if (-not (Get-Command "docker.exe" -ErrorAction SilentlyContinue)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "OpenSSL container requires the Docker Engine." `
      -ExceptionType "System.InvalidOperationException" `
      -ErrorId "System.InvalidOperation" `
      -ErrorCategory "InvalidOperation"))
  }

  if (Test-DockerLinuxEngine) {
    $params = @{
      Image = "dcjulian29/openssl"
      Tag = "latest"
      Interactive = $true
      Name = "openssl_shell"
      Volume = @(
        "$(Get-DockerMountPoint $PWD):/data"
      )
      Environment = $EnvironmentVariables
    }

    if ($Direct) {
      $docker = Find-Docker
      $cmd = "run -it --rm --name $($params.Name) --entrypoint $EntryPoint " `
        + "--volume $($params.Volume[0]) `"$($params.Image):$($params.Tag)`" $Command"

      Invoke-Expression "& '$docker' $cmd"
    } else {
      if ($EntryPoint) {
        $params.Add("EntryPoint", $EntryPoint)
      }

      if ($EntryScript) {
        $params.Add("EntryScript", $EntryScript)
      }

      if ($Command) {
        $params.Add("Command", "$Command")
      }

      $params.GetEnumerator().ForEach({ Write-Verbose "$($_.Name)=$($_.Value)" })

      New-DockerContainer @params
    }
  } else {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "OpenSSL container requires the Linux Docker Engine." `
      -ExceptionType "System.InvalidOperationException" `
      -ErrorId "System.InvalidOperation" `
      -ErrorCategory "InvalidOperation"))
  }
}

Set-Alias -Name opensslc -Value Invoke-OpenSslContainer
Set-Alias -Name openssl-container -Value Invoke-OpenSslContainer

function New-OpenSslDhParameters {
  param (
    [Int32] $NumberOfBits = 2048,
    [string] $Path,
    [ValidateSet("PEM", "DER")]
    [string] $Format = "PEM"
  )

  $param = "dhparam"

  if ($Path) {
    $param += " -out $Path"
  }

  switch ($Format) {
    "PEM" { $param += " -outform PEM"}
    "DER" { $param += " -outform DER"}
  }

  Invoke-OpenSsl "$param $NumberOfBits"
}

function New-OpenSslDsaParameters {
  param (
    [Int32] $NumberOfBits = 2048,
    [string] $Path,
    [ValidateSet("PEM", "DER")]
    [string] $Format = "PEM"
  )

  $param = "dsaparam"

  if ($Path) {
    $param += " -out $Path"
  }

  switch ($Format) {
    "PEM" { $param += " -outform PEM"}
    "DER" { $param += " -outform DER"}
  }

  Invoke-OpenSsl "$param $NumberOfBits"
}
