function Get-Hash
{
  param
  (
    [string]$Text,
    [ValidateSet("MD5", "SHA1", "SHA256", "SHA384", "SHA512")]
    [string]$Algorithm = "SHA1"
  )
  
  $a = [System.Security.Cryptography.HashAlgorithm]::Create($Algorithm)
   
  if (-not $a)
  {
    "Algorithm {0} not found" -f $algorithm
  }
  else
  {
    $encoding = New-Object System.Text.ASCIIEncoding
    $bytes = $encoding.GetBytes($Text)
    $hash = $a.ComputeHash($bytes)
    $hashstring = ""
    foreach ($byte in $hash) { $hashstring += $byte.ToString("x2") }
    
    $hashstring
  }
}
