$script:cnf_ca = "ca.cnf"

function assertAuthority($path=$PWD.Path) {
  if (-not (Test-CertificateAuthority -Path $path)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "This is not a certificate authority that can be managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }
}


#--------------------------------------------------------------------------------------------------

function Get-SubordinateAuthority {
  if (-not (Test-CertificateAuthority -Root)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "Subordinate authorities are typically created within a root authority managed by this module." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  $sub = @()
  $subca = Get-CertificateAuthoritySetting subca

  foreach ($name in $subca) {
    $sn = Get-CertificateAuthoritySetting "subca_$name"
    $cert = Get-IssuedCertificate | Where-Object {$_.SerialNumber -eq $sn}
    $sub += [PSCustomObject]@{
      Name              = $name
      Mounted           = $(Test-SubordinateAuthorityMounted -Name $name)
      Status            = $cert.Status
      SerialNumber      = $sn
      DistinguishedName = $cert.DistinguishedName
      NotValidAfter     = $(if ($cert.RevocationDate) { $cert.RevocationDate } else { $cert.ExpirationDate })
    }
  }

  return $sub
}

function Test-CertificateAuthority {
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

function Test-SubordinateAuthorityMounted {
  [CmdletBinding()]
  param (
    [ValidateScript({ Test-Path })]
    [string] $Path = ($PWD.Path),
    [string] $Name = $(Split-Path -Path $Path -Leaf)
  )

  assertAuthority $Path

  if (Test-CertificateAuthority $Path -Subordinate) {
    Push-Location -Path "$((Get-Item -Path $Path).Parent.FullName)"
  } else {
    Push-Location $Path
  }


  if ($Path -like "*$Name") {
    $testfile = "$Path/.openssl_ca"
  } else {
    $testfile = "$Path/$Name/.openssl_ca"
  }

  if (Test-Path $testfile ) {
    return $true
  } else {
    return $false
  }
}
