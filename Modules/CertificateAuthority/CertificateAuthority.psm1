function Get-OpenSslCertificateAuthoritySetting {
  [CmdletBinding()]
  [Alias("ca-get")]
  param (
    [Parameter(Position = 0)]
    [string] $Name = "*",
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path)
  )

  if (-not (Test-OpenSslCertificateAuthority $Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  if ($Name -eq '*') {
    $content = Get-Content "$($Path)/.openssl_ca"
    $results = @()

    foreach ($line in $content) {
      $result = $line | Select-String "\.(.*)=(.*)$"

      if ($result.Matches.Count -eq 1) {
        $results += [PSCustomObject]@{
          Name = ($result.Matches[0].Groups[1].Value | Out-String).Trim()
          Value = ($result.Matches[0].Groups[2].Value | Out-String).Trim()
        }
      }
    }

    return $results
  }

  $result = (Get-Content "$($Path)/.openssl_ca" | Select-String "\.$Name=(.*)$" -AllMatches)
  $results = @()

  if ($result.Matches.Count -gt 0) {
    for ($i = 0; $i -lt $result.Matches.Count; $i++) {
      $results += ($result.Matches[$i].Groups[1].Value | Out-String).Trim()
    }

    return $results
  } else {
    return $null
  }
}

function Set-OpenSslCertificateAuthoritySetting {
  [CmdletBinding(DefaultParameterSetName = "add")]
  [Alias("ca-set")]
  param (
    [Parameter(ParameterSetName = "add", Mandatory = $true, Position = 0)]
    [Parameter(ParameterSetName = "remove", Mandatory = $true, Position = 0)]
    [string] $Name,
    [Parameter(ParameterSetName = "add", Mandatory = $true, Position = 1)]
    [Parameter(ParameterSetName = "remove", Position = 1)]
    [string] $Value,
    [Parameter(ParameterSetName = "add")]
    [Parameter(ParameterSetName = "remove")]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path),
    [Parameter(ParameterSetName = "add")]
    [switch] $Append,
    [Parameter(ParameterSetName = "remove", Mandatory = $true)]
    [switch] $Remove
  )

  if (-not (Test-OpenSslCertificateAuthority $Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  $config = "$($Path)/.openssl_ca"

  if ($null -ne (Get-OpenSslCertificateAuthoritySetting $Name)) {
    if (-not $Append) {
      if ($Value.Length -gt 0) {
        $content = Get-Content $config | Where-Object { $_ -notlike ".$Name=$Value" }
      } else {
        $content = Get-Content $config | Where-Object { $_ -notlike "*$Name*" }
      }

      Set-Content -Path $config -Value  $content -Force
    }
  }

  if ($PsCmdlet.ParameterSetName -eq "add") {
    Add-Content -Path $config -Value ".$Name=$Value".Trim()
  }
}

function Start-OpenSslOcspServer {
  [Alias("ocsp-start")]
  param (
    [Parameter(Position = 0)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path),
    [String] $Port = 8080
  )

  if (-not (Test-OpenSslCertificateAuthority $Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  Push-Location $Path

  $Name = Get-OpenSslCertificateAuthoritySetting Name

  $params = @{
    Command = "ocsp -port $Port -index db/index -rsigner ocsp.crt -rkey private/ocsp.key -CA $Name.crt -text"
    Interactive = $false
    Name = "ocsp_$Name"
    Port = @(
      "${Port}:$Port/tcp"
    )
  }

  if (-not (Get-DockerContainerNames -Running | Where-Object { $_.Name -eq $params.Name })) {
    Invoke-OpenSslContainer @params
    Pop-Location
  } else {
    Pop-Location
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "An OCSP server is already running for this certificate authority." `
      -ExceptionType "System.InvalidOperationException" `
      -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }
}

function Stop-OpenSslOcspServer {
  [Alias("ocsp-stop")]
  param (
    [Parameter(Position = 0)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path)
  )

  if (-not (Test-OpenSslCertificateAuthority $Path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  Push-Location $Path
  $name = "ocsp_$(Get-OpenSslCertificateAuthoritySetting Name)"
  Pop-Location

  if (Get-DockerContainerNames -Running | Where-Object { $_.Name -eq $name }) {
    Get-DockerContainer -Running | Where-Object { $_.Name -eq $name } | Remove-DockerContainer
  } else {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "An OCSP server is not running for this certificate authority." `
      -ExceptionType "System.InvalidOperationException" `
      -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }
}

function Test-OpenSslCertificateAuthority {
  [CmdletBinding()]
  [Alias("ca-test")]
  param (
    [Parameter(Position = 0)]
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path),
    [switch] $Root,
    [switch] $Subordinate
  )

  $result = Test-Path "$Path/.openssl_ca"

  if ($result) {
    if ($root) {
      return (Get-Content .openssl_ca | Select-String ".type=root").Matches.Count -gt 0
    }

    if ($Subordinate) {
      return (Get-Content .openssl_ca | Select-String ".type=subordinate").Matches.Count -gt 0
    }
  }

  return $result
}
