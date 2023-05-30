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
