function Get-AvailableOpenSslDigestAlgorithms {
  Invoke-OpenSsl "list -digest-algorithms"
}

Set-Alias -Name "Get-OpenSslDigestAlgorithms" -Value Get-AvailableOpenSslDigestAlgorithms
