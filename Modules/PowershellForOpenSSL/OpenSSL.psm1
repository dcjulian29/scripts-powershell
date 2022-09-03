function Find-OpenSSL {
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

function Invoke-OpenSSL {
  $cmd = Find-OpenSSL

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
    Invoke-OpenSSLContainer -Command $param
  }

}

Set-Alias -Name openssl -Value Invoke-OpenSSL

function Invoke-OpenSSLContainer {
  [CmdletBinding()]
  param (
    [string]$EntryPoint,
    [string]$Command,
    [Alias("env")]
    [hashtable]$EnvironmentVariables,
    [string]$EntryScript
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

    if ($EntryPoint) {
      $params.Add("EntryPoint", $EntryPoint)
    }

    if ($EntryScript) {
      $params.Add("EntryScript", $EntryScript)
    }

    if ($Command) {
      $params.Add("Command", "`"$Command`"")
    }

    $params.GetEnumerator().ForEach({ Write-Verbose "$($_.Name)=$($_.Value)" })

    New-DockerContainer @params
  } else {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "OpenSSL container requires the Linux Docker Engine." `
      -ExceptionType "System.InvalidOperationException" `
      -ErrorId "System.InvalidOperation" `
      -ErrorCategory "InvalidOperation"))
  }
}

Set-Alias -Name opensslc -Value Invoke-OpenSSLContainer
Set-Alias -Name openssl-container -Value Invoke-OpenSSLContainer
