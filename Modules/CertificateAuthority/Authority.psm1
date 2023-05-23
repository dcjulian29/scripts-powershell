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

function Publish-CertificateAuthority {
  [CmdletBinding()]
  [Alias("ca-publish")]
  param (
    [Parameter(Position = 0, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Path = "$($PWD.Path)/.publish",
    [switch] $Force
  )

  assertAuthority

  if (-not (Test-CertificateAuthority -Root)) {
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "Certificate Authorities can only be published by the root authority." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  $origialErrorActionPreference = $ErrorActionPreference
  $ErrorActionPreference = "Stop"

  Write-Verbose "Path: $Path"
  if (-not (Test-Path $Path)) {
    New-Folder $Path
  }

  $Destination = "$((Resolve-Path -Relative -Path $Path) -replace '\\', '/')"
  Write-Verbose "Destination: $Destination"

  if ((Get-ChildItem $Destination).Count -gt 0) {
    if ($Force) {
      Remove-Item -Path "$Destination/*" -Recurse -Force
    } else {
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "Files present in publish path and -Force was not supplied." `
        -ExceptionType "System.InvalidOperationException" `
        -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
    }
  }

  Set-Content -Path "$Destination/mime.types" -Value @"
application/pkcs7-mime              .p7c
application/pkcs8                   .p8  .key
application/pkcs10                  .p10 .csr
application/pkix-cert               .cer
application/pkix-crl                .crl
application/x-pem-file              .pem
application/x-pkcs7-certificates    .p7b .spc
application/x-pkcs7-certreqresp     .p7r
application/x-pkcs7-crl             .crl
application/x-pkcs12                .p12 .pfx
application/x-x509-ca-cert          .crt .der
application/x-x509-user-cert        .crt
"@

  $root = Get-CertificateAuthoritySetting name
  $authorities = @($root, $(Get-CertificateAuthoritySetting subca))

  Write-Verbose "root: $root"
  Write-Verbose "authorities: $authorities"

  foreach ($authority in $authorities) {
    if (($authority -eq $root) -or (Test-SubordinateAuthorityMounted -Name $authority)) {
      Write-Verbose "Authority is mounted. Proceeding to publish..."
      if ($authority -eq $root) {
        $subdir = "./"
      } else {
        $subdir = "$authority/"
      }

      Push-Location $subdir

      if ( "imported" -ne (Get-CertificateAuthoritySetting type)) {
        $cn = Get-CertificateAuthoritySetting cn

        Write-Output ">>>---------------- '$cn' Certificate Authority`n"

        $pass = Read-Host "Enter password for '$cn' private key" -AsSecureString

        Write-Output "Updating the certificate authority database..."
        Update-CertificateAuthorityDatabase -AuthorityPassword $pass

        if (Get-CertificateAuthoritySetting ocsp) {
          Update-OcspCertificate -AuthorityPassword $pass
        }

        if (Get-CertificateAuthoritySetting timestamp) {
          Update-TimestampCertificate -AuthorityPassword $pass
        }

        Write-Output "Updating the certificate revocation list..."
        Update-CertificateAuthorityRevocationList -AuthorityPassword $pass

        $name = Get-CertificateAuthoritySetting name
      } else {
        Write-Output ">>>---------------- '$cn' Certificate Authority"
        Write-Output "                     This is an imported authority.`n"
      }

      Pop-Location

      if (Test-Path "$($subdir)certs/ca.pem" ) {
        ConvertFrom-PemCertificate -CertPath "$($subdir)certs/ca.pem" `
        -Destination "$Destination/$name.crt" -To DER
      }

      if (Test-Path "$subdir$name.crl") {
        Invoke-OpenSsl "crl -in $subdir$name.crl -out $Destination/$name.crl -outform der"
      }

      if (Test-Path "$($subdir)certs/ocsp.pem" ) {
        Copy-Item -Path "$($subdir)certs/ocsp.pem" -Destination "$Destination/$name-ocsp.pem"
      }

      if (Test-Path "$($subdir)certs/timestamp.pem" ) {
        Copy-Item -Path "$($subdir)certs/timestamp.pem" -Destination "$Destination/$name-timestamp.pem"
      }

      $subdir = ""
    }
  }

  $ErrorActionPreference = $origialErrorActionPreference

  Write-Output "`n~~~~~~`n"
  Write-Output "This certificate authority has been published to '$Destination'"
}

function Remove-SubordinateAuthority {
  [CmdletBinding()]
  [Alias("remove-subca")]
  param (
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path),
    [string] $Name = $(Split-Path -Path $Path -Leaf)
  )

  assertAuthority $Path

  if (Test-CertificateAuthority $Path -Subordinate) {
    Push-Location -Path "$((Get-Item -Path $Path).Parent.FullName)"
  } else {
    Push-Location $Path
  }

  if (-not (Test-CertificateAuthority -Root)) {
    Pop-Location
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "'$Path' is not part of a certificate authority that includes the root authority." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  $subca = (Get-CertificateAuthoritySetting subca | Where-Object { $_ -like $Name })

  if ($subca.Length -gt 0) {
    $sn = Get-CertificateAuthoritySetting "subca_$Name"

    if ($sn -eq "~REVOKED~") {
      Set-CertificateAuthoritySetting -Name "subca" -Value $Name -Remove
      Set-CertificateAuthoritySetting -Name "subca_$Name" -Remove

      if (Test-Path "$Name/") {
        Remove-Item -Path $Name -Recurse -Force
      }
    } else {
      Pop-Location
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "'$Name' authority must be revoked before it can be removed." `
        -ExceptionType "System.InvalidOperationException" `
        -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
    }
  } else {
    Pop-Location
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "'$Name' authority is not currently managed by this root authority." `
      -ExceptionType "System.InvalidOperationException" `
      -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  Pop-Location
}

function Revoke-SubordinateAuthority {
  [CmdletBinding()]
  [Alias("revoke-subca")]
  param (
    [ValidateScript({ Test-Path $(Resolve-Path $_) })]
    [string] $Path = ($PWD.Path),
    [string] $Name = $(Split-Path -Path $Path -Leaf),
    [ValidateSet("unspecified", "keyCompromise", "CACompromise", "affiliationChanged", "superseded", "cessationOfOperation", "certificateHold", "removeFromCRL")]
    [string] $Reason = "unspecified"
  )

  assertAuthority $Path

  if (Test-CertificateAuthority $Path -Subordinate) {
    Push-Location -Path "$((Get-Item -Path $Path).Parent.FullName)"
  } else {
    Push-Location $Path
  }

  if (-not (Test-CertificateAuthority -Root)) {
    Pop-Location
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
       -Message "'$Path' is not part of a certificate authority that includes the root authority." `
       -ExceptionType "System.InvalidOperationException" `
       -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  $subca = (Get-CertificateAuthoritySetting subca | Where-Object { $_ -like $Name })

  if ($subca.Length -gt 0) {
    $sn = Get-CertificateAuthoritySetting "subca_$Name"

    if ($sn -eq "~REVOKED~") {
      Pop-Location
      $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
        -Message "'$Name' authority has already been revoked." `
        -ExceptionType "System.InvalidOperationException" `
        -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
    }

    if ($sn.Length -gt 0) {
      Invoke-OpenSsl "ca -config $($script:cnf_ca) -revoke certs/$sn.pem -crl_reason $Reason"

      Move-Item -Path "certs/$sn.pem" "certs/$sn.pem.revoked"

      Set-CertificateAuthoritySetting -Name "subca_$Name" -Value "~REVOKED~"

      if (Test-Path "$Name/") {
        ###TODO: If subordinate authority is mounted (directly below root), cycle through each issued certificate and revoke them as well
      }
    }
  } else {
    Pop-Location
    $PSCmdlet.ThrowTerminatingError((New-ErrorRecord `
      -Message "'$Name' authority is not currently managed by this root authority." `
      -ExceptionType "System.InvalidOperationException" `
      -ErrorId "System.InvalidOperation" -ErrorCategory "InvalidOperation"))
  }

  Pop-Location
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
