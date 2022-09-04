function Get-AvailableOpenSSLDigestAlgorithms {
  Invoke-OpenSSL "list -digest-algorithms"
}
