function Get-AvailableOpenSslDigestAlgorithms {
  Invoke-OpenSsl "list -digest-algorithms"
}
